@isTest
public class PartnerPortalDealRegControllerTest
{
    @isTest
    static void test()
    {
        PartnerPortalDealRegController controller = new PartnerPortalDealRegController();
        controller.Lead.FirstName = 'acme';
        controller.Lead.LastName = 'acme';
        controller.Lead.Company = 'acme';
        controller.submit();
    }
}