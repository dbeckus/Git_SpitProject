/*
    click sendEmail button to add PDF Attachment to POC.
    controller of page SendPocSummaryEmail
*/
public with sharing class SendPocSummaryControler
{
    private static String ContentWorkspaceId = '058500000004GBb';
    
    public SendPocSummaryControler()
    {
    }  
    
    public PageReference redirect()
    {
        String pocId = ApexPages.currentPage().getParameters().get('id');
        List<POC_Summary__c> pocs = [select Id, Name, POC_For__r.Name from POC_Summary__c where Id =:pocId limit 1];  
        if(pocs.size() > 0)
        {        
            POC_Summary__c poc = pocs[0];
            try
            {
                createPocSummaryPDF(poc);
                createFilesInContentLibrary(poc);
                poc.Email_Sending__c = true;
                poc.Email_Report__c = true; 
                update poc;
                return new PageReference('/' + poc.Id);
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'Please click the button on POC Summary page.'));
            return null;
        }
    }
    
    //this method is called from a poc trigger
    @future
    public static void sendBatchEmails(Set<Id> pocIds)
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> temporaryHtmlFiles = new List<Attachment>();
        User currentUser = [select Id, Email from User where Id=:UserInfo.getUserId() limit 1];
        for(POC_Summary__c poc : [select Id, POC_For__r.Name, (select Id from Attachments) from POC_Summary__c where Id in :pocIds])
        {
            String oppName = poc.POC_For__r.Name;
            oppName = (oppName.length() > 70) ? oppName.substring(0, 70) : oppName;
        
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject('POC Summary');
            message.setToAddresses(new String[] { currentUser.Email });
            message.setCcAddresses(new String[] { 'tek-talk@silver-peak.com' });
            message.setPlainTextBody('POC Summary');
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            for(Attachment file : [select Id, Name, Body from Attachment where ParentId=:poc.Id])
            {
                if(file.Name == getTemporaryHtmlFileName(oppName))
                {
                    message.setHtmlBody(file.Body.toString());
                    temporaryHtmlFiles.add(file);
                }
                else
                {
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName(file.Name);
                    attachment.setBody(file.Body);
                    attachments.add(attachment);
                }
            }
            message.setFileAttachments(attachments);
            emails.add(message);
        }
        Messaging.sendEmail(emails);
        List<POC_Summary__c> pocsToBeClear = new List<POC_Summary__c>();
        for(Id pocId : pocIds)
        {
            pocsToBeClear.add(new POC_Summary__c(Id=pocId, Email_Sending__c=false));
        }
        update pocsToBeClear;
        if(temporaryHtmlFiles.size() > 0)
        {
            delete temporaryHtmlFiles;
        }
    }
    
    private void createPocSummaryPDF(POC_Summary__c poc)
    {
        String oppName = poc.POC_For__r.Name;
        oppName = (oppName.length() > 70) ? oppName.substring(0, 70) : oppName;
        String pdfFileName = 'POC-' + oppName + '.pdf';
        
        PageReference pdfPage = new PageReference('/apex/POCSummaryPdf');
        pdfPage.getParameters().put('id', poc.id);
        Blob pdfBlob = (!Test.isRunningTest()) ? pdfPage.getContentAsPdf() : Blob.valueOf('acme');  //getContent method always fails in test methods
        Blob textBlob = (!Test.isRunningTest()) ? pdfPage.getContent() : Blob.valueOf('acme');
        
        List<Attachment> attachments = [select Id from Attachment where Name=:pdfFileName and ParentId=:poc.Id limit 1];
        if(attachments.size() == 0) 
        {
            Attachment a = new Attachment(ParentId = poc.Id, Name = pdfFileName, Body = pdfBlob);
            insert a;
        }
        else
        {
            attachments[0].Body = pdfBlob;
            update attachments[0];
        }
        Attachment textFile = new Attachment(ParentId=poc.Id, Name=getTemporaryHtmlFileName(oppName), Body=textBlob);  //textFile is for email sending temporarily, will be removed in a future method
        insert textFile;
    }
    
    private static String getTemporaryHtmlFileName(String oppName)
    {
        return 'POC-' + oppName + '.html';
    }
    
    private void createFilesInContentLibrary(POC_Summary__c poc)
    {
        String oppName = poc.POC_For__r.Name;
        oppName = (oppName.length() > 70) ? oppName.substring(0, 70) : oppName;

        String filenamePrefix = 'POC-' + oppName;
        List<Attachment> existingAttachments = [select Id, Name, Body from Attachment where ParentId=:poc.Id];
        List<String> attachmentNames = new List<String>();
        for(Attachment file : existingAttachments)
        {
            if(file.Name == filenamePrefix + '.pdf')
            {
                attachmentNames.add(filenamePrefix);
            }
            else
            {
                attachmentNames.add(trimFileExtension(filenamePrefix + '-' + file.Name));
            }
        }

        List<ContentWorkspaceDoc> existingContentDocs = [select ContentDocumentId, ContentDocument.Title from ContentWorkspaceDoc where ContentWorkspaceId=:ContentWorkspaceId and ContentDocument.Title in :attachmentNames];
        List<ContentVersion> versionsOfExisting = new List<ContentVersion>();
        List<ContentVersion> versionsOfNew = new List<ContentVersion>();
        for(Attachment file : existingAttachments)
        {
            Boolean found = false;
            String title = trimFileExtension(file.Name);
            for(ContentWorkspaceDoc doc : existingContentDocs)
            {
                if(filenamePrefix + '-' + title == doc.ContentDocument.Title || title == doc.ContentDocument.Title)
                {
                    String filename = (file.Name == filenamePrefix + '.pdf') ? file.Name : filenamePrefix + '-' + file.Name;
                    ContentVersion version = new ContentVersion(ContentDocumentId=doc.ContentDocument.Id, PathOnClient=filename, VersionData=file.Body, ReasonForChange='New version submitted');
                    versionsOfExisting.add(version);
                    found = true;
                    break;
                }
            }
            if(!found)
            {
                String filename = (file.Name == filenamePrefix + '.pdf') ? file.Name : filenamePrefix + '-' + file.Name;
                ContentVersion version = new ContentVersion(PathOnClient=filename, VersionData=file.Body);
                versionsOfNew.add(version);
            }
        }
        
        try
        {
            if(versionsOfExisting.size() > 0)
            {
                insert versionsOfExisting;
            }
            if(versionsOfNew.size() > 0)
            {
                insert versionsOfNew;
                versionsOfNew = [select Id, ContentDocumentId from ContentVersion where Id in :versionsOfNew];
                List<ContentWorkSpaceDoc> docsOfNew = new List<ContentWorkSpaceDoc>();
                for(ContentVersion version : versionsOfNew)
                {
                    docsOfNew.add(new ContentWorkspaceDoc(ContentDocumentId=version.ContentDocumentId, ContentWorkspaceId=ContentWorkspaceId));
                }
                insert docsOfNew;
            }
        }
        catch(Exception ex)
        {
            //ignore the exceptions in content library
        }
     }
     
     private static String trimFileExtension(String filename)
     {
         if(filename.indexOf('.') > 0)
         {
             return filename.substring(0, filename.lastIndexOf('.'));
         }
         else
         {
             return filename;
         }
     }
     
     @isTest
     static void testSendPocSummaryControler()
     {
         Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery');
         insert opp;
         POC_Summary__c pocnew = new POC_Summary__c(POC_For__c = opp.Id);
         insert pocnew;
         PageReference page = new PageReference('/apex/SendPocSummary?id=' + pocnew.Id);
         Test.setCurrentPage(page);
         SendPocSummaryControler controller = new SendPocSummaryControler();
         controller.redirect();
         pocnew = [select Id, Email_Report__c from POC_Summary__c where Id=:pocnew.Id limit 1];
         System.assertEquals(true, pocnew.Email_Report__c);
     }    
}