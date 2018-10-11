@IsTest
public class TestCloudPortalGetUpdatedAccJob {
@IsTest
    public static void TestBatchGetAccNameAndKey()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898',Cloud_Portal_Account_Key__c='934932849343');
        insert acc;
        Api_Configuration__c apicOnfig= new Api_Configuration__c(Base_Endpoint__c='https://portaleng.silverpeaksystems.net/portal',Endpoint_URL__c='https://portaleng.silverpeaksystems.net/portal/apis/rest',Environment_Name__c='Cloud Portal Testing',UserName__c='abc@silver-peak.com',Password__c='test');
        insert apicOnfig;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalGetUpdatedAccountsJob obj= new CloudPortalGetUpdatedAccountsJob();
        Database.executeBatch(obj);
        Test.stopTest();
    }
   
}