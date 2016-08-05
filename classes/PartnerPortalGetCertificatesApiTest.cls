@isTest
private class PartnerPortalGetCertificatesApiTest 
{
    @isTest 
    static void testPartnerPortalGetCertificatesApi() 
    {
        Test.setMock(HttpCalloutMock.class, new LMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        PartnerPortalGetCertificatesApi api = new PartnerPortalGetCertificatesApi('cccc', 'xxxxx',null);
        api.execute();
    }
}