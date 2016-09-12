@IsTest
private class TestHPartnerPortalGetDepartmentApi {
 @isTest 
    static void TestPartnerPortalGetDepartmentApi() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetDepartmentApi api = new HPartnerPortalGetDepartmentApi('20323023','xxxxx');
        api.execute();
    }
}