@IsTest
private class TestHPartnerPortalGetUserDetailsApi {
    
    @IsTest
    static void testPartnerPortalGetStudentsApi()
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetUserDetailsApi api = new HPartnerPortalGetUserDetailsApi('xxxxx','01p3B000000Ea8s');
        api.execute();
    }

}