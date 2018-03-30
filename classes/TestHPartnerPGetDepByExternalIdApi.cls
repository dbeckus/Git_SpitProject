@IsTest
public class TestHPartnerPGetDepByExternalIdApi {
    @isTest 
    static void TestPartnerPortalGetDepartmentsByExtIdApi() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetDepartmentsByExtIdApi api = new HPartnerPortalGetDepartmentsByExtIdApi('20323023','xxxxx');
        api.execute();
    }
    
    
}