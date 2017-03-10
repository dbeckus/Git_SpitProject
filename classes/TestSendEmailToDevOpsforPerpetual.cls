@IsTest
public class TestSendEmailToDevOpsforPerpetual {
    @IsTest
    public static void TestData()
    {
        Account acc= new Account(Name='Test Data',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual-Orchestrator SP',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='test',Service_Provider_Location__c='EU (London)');
        insert acc;
        acc.Cloud_Portal_Account_Id__c='test';
        acc.Cloud_Portal_Account_Key__c='test';
        acc.Cloud_Portal_Account_Name__c='test';
        update acc;
    }

}