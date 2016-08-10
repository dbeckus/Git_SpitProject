@isTest
public class PartnerPortalRegistrationControllerTest
{
    @isTest
    static void test()
    {
        PartnerPortalRegistrationController controller = new PartnerPortalRegistrationController();
        System.assert(controller.goToMarketSalesModelItem != null);
        System.assert(controller.goToMarketSalesModelItemSetGet != null);
        System.assert(controller.marketingSegmentsServedItem != null);
        System.assert(controller.marketingSegmentsServedSetGet != null);
        System.assert(controller.productCategoriesSoldItem != null);
        System.assert(controller.productCategoriesSoldSetGet != null);
        System.assert(controller.silverPeakProductsSoldItem != null);
        System.assert(controller.silverPeakProductsSoldSetGet != null);
        System.assert(controller.applicationsItem != null);
        System.assert(controller.applicationsSetGet != null);
        System.assert(controller.silverPeakCompetenciesItem != null);
        System.assert(controller.silverPeakCompetenciesSetGet != null);
        System.assert(controller.professionalServicesOfferedItem != null);
        System.assert(controller.professionalServicesOfferedSetGet != null);
        System.assert(controller.channelProgramsParticipatedItem != null);
        System.assert(controller.channelProgramsParticipatedSetGet != null);
        System.assert(controller.branchOfficeTypeItem != null);
        System.assert(controller.branchOfficeTypeSetGet != null);
        System.assert(controller.distributionPartners != null);
        controller.savePage5();
    }
}