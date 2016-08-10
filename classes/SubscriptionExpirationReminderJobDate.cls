/*
 * Sends notification to customers when asset is expiring/expired on T0, T30, T60, T90
 */
public class SubscriptionExpirationReminderJobDate implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    private static final Id TemplateIdT_30 = '00X50000001ZtD4';
    private static final Id TemplateIdT0 = '00X50000001ZtD0';
    private static final Id TemplateIdT30 = '00X50000001ZtD1';
    private static final Id TemplateIdT60 = '00X50000001ZtD2';
    private static final Id TemplateIdT90 = '00X50000001ZtD3';
    private static final Id FromAddressId = '0D2500000004CZL';
    private static final Date customDate = Date.newInstance(2015, 09, 18);
    private static final List<Id> ExclusionIds = new List<Id> { '0015000000cQ9H6', '00130000007mEjX' };  //exclude silver-peak account
    
    private Integer emailsSentCount = 0;
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new SubscriptionExpirationReminderJob(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        
        List<Date> expirationDates = new List<Date> { customDate.addDays(-30), customDate, customDate.addDays(30), customDate.addDays(60), customDate.addDays(90) };
        return Database.getQueryLocator([select Id from Contact where Id in (select ContactId from Asset where Opt_Out_Subscription_Reminder__c=false and Hosted_GMS__c=false and Product2.Family='Virtual Image' and Status!='Customer Evaluation' and Product2.Product_Category__c='Subscription' and License_End_Date__c in :expirationDates)]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        System.debug('scope' + scope);
        System.debug('Custom Date' + customDate);
        Set<Id> contactsT_30 = new Set<Id>(), contactsT0 = new Set<Id>(), contactsT30 = new Set<Id>(), contactsT60 = new Set<Id>(), contactsT90 = new Set<Id>();
        List<Id> accountIds = new List<Id>();
        Map<Id, Set<Id>> contact2Account = new Map<Id, Set<Id>>();
        Map<Id, String> userEmails = new Map<Id, String>();
        List<Date> expirationDates = new List<Date> { customDate.addDays(-30), customDate, customDate.addDays(30), customDate.addDays(60), customDate.addDays(90) };
        for(Asset asset : [select Id, AccountId, ContactId, License_End_Date__c, Contact.Owner.Email from Asset where Opt_Out_Subscription_Reminder__c=false and Hosted_GMS__c=false and Product2.Family='Virtual Image' and Status!='Customer Evaluation' and Product2.Product_Category__c='Subscription' and License_End_Date__c in :expirationDates and ContactId in :scope and AccountId not in :ExclusionIds])
        {
           
            accountIds.add(asset.AccountId);
            if(!contact2Account.containsKey(asset.ContactId))
            {
                contact2Account.put(asset.ContactId, new Set<Id>());
            }
            contact2Account.get(asset.ContactId).add(asset.AccountId);
            userEmails.put(asset.ContactId, asset.Contact.Owner.Email);
            if(asset.License_End_Date__c == customDate.adddays(-30))
            {
                contactsT_30.add(asset.ContactId);
            }
            else if(asset.License_End_Date__c == customDate)
            {
                contactsT0.add(asset.ContactId);
            }
            else if(asset.License_End_Date__c == customDate.adddays(30))
            {
                contactsT30.add(asset.ContactId);
            }
            else if(asset.License_End_Date__c == customDate.adddays(60))
            {
                contactsT60.add(asset.ContactId);
            }
            else if(asset.License_End_Date__c == customDate.adddays(90))
            {
                contactsT90.add(asset.ContactId);
            }
        }
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
                    emails.add(getEmailMessage(contactId, accountId, TemplateIdT_30, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                }
            }
            for(Id contactId : contactsT0)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    emails.add(getEmailMessage(contactId, accountId, TemplateIdT0, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                }
            }
            for(Id contactId : contactsT30)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    emails.add(getEmailMessage(contactId, accountId, TemplateIdT30, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                }
            }
            for(Id contactId : contactsT60)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    emails.add(getEmailMessage(contactId, accountId, TemplateIdT60, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                }
            }
            for(Id contactId : contactsT90)
            {
                for(Id accountId : contact2Account.get(contactId))
                {
                    emails.add(getEmailMessage(contactId, accountId, TemplateIdT90, getCcEmails(contactId, userEmails, accountId, teamMemberEmails)));
                }
            }
            if(emails.size() > 0)
            {
                System.debug('Emails size'+ emails.size());
                Messaging.sendEmail(emails, false);
                emailsSentCount += emails.size();
            }
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        insert new ErrorLog__c(Subject__c='Subscription Expiration Reminder', Message__c='Sent ' + emailsSentCount + ' emails.');
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
    
    private Messaging.SingleEmailMessage getEmailMessage(Id recipientId, Id whatId, Id templateId, List<String> ccEmails)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(recipientId);
        email.setWhatId(whatId);
        email.setTemplateId(templateId);
        email.setOrgWideEmailAddressId(FromAddressId);
        email.setSaveAsActivity(false);
        ccEmails.add('notifications@silver-peak.com');
        email.setCcAddresses(ccEmails);
        return email;
    } 
}