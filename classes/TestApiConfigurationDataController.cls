@IsTest
public class TestApiConfigurationDataController {
    @IsTest
    public static void TestData()
    {
        Api_Configuration__c api= new Api_Configuration__c();
        api.Environment_Name__c='Test';
        api.UserName__c='Test@test.com';
        api.Endpoint_URL__c='http://test.test.com';
        api.Password__c='test';
        insert api;
        Api_Configuration__c obj=ApiConfigurationDataController.RetreiveApiCredentials('Test');
        System.assert(obj!=null);
        
        
    }
  	 @IsTest
    public static void TestData_Nodata()
    {
        Api_Configuration__c obj=ApiConfigurationDataController.RetreiveApiCredentials('Test');
        System.assert(obj==null);
        
        
    }
}