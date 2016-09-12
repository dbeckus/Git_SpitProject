@IsTest
private class TestHPartnerPortalGetEnrolDetailsApi {
    
    @IsTest
    static void TestPartnerPortalGetEnrolDetailsApi()
    {
         Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetEnrollementDetailsApi api = new HPartnerPortalGetEnrollementDetailsApi('01p3B000000Ea8s','xxxxx');
        api.execute();
    }

}