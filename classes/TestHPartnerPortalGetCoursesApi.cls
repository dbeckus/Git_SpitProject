@IsTest
private class TestHPartnerPortalGetCoursesApi {
 @isTest 
    static void testPartnerPortalGetCoursesApi() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetCoursesApi api = new HPartnerPortalGetCoursesApi('xxxxx');
        api.execute();
    }
}