@IsTest
public class TestHPartnerPortalGetStudentsApi {
    @IsTest
    static void testPartnerPortalGetStudentsApi()
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalGetStudentsApi api = new HPartnerPortalGetStudentsApi('xxxxx','prane@silver-peak.com');
        api.execute();
    }
    
}