/*
 *  Sends email to the lead owners if the deferral date is today.
 */
global class DeferralLeadBatchJob implements Database.Batchable<Sobject>, Database.Stateful
{
    private Integer leadCount = 0;
    private Integer userCount = 0;
    private Id EmailAddressId = null;

    global Database.Querylocator start(Database.BatchableContext BC)
    {
        List<OrgWideEmailAddress> emailAddresses = [select Id, DisplayName, Address from OrgWideEmailAddress where Address like 'notifications@%'];
        if(emailAddresses.size() > 0)
        {
            EmailAddressId = emailAddresses[0].Id;
        }        
        if(Test.isRunningTest())
        {
            return Database.getQueryLocator([select Id, Email from User where Id=:UserInfo.getUserId() limit 1]);
        }
        else
        {
            return Database.getQueryLocator([select Id, Email from User where IsActive=true and Email like '%@silver-peak.com']);
        }  
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEMailMessage>();
        for(User usr : scope)
        {
            List<Lead> deferralLeads = [select Id, Name, Company, Deferral_Date__c, OwnerId from Lead where OwnerId=:usr.Id and Deferral_Date__c = Today];
            if(deferralLeads.size() > 0)
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(usr.Id);
                email.setSubject('Lead Notification');
                email.setHtmlBody(composeDeferralLeadEmail(deferralLeads));
                email.setSaveAsActivity(false);
                if(EmailAddressId != null)
                {
                    email.setOrgWideEmailAddressId(EmailAddressId);
                }
                mails.add(email);
                
                userCount++;
                leadCount += deferralLeads.size();
            }
        }
        if(mails.size() > 0)
        {
            Messaging.sendEmail(mails);
            mails = new List<Messaging.SingleEMailMessage>();
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if(leadCount > 0)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { 'curtisc@silver-peak.com' });
            email.setSubject('Deferral Leads Notification Summary');
            email.setPlainTextBody('Totally ' + userCount + ' users get notified. \r\nIncludes ' + leadCount + ' leads.\r\n' + Date.today().format());
            if(EmailAddressId != null)
            {
                email.setOrgWideEmailAddressId(EmailAddressId);
            }
            Messaging.sendEmail(new Messaging.Email[] {email});
        }
    }
    
    private String composeDeferralLeadEmail(List<Lead> leads)
    {
        String result = 'This is a reminder that the following leads have been deferred for follow to today. Please review and update them as needed.<br/>';
        result += '<ul>';
        for(Lead currentLead : leads)
        {
            result += '<li><a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + currentLead.Id + '">' + currentLead.Name + '</a>&nbsp;' + currentLead.Company + '</li>';
        }
        result += '</ul>';    
        return result;
    }    
    
    @isTest
    static void testCaseAuditBatchJob()
    {
        Lead lead = new Lead(LastName='acme', Company='acme', Status='Sales Accepted - Deferred', Deferral_Date__c=Date.today(), OwnerId=UserInfo.getUserId());
        insert lead;
        Test.StartTest();
        DeferralLeadBatchJob batch = new DeferralLeadBatchJob();
        Database.executeBatch(batch, 10); 
        Test.StopTest();
    }    
}