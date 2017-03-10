/*
* Sends notification to customers when asset is expiring/expired on T0, T30, T60, T90
*/
public class ECSubscriptionExpirationReminderJob implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    private static final string TemplateIdT_30 = 'EC_Subs_License_Email_T_30_Days';
    private static final string TemplateIdT0 = 'EC_Subscription_License_Email_Expiration';
    private static final string TemplateIdT30 = 'EC_Subscription_License_Email_T_30_Days';
    private static final string TemplateIdT60 = 'EC_Subscription_License_Email_T_60_Days';
    private static final string TemplateIdT90 = 'EC_Subscription_License_Email_T_90_Days';
    private static final Id FromAddressId = '0D2500000004CZL';
    private static final List<Id> ExclusionIds = new List<Id> { '0015000000cQ9H6', '00130000007mEjX' };  //exclude silver-peak account
        
        private Integer emailsSentCount = 0;
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new ECSubscriptionExpirationReminderJob(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        List<Date> expirationDates = new List<Date> { Date.today().addDays(-30), Date.today().addDays(-1), Date.today().addDays(30), Date.today().addDays(60), Date.today().addDays(90) };
            return Database.getQueryLocator([select Id from Contact where Id in (select ContactId from Asset where Product2.Name like 'EC%' and Opt_Out_Subscription_Reminder__c=false and Hosted_GMS__c=false and Product2.Family='Virtual Image' and Product2.Product_Type__c='EDGECONNECT' and Status not in('Customer Evaluation','Conditional PO') and Product2.Product_Category__c in ('Subscription','GMS') and License_End_Date__c in :expirationDates)]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        Set<Id> contactsT_30 = new Set<Id>(), contactsT0 = new Set<Id>(), contactsT30 = new Set<Id>(), contactsT60 = new Set<Id>(), contactsT90 = new Set<Id>();
        Set<Id> accountsT_30 = new Set<Id>(), accountsT0 = new Set<Id>(), accountsT30 = new Set<Id>(), accountsT60 = new Set<Id>(), accountsT90 = new Set<Id>();
        List<Id> accountIds = new List<Id>();
        List<Asset> lstExpiredAssets= new List<Asset>();
        Map<Id, Set<Id>> contact2Account = new Map<Id, Set<Id>>();
        Map<Id, String> userEmails = new Map<Id, String>();
        List<Date> expirationDates = new List<Date> { Date.today().addDays(-30), Date.today().addDays(-1), Date.today().addDays(30), Date.today().addDays(60), Date.today().addDays(90) };
            for(Asset asset : [select Id, AccountId, ContactId, License_End_Date__c, Contact.Owner.Email from Asset where Product2.Name like 'EC%' and Opt_Out_Subscription_Reminder__c=false and Hosted_GMS__c=false and Product2.Family='Virtual Image' and Product2.Product_Type__c='EDGECONNECT' and Status not in('Customer Evaluation','Conditional PO') and Product2.Product_Category__c='Subscription' and License_End_Date__c in :expirationDates and ContactId in :scope and AccountId not in :ExclusionIds])
        {
            accountIds.add(asset.AccountId);
            if(!contact2Account.containsKey(asset.ContactId))
            {
                contact2Account.put(asset.ContactId, new Set<Id>());
            }
            contact2Account.get(asset.ContactId).add(asset.AccountId);
            userEmails.put(asset.ContactId, asset.Contact.Owner.Email);
            if(asset.License_End_Date__c!=null && asset.License_End_Date__c == Date.today().adddays(-30))
            {
                contactsT_30.add(asset.ContactId);
                accountsT_30.add(asset.AccountId);
            }
            else if(asset.License_End_Date__c!=null && asset.License_End_Date__c == Date.today().addDays(-1))
            {
                contactsT0.add(asset.ContactId);
                accountsT0.add(asset.AccountId);
                lstExpiredAssets.add(new Asset(Id= asset.Id,Status='Customer Subscription Expired',Licenses_Nodes__c=0,Bandwidth_Nodes__c=0));
            }
            else if(asset.License_End_Date__c!=null && asset.License_End_Date__c == Date.today().adddays(30))
            {
                contactsT30.add(asset.ContactId);
                accountsT30.add(asset.AccountId);
            }
            else if(asset.License_End_Date__c!=null && asset.License_End_Date__c == Date.today().adddays(60))
            {
                contactsT60.add(asset.ContactId);
                accountsT60.add(asset.AccountId);
            }
            else if(asset.License_End_Date__c!=null && asset.License_End_Date__c == Date.today().adddays(90))
            {
                contactsT90.add(asset.ContactId);
                accountsT90.add(asset.AccountId);
            }
        }
        MarkOrchestratorAsExpired(accountsT0);
        Set<Id> allContacts = new Set<Id>();
        allContacts.addAll(contactsT_30);
        allContacts.addAll(contactsT0);
        allContacts.addAll(contactsT30);
        allContacts.addAll(contactsT60);
        allContacts.addAll(contactsT90);
        if(allContacts.size() > 0)
        {
            Map<Id, List<String>> teamMemberEmails = getAccountTeamEmails(accountIds);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            for(Id contactId : contactsT_30)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    if(accountsT_30.contains(accountId))// Send an email if the account has expired assets. This is to handle scenario where a contact can be linked to multiple accounts
                    {
                        emails.add(getEmailMessage(contactId, accountId, TemplateIdT_30, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                    }
                }
            }
            for(Id contactId : contactsT0)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    if(accountsT0.contains(accountId))
                    {
                        emails.add(getEmailMessage(contactId, accountId, TemplateIdT0, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                    }
                }
            }
            for(Id contactId : contactsT30)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    if(accountsT30.contains(accountId))
                    {
                        emails.add(getEmailMessage(contactId, accountId, TemplateIdT30, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                    }
                }
            }
            for(Id contactId : contactsT60)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    if(accountsT60.contains(accountId))
                    {
                        emails.add(getEmailMessage(contactId, accountId, TemplateIdT60, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                    }
                }
            }
            for(Id contactId : contactsT90)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    if(accountsT90.contains(accountId))
                    {
                        emails.add(getEmailMessage(contactId, accountId, TemplateIdT90, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                    }
                }
            }
            if(emails.size() > 0)
            {
                Messaging.sendEmail(emails, false);
                emailsSentCount += emails.size();
                if(lstExpiredAssets.size()>0)
                {
                    update lstExpiredAssets;
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        insert new ErrorLog__c(Subject__c='EC Subscription Expiration Reminder', Message__c='Sent ' + emailsSentCount + ' emails.');
    }
    
    private boolean MarkOrchestratorAsExpired(Set<Id> acctIds)
    {
        List<Asset> lstAsset=[Select Id, Status from Asset where AccountId in:acctIds and  Status ='Customer Subscription Active' and Product2.Family='Virtual Image' and Product2.Name='EC-ORCH'];
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(Asset item: lstAsset)
            {
                item.status='Customer Subscription Expired';
            }
            
            update lstAsset;
        }
        
        return true;
    }
    
    private List<String> getCcEmails(Id contactId, Map<Id, String> userEmails, Id accountId, Map<Id, List<String>> teamMemberEmails)
    {
        List<String> emailAddresses = new List<String>();
        String ownerEmail = userEmails.get(contactId);
        emailAddresses.add(ownerEmail);
        if(accountId != null && teamMemberEmails.containsKey(accountId))
        {
            emailAddresses.addAll(teamMemberEmails.get(accountId));
        }
        return emailAddresses;
    }
    
    //returns the emails of account team members of specified accounts
    //only returns 'account manager' and 'systems engineer'
    private Map<Id, List<String>> getAccountTeamEmails(List<Id> accountIds)
    {
        Map<Id, List<String>> teamMemberEmails = new Map<Id, List<String>>();
        for(AccountTeamMember member : [select AccountId, User.Email from AccountTeamMember where AccountId in :accountIds and TeamMemberRole in ('Account Manager', 'Systems Engineer')])
        {
            if(teamMemberEmails.containsKey(member.AccountId))
            {
                teamMemberEmails.get(member.AccountId).add(member.User.Email);
            }
            else
            {
                teamMemberEmails.put(member.AccountId, new List<String> { member.User.Email });
            }
        }
        return teamMemberEmails;
    }
    
    private Messaging.SingleEmailMessage getEmailMessage(Id recipientId, Id whatId, string templateName, List<String> ccEmails)
    {
        EmailTemplate temp=[Select Id from EmailTemplate where DeveloperName=:templateName limit 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(recipientId);
        email.setWhatId(whatId);
        email.setTemplateId(temp.Id);
        email.setOrgWideEmailAddressId(FromAddressId);
        email.setSaveAsActivity(false);
        ccEmails.add('notifications@silver-peak.com');
        email.setCcAddresses(ccEmails);
        return email;
    } 
}