@isTest
private class PartnerPortalSSOControllerTest 
{	
	@isTest 
	static void testPartnerPortalSSOController() 
	{
		Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
		PartnerPortalSSOController controller = new PartnerPortalSSOController();
		controller.redirect();
	}
}