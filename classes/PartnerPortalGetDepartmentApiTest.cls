@isTest
private class PartnerPortalGetDepartmentApiTest 
{	
	@isTest 
	static void testPartnerPortalGetDepartmentApi() 
	{
		Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
		PartnerPortalGetDepartmentApi api = new PartnerPortalGetDepartmentApi('aaaa','xxxxx');
		api.execute();
	}
}