@isTest
public class PartnerPortalDealSearchControllerTest
{
    @isTest
    static void test()
    {
        PartnerPortalDealSearchController controller = new PartnerPortalDealSearchController();
        controller.partnerPortalSearchLeadsInit();
        controller.partnerPortalSearchDealsInit();
    }
}