/*
 * Updates the SendingReminderEmail field to true when TargetEndDate on Requests is 10 days after today, or just today.
 * An email will be sent out with a workflow.
 */
global class PocRequestNotification implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        System.debug('POC Request Notiifcation started '+ Datetime.now());
        List<Request__c> requests = [select Id, Opportunity__c, Opportunity__r.Account.OwnerId from Request__c where ActiveForNotices__c = 1 and Target_End_Date__c=:Date.today().addDays(5)];
        if(requests!=null)
        {
            System.debug('POC Request Pending Expiring count '+ requests.size());
        }
        for(Request__c request : requests)
        {
            request.Sending_Reminder_Email__c = true;
        }
        Database.SaveResult[] results = Database.update(requests, false);
        SilverPeakUtils.logDatabaseError(requests, results);
        
        List<Request__c> requests2 = [select Id, Opportunity__c, Opportunity__r.Account.OwnerId from Request__c where ActiveForNotices__c = 1 and Target_End_Date__c=:Date.today()];
        if(requests2!=null)
        {
            System.debug('POC Request Expired count '+ requests2.size());
        }
        for(Request__c request : requests2)
        {
            request.Sending_Reminder_Email__c = true;
            request.Status__c = 'Pending Return';
        }
        Database.SaveResult[] results2 = Database.update(requests2, false);
        SilverPeakUtils.logDatabaseError(requests2, results2);
		System.debug('POC Request Notiifcation ended '+ Datetime.now());
        /*requests = [select Id, Opportunity__c, Opportunity__r.Account.OwnerId from Request__c where ActiveForNotices__c = 1 and Target_End_Date__c=:Date.today().addDays(1)];
        for(Request__c request : requests)
        {
            request.Sending_Reminder_Invitation__c = true;
        }
        try
        {
            update requests;
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }*/
    }
    
    @isTest
    static void testPocRequestNotification()
    {
        Account supportAccount = new Account(Name='EMAIL SUPPORT CONTACTS');
        insert supportAccount;
        Account account = new Account(Name='acme');
        insert account;
        Opportunity opp = new Opportunity(AccountId=account.Id, Name='test', StageName='Open', CloseDate=Date.today(), ForecastCategoryName='Pipeline');
        opp.Product_Type__c='Both';
        insert opp;
        Request__c request = new Request__c(Opportunity__c=opp.Id, Status__c='Shipped', Target_End_Date__c=Date.today());
        insert request;
        Test.startTest();
        PocRequestNotification notify = new PocRequestNotification();
        notify.execute(null);
        Test.stopTest();
    }
}