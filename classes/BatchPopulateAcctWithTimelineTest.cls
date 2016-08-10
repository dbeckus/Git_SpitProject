@isTest
private class BatchPopulateAcctWithTimelineTest
{
    @isTest
    static void testAcctTimeLines()
    {
        AccountWithTimeline__c acct = new AccountWithTimeline__c(Name = 'acme');
        acct.Total_Sales__c =13212342343.80;
        acct.Name__c = '0015000000Z7KhmAAF';
        acct.First_Order__c = Date.today();
        acct.Last_Order_Date__c = Date.today().addDays(90);
        acct.First_Order_Amt__c =123.80;
        acct.Ninety_Days_Total__c =1234.80;        
        acct.First_Year_Total__c = 234214.80;
        acct.Last_Order_Amt__c = 422.80;
        insert acct;  
        
        Account accAcme = new Account(Name = 'Acme');
        Account accTest = new Account(Name = 'Test');
        Account accPeak = new Account(Name = 'Peak');
        List<Account> accounts = new List<Account>{accAcme, accTest, accPeak};
        insert accounts;
        
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity opp = new Opportunity(AccountId = accAcme.Id, StageName = 'Closed Won', Finance_Reviewed__c = true, Amount = 9, Name = 'Acme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme OppAcme Opp', CloseDate = Date.today());
        Opportunity opp1 = new Opportunity(AccountId = accAcme.Id, StageName = 'Closed Won', Finance_Reviewed__c = true, Amount = 99, Name = 'Acme Opp', CloseDate = Date.today());
        Opportunity opp2 = new Opportunity(AccountId = accTest.Id, StageName = 'Closed Won', Finance_Reviewed__c = true, Name = 'Acme Opp', CloseDate = Date.today());
        opps.add(opp);
        opps.add(opp1);
        opps.add(opp2);
        insert opps;
        
        Test.startTest();
        BatchPopulateAcctWithTimeline batchJob = new BatchPopulateAcctWithTimeline();
        Database.executeBatch(batchJob);
        Test.stopTest();
    }
}