@IsTest
public class PartnerPortalGetCourseCertificateApiTest {
    @IsTest
static void testPartnerPortalGetCourseCertificateApiTest() 
  {
    Test.setMock(HttpCalloutMock.class, new LMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
    PartnerPortalGetCourseCertificateApi api = new PartnerPortalGetCourseCertificateApi('2368423', '153338','xxxxxxx');
    api.execute();
  }
}