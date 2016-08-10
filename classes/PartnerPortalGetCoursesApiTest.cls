@isTest
private class PartnerPortalGetCoursesApiTest 
{	
	@isTest 
	static void testPartnerPortalGetCoursesApi() 
	{
		Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
		PartnerPortalGetCoursesApi api = new PartnerPortalGetCoursesApi('xxxxx');
		api.execute();
	}	
}