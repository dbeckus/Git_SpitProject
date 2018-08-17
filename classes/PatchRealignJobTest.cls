@isTest
public class PatchRealignJobTest
{
    @isTest
    static void test()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true);
        insert patch;
        Lead lead = new Lead(LastName='acme', Company='acme', Patch__c=patch.Id);
        insert lead;
        
        Test.startTest();
        PatchRealignJob job = new PatchRealignJob(new List<Id> {patch.Id});
        Database.executeBatch(job, 1);
        Test.stopTest();
    }  
    
    @isTest(SeeAllData=True)
    static void InReviewAccount()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true);
        insert patch;
        Account acc = new Account(Name='Test InReview Account', Type='In Review');
        insert acc;
        
        Test.startTest();
        PatchRealignJob job = new PatchRealignJob(new List<Id> {patch.Id});
        Database.executeBatch(job, 1);
        Test.stopTest();
        Account acc1= [Select Trigger_Assignment__c, Patch__c from Account where Id =:acc.Id];
        system.assertEquals(False, acc1.Trigger_Assignment__c); 
        system.assertEquals(Null, acc1.Patch__c);
    }
    
    @isTest(SeeAllData=True)
    static void NotInReviewAccount()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true, ProcessingSequence__c=5000);
        insert patch;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch.Id, Type__c='State', Operation__c='equals', Value__c='MLKTest', ProcessingSequence__c=1);
        insert rule1;
        Account acc = new Account(Name='Test InReview Account', Type='Customer', Patch__c=patch.Id);
        insert acc;
        
        Test.startTest();
        PatchRealignJob job = new PatchRealignJob(new List<Id> {patch.Id});
        Database.executeBatch(job, 1);
        Test.stopTest();
        Account acc1= [Select Trigger_Assignment__c, Patch__c from Account where Id =:acc.Id];
        Patch__c p= [Select Id from Patch__c where Name='P-480'];
        system.assertEquals(False, acc1.Trigger_Assignment__c); 
        system.assertEquals(p.Id, acc1.Patch__c);
    }
    
    @isTest(SeeAllData=True)
    static void OpportunityTest()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true, ProcessingSequence__c=5000);
        insert patch;
        PatchCriteriaRule__c rule1 = new PatchCriteriaRule__c(Patch__c=patch.Id, Type__c='State', Operation__c='equals', Value__c='MLKTest', ProcessingSequence__c=1);
        insert rule1;
        Account acc = new Account(Name='Test Account', Type='Customer', Patch__c=patch.Id);
        insert acc;
        Opportunity opp = new Opportunity(Name='Test Opportunity', AccountId=acc.Id,StageName='Discovery', CloseDate=Date.today(), Patch__c=patch.Id);
        insert opp;
        
        Test.startTest();
        PatchRealignJob job = new PatchRealignJob(new List<Id> {patch.Id});
        Database.executeBatch(job, 1);
        Test.stopTest();
        Opportunity o= [Select Patch__c from Opportunity where Id =:opp.Id];
        Patch__c p= [Select Id from Patch__c where Name='P-480'];
        system.assertEquals(p.Id, o.Patch__c);
    }
}