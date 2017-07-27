global class RequeueCaseController {
    
    public string CaseId{get;set;}
    public RequeueCaseController(ApexPages.StandardController std)
    { 
    }
    
    public PageReference AutoSave()
    {
        CaseId = ApexPages.currentPage().getParameters().get('id');
        System.debug('test'+CaseId);
        SavePoint sp= Database.setSavepoint();
        try
        {
            
            Case caseInfo=[Select Id,ContactId,OwnerId,Owner.Email,CaseNumber,CC1__c,CC2__c,CC3__c,CC4__c,CC5__c,CC6__c,CC7__c,CC8__c,CC9__c,CC10__c,CC11__c,CC12__c from Case where Id=:CaseId];
           
            Case caseToUpdate= new Case(Id=caseInfo.Id,Status='Customer Awaiting Call',OwnerId='00G500000016yiB');
            update caseToUpdate;
            SendEmailToCustomer(caseInfo);
            SendEmailToInternal(caseInfo);
            
        }
        catch(Exception ex)
        {
            Database.Rollback(sp);
            SilverPEakUtils.logException(ex);
            System.debug(ex.getStackTraceString());
            System.debug(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
        
        PageReference pageRef = new PageReference('/'+CaseId);
        return pageRef;
    }
    
    private void SendEmailToInternal(Case caseInfo)
    {
         System.debug('caseInfo.Owner.email' +caseInfo.OwnerId);
        List<String> ccs = new List<String>();
        if(caseInfo.Owner.email!=null)
        {
             ccs.add(caseInfo.Owner.Email);
             ccs.add('customerresponse@answer1.com');
        }
           
        
        System.debug('caseInfo.Owner.email'+caseInfo.Owner.email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String formattedString = String.format('Case {0} Initiate Case Transfer Request Notification.', new String[]{caseInfo.CaseNumber});
        mail.setSubject(formattedString);
        string datastring= 'Hello,\r\n\r\n This is to notify that the customer has initiated a request to requeue the case. It has been assigned to csr answer1. \r\n\r\n  Thank you,\r\n\r\n Silver Peak Support';
        Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
        if(orgWideEmail != null)
        {
            mail.setOrgWideEmailAddressId(orgWideEmail);
        }
        mail.setPlainTextBody(string.valueof(datastring));
        mail.setToAddresses(ccs);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
    private void SendEmailToCustomer(Case caseInfo)
    {
        List<EmailTemplate> template = [select Id from EmailTemplate where Name='Case Requeue Contact' limit 1];
        if(template.size() > 0)
        {
            List<String> ccs = new List<String>();
            if(caseInfo.CC1__c!=null)
                ccs.add(caseInfo.CC1__c);
            if(caseInfo.CC2__c!=null)
                ccs.add(caseInfo.CC2__c);
            if(caseInfo.CC3__c!=null)
                ccs.add(caseInfo.CC3__c);
            if(caseInfo.CC4__c!=null)
                ccs.add(caseInfo.CC4__c);
            if(caseInfo.CC5__c!=null)
                ccs.add(caseInfo.CC5__c);
            if(caseInfo.CC6__c!=null)
                ccs.add(caseInfo.CC6__c);
            if(caseInfo.CC7__c!=null)
                ccs.add(caseInfo.CC7__c);
            if(caseInfo.CC8__c!=null)
                ccs.add(caseInfo.CC8__c);
            if(caseInfo.CC9__c!=null)
                ccs.add(caseInfo.CC9__c);
            if(caseInfo.CC10__c!=null)
                ccs.add(caseInfo.CC10__c);
            if(caseInfo.CC11__c!=null)
                ccs.add(caseInfo.CC11__c);
            if(caseInfo.CC12__c!=null)
                ccs.add(caseInfo.CC12__c);
            
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template[0].Id);
            email.setTargetObjectId(caseInfo.ContactId);
            email.setCcAddresses(ccs);
            email.setWhatId(caseInfo.Id);
            email.setsaveAsActivity(false);
            Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
            if(orgWideEmail != null)
            {
                email.setOrgWideEmailAddressId(orgWideEmail);
            }
            Messaging.sendEmail(new List<Messaging.Email> {email}, true);  }
    }
}