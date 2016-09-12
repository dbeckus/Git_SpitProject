@IsTest
private class TestHPartnerPortalGetDepartmentsApi {
 @isTest 
    static void TestPartnerPortalGetDepartmentsApi() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetDepartmentsApi api = new HPartnerPortalGetDepartmentsApi('20323023','xxxxx');
        api.execute();
    }
}