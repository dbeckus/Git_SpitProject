@isTest
public class PartnerPortalIndividualRegControllerTest
{
    @isTest
    static void test()
    {
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.save();
    }
}