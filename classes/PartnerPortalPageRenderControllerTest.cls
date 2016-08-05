@isTest
private class PartnerPortalPageRenderControllerTest 
{
	static 
	{
		ContentPage__c p = new ContentPage__c(Name='acme', VirtualPath__c='v', ActualUrl__c='a', Public__c=false);
        ContentPage__c p2 = new ContentPage__c(Name='acme2', VirtualPath__c='home', ActualUrl__c='a2', Public__c=false);
        insert new ContentPage__c[]{p, p2};
	}

	@isTest 
	static void testAuthenticatePage() 
	{
		PageReference contentPage = Page.PartnerPortalPageRender;
		contentPage.getParameters().put('name', 'home');
		Test.setCurrentPage(contentPage);
		PartnerPortalPageRenderController controller = new PartnerPortalPageRenderController();
		controller.authenticate();
		System.debug(controller.Title);
		System.debug(controller.PageContent);
	}
	
	@isTest 
	static void testUnauthenticatePage() 
	{
		User guestUser = [select Id from User where UserType = 'Guest' limit 1];
		System.runAs(guestUser)
		{
			PageReference contentPage = Page.PartnerPortalPageRender;
			contentPage.getParameters().put('name', 'v');
			Test.setCurrentPage(contentPage);
			PartnerPortalPageRenderController controller = new PartnerPortalPageRenderController();
			controller.authenticate();
		}
	}
	
}