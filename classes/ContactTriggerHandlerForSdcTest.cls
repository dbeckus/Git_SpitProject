@isTest
public class ContactTriggerHandlerForSdcTest
{
    @isTest
    static void test()
    {
        TriggerHandlerSetting__c ths = new TriggerHandlerSetting__c(Name='1', SObjectType__c='Contact', Handler__c='ContactTriggerHandlerForSDC');
        insert ths;
        
        Test.startTest();
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.id);
        insert ct;
        
        ct.Lead_Lifecycle_Stage__c='03 MQL';
        update ct;
        
        ct.Lead_Lifecycle_Stage__c = 'Rejected';
        update ct;
        Test.stopTest();
    }
}