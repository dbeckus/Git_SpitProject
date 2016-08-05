@isTest
public class LeadTriggerHandlerForSdcTest
{
    @isTest
    static void test()
    {
        TriggerHandlerSetting__c ths = new TriggerHandlerSetting__c(Name='1', SObjectType__c='Lead', Handler__c='LeadTriggerHandlerForSDC');
        insert ths;
        
        Test.startTest();
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        ld.Lead_Lifecycle_Stage__c='03 MQL';
        update ld;
        
        ld.Lead_Lifecycle_Stage__c = 'Rejected';
        update ld;
        
        Lead ld2 = new Lead(LastName='acme', Company='acme', Lead_Lifecycle_Stage__c='03 MQL');
        insert ld2;
        
        ld2.Status = 'Approved';
        update ld2;
                       
        Test.stopTest();
    }
}