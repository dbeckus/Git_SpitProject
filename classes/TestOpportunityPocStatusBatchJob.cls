@isTest
public class TestOpportunityPocStatusBatchJob {
    @isTest
    public  static void test()
    {
        Account acct = new Account(Name = 'Acme');
        insert acct;
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2006,10,10),AccountId = acct.Id);
        insert opp;
        Request__c poc = new Request__c( Opportunity__c = opp.Id, Status__c = 'Shipped');
        insert poc;
        Opportunity newOpp = [select Id,Has_Active_POCs__c from Opportunity where Id =: opp.Id];
        newOpp.Has_Active_POCs__c = false;
        update newOpp;
        Account newAcct = [select Id, Has_Active_POCs__c from Account where Id =: acct.Id];
        newAcct.Has_Active_POCs__c = false;
        update newAcct;
        Test.startTest();
        OpportunityPocStatusBatchJob opsb = new OpportunityPocStatusBatchJob();
        Database.executeBatch(opsb);
        Test.stopTest();
        Opportunity newOpp1 = [select Id,Has_Active_POCs__c from Opportunity where Id =: opp.Id];
        Account newAcct1 = [select Id, Has_Active_POCs__c from Account where Id =: acct.Id];
        system.assertEquals(true, newOpp1.Has_Active_POCs__c);
        system.assertEquals(true, newAcct1.Has_Active_POCs__c);        
    }
}