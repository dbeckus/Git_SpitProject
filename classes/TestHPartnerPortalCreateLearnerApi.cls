@IsTest
public class TestHPartnerPortalCreateLearnerApi {
    @IsTest
    static void test()
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('username', 'Test');
        studentParams.put('firstName', 'Test');
        studentParams.put('lastName', 'Test');
        studentParams.put('JobTitle', 'Test');
        studentParams.put('emailAddress','Test');
        studentParams.put('departmentId', 'Test');
        studentParams.put('location', 'Test');
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalCreateLearnerApi  api = new HPartnerPortalCreateLearnerApi ('xxxxx',studentParams);
        api.execute();
    }
}