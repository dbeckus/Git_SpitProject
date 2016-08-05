@isTest
private class PartnerPortalControllerTest 
{	
	@isTest 
	static void testPartnerPortalController() 
	{
		PartnerPortalController controller = new PartnerPortalController();
		System.debug(controller.IsAuthorized);
	}
}