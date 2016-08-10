@isTest
private class PartnerPortalCreateLearnerApiTest 
{	
	@isTest 
	static void testPartnerPortalCreateLearnerApi() 
	{
		Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
		Map<String, String> params = new Map<String, String>();
		params.put('token', 'xxxxxx');
		PartnerPortalCreateLearnerApi api = new PartnerPortalCreateLearnerApi(params);
		api.execute();
	}
}