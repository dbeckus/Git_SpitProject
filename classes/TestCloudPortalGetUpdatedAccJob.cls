@IsTest
public class TestCloudPortalGetUpdatedAccJob {
@IsTest
    public static void TestBatchGetAccNameAndKey()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898');
        insert acc;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalGetUpdatedAccountsJob obj= new CloudPortalGetUpdatedAccountsJob();
        Database.executeBatch(obj);
        Test.stopTest();
    }
   
}