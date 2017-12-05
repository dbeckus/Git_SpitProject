@isTest
public class MarketingFundsControllerTest {
    @isTest
    public static void testAnonymousUser()
    {
        List<User> crrentUser = [Select Id from User where Profile.Name = 'Silver Peak Partner Community Profile' limit 1];
        if(crrentUser.isEmpty())
        {
            return;
        }
        system.runAs(crrentUser[0])
        {
            MarketingFundsController mfc1 = new MarketingFundsController();
            mfc1.pap1.Country__c = 'USA';
            mfc1.pap1.State__c = 'California';
            mfc1.eventDetails = 'test;test;';
            mfc1.saveMDF();
            //mfc1.saveApprovedMDF();
            
            MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                    Silver_Peak_Speaking_Opportunity__c = 'Yes');
            insert mdf;
            List<Attachment> atts = new List<Attachment>();
            Attachment accountAttachment = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'Target Account List', ParentId = mdf.Id);
            atts.add(accountAttachment);
            Attachment eventAgendaAttachment = new Attachment(Name = 'Test', Body = Blob.valueOf('Test Data'), Description = 'Event Agenda',ParentId = mdf.Id);
            atts.add(eventAgendaAttachment);
            insert atts;
            Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), Blob.valueOf(mdf.Id + '|' + Date.today().format()));
            String url = EncodingUtil.base64Encode(cryptoData);
            ApexPages.currentPage().getParameters().put('id',url);
            MarketingFundsController mfc = new MarketingFundsController();
            mfc.pap1.Country__c = '';
            mfc.pap1.State__c = '';
            mfc.saveMDF();
            //mfc.saveApprovedMDF();
            
            MarketingFundsController mfc2 = new MarketingFundsController();
            mfc2.getAWSConfig();
            //mfc2.accountAttachment.Body = Blob.valueOf('Test Data');
            //mfc2.eventAgendaAttachment.Body = Blob.valueOf('Test Data');
            mfc2.request = new MDF_Request__c(Type_of_Program__c ='Awareness', Silver_Peak_Speaking_Opportunity__c = 'No', Approval_Status__c = 'Approved', Activity_Complete__c = true,Expected_Audience_Size__c = 2, Expected_Number_of_Leads__c = 2,Est_Value_of_Expected_Opportunities__c = 2,Event_Location_City__c = 'los', Event_Location_Zip__c = 'testZip');
            mfc2.pap1.Country__c = 'USA';
            mfc2.pap1.State__c = 'California';
            system.assertEquals(true, mfc2.validateFileds());
            mfc2.request = new MDF_Request__c(Type_of_Program__c ='Enablement');
            mfc2.pap1.Country__c = '';
            mfc2.pap1.State__c = '';
            system.assertEquals(false, mfc2.validateFileds());
            try
            {
                mfc2.saveMDF();
            }
            catch(Exception ex)
            {
                ex.getMessage();
            }
            //mfc2.saveApprovedMDF();
        }
    }
    
    @isTest
    public static void testLoginUser()
    {
        MarketingFundsController mfc1 = new MarketingFundsController();
        mfc1.pap1.Country__c = 'USA';
        mfc1.pap1.State__c = 'California';
        mfc1.eventDetails = 'test;test;';
        mfc1.saveMDF();
        //mfc1.saveApprovedMDF();

        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes');
        insert mdf;
        ApexPages.currentPage().getParameters().put('id',mdf.id);
        MarketingFundsController mfc = new MarketingFundsController();
        mfc.pap1.Country__c = '';
        mfc.pap1.State__c = '';
        mfc.saveMDF();
        //mfc.saveApprovedMDF();
        
        //Test editMDF and editMDFResult
        PageReference ref = mfc.editMDF();
        system.assertEquals(true, mfc.editable);
        ref = mfc.editMDFResult();
        system.assertEquals(true, mfc.resultEditable);
        
        MarketingFundsController mfc2 = new MarketingFundsController();
        //mfc2.accountAttachment.Body = Blob.valueOf('Test Data');
        //mfc2.eventAgendaAttachment.Body = Blob.valueOf('Test Data');
        //mfc2.accountAttachment.Name = 'Test';
        //mfc2.eventAgendaAttachment.Name = 'Test';
        mfc2.request = new MDF_Request__c(Type_of_Program__c ='Awareness', Silver_Peak_Speaking_Opportunity__c = 'No', Approval_Status__c = 'Approved', Activity_Complete__c = true,Expected_Audience_Size__c = 2, Expected_Number_of_Leads__c = 2,Est_Value_of_Expected_Opportunities__c = 2,Event_Location_City__c = 'los', Event_Location_Zip__c = 'testZip');
        mfc2.pap1.Country__c = 'USA';
        mfc2.pap1.State__c = 'California';
        system.assertEquals(true, mfc2.validateFileds());
        try
        {
            mfc2.saveMDF();
        }
        catch(Exception ex)
        {
        }
        
        MarketingFundsController.MDF newMDF = new MarketingFundsController.MDF();
        newMDF.Total_Attendees = '10';
        newMDF.Event_Results_Opportunities = '20';
        newMDf.Total_Qualified_Leads = '30';
        newMDF.Estimated_Pipeline_Value = '40';
        newMDF.Result_Detail = '50';
        newMDF.Requested_Reimbursement_Amount = '60';
        newMDF.Topic_Course = '70';
        newMDF.Number_of_Certifications = '80';
        newMDF.invoice = 1;
        newMDF.proof = 2;
        newMDF.attendance = 3;
        
        //add 3 contentVersions sample 
        ContentVersion invoiceCv = new ContentVersion(Title = 'title', PathOnClient = 'test', IsMajorVersion = false, Description = 'invoice', VersionData = Blob.valueOf('Test Data'));
        insert invoiceCv;
        invoiceCv = [Select Id, ContentDocumentId from ContentVersion where Id =: invoiceCv.Id];
        //ContentDocumentLink invoiceLdl = new ContentDocumentLink(ContentDocumentId = invoiceCv.ContentDocumentId, LinkedEntityId = mdf.Id,ShareType='V');
        //insert invoiceLdl;
        ContentVersion proofCv = new ContentVersion(Title = 'title', PathOnClient = 'test', IsMajorVersion = false, Description = 'proof', VersionData = Blob.valueOf('Test Data'));
        insert proofCv;
        proofCv = [Select Id, ContentDocumentId from ContentVersion where Id =: proofCv.Id];
        ContentDocumentLink proofLdl = new ContentDocumentLink(ContentDocumentId = proofCv.ContentDocumentId, LinkedEntityId = mdf.Id,ShareType='V');
        insert proofLdl;
        ContentVersion attendanceCv = new ContentVersion(Title = 'title', PathOnClient = 'test', IsMajorVersion = false, Description = 'attendance', VersionData = Blob.valueOf('Test Data'));
        insert attendanceCv;
        attendanceCv = [Select Id, ContentDocumentId from ContentVersion where Id =: attendanceCv.Id];
        ContentDocumentLink attendanceLdl = new ContentDocumentLink(ContentDocumentId = attendanceCv.ContentDocumentId, LinkedEntityId = mdf.Id,ShareType='V');
        insert attendanceLdl;
        mfc2.getFile(mdf.Id);
        MarketingFundsController.AWSResponse response = new MarketingFundsController.AWSResponse();
        response.FileName = 'test';
        MarketingFundsController.linkFileToMFR(response, mdf.Id, true, null);
        //MarketingFundsController.linkFileToMFR(mdf.Id, proofCv.Id, true, null);
        MarketingFundsController.updateMDF(newMDF,'');
        MarketingFundsController.updateMDF(newMDF, mdf.Id);
        MDF_Request__c eMdf = new MDF_Request__c(Type_of_Program__c ='Enablement', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes');
        insert eMdf;
        MarketingFundsController.updateMDF(newMDF, eMdf.Id);
        newMDF.Total_Attendees='';
        newMDF.Requested_Reimbursement_Amount = 'Error Data';
        mfc2.getFile(eMdf.Id);
        MarketingFundsController.updateMDF(newMDF, eMdf.Id);
        
        
    }
    
    @isTest
    public static void testPartnerController()
    {
        PartnerMDFListingController pmc = new PartnerMDFListingController();
    }
}