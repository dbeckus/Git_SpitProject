@IsTest
public class PartnerPortalGetStudentInfoApiTest {
 @IsTest
static void testPartnerPortalGetStudentInfoApiTest() 
  {
    Test.setMock(HttpCalloutMock.class, new LMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
    PartnerPortalGetStudentInformationApi api = new PartnerPortalGetStudentInformationApi('153338','xxxxxxx');
    api.execute();
  }
}