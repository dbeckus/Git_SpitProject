@isTest
private class TestHPartnerPortalGetCertificatesApi {
    @isTest 
    static void testPartnerPortalGetCertificatesApi() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetCertificatesApi api = new HPartnerPortalGetCertificatesApi('cccc', 'xxxxx',null);
        api.execute();
    }

}