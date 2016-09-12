@IsTest
private class TestHPartnerPortalCreateDepartment {
    @IsTest
    static void test()
    {
         Map<String, String> params = new Map<String, String>() ;
        params.put('name','test');
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        HPartnerPortalCreateDepartmentApi api = new HPartnerPortalCreateDepartmentApi('xxxxx',params);
        api.execute();
    }

}