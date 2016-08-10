@isTest
private class PartnerPortalCreateDepartmentApiTest 
{	
	@isTest 
	static void testPartnerPortalCreateDepartmentApi() 
	{
		Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
		Map<String, String> params = new Map<String, String>();
		params.put('token', 'xxxxxx');
		PartnerPortalCreateDepartmentApi api = new PartnerPortalCreateDepartmentApi(params);
		api.execute();
	}	
}