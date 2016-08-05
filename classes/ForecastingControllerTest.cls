@isTest
public class ForecastingControllerTest
{
    @isTest
    static void test()
    {
        PageReference ref = new PageReference('/apex/forecasting?quarter=2014Q4');
        Test.setCurrentPage(ref);
        ForecastingController controller = new ForecastingController();
        System.assert(controller.CurrentUser != null);
        System.assertEquals('2014Q3', controller.PreviousFiscalQuarter);
        System.assertEquals('2015Q1', controller.NextFiscalQuarter);
        String path = controller.Path;
        System.assert(controller.CurrentViewingUser != null);
        System.assert(controller.ForecastingHistory != null);
        
        System.assert(ForecastingController.getDirectSubordinateUsers(UserInfo.getUserid()) != null);
        System.assert(ForecastingController.getAllSubordinateUsers(UserInfo.getUserid()) != null);
        
        ForecastingController.ForecastEntry entry = new ForecastingController.ForecastEntry();
        entry.type = 'Quota';
        entry.nbValue = 100;
        entry.foValue = 100;
        entry.mrValue = 100;
        ForecastingController.saveForecast(UserInfo.getUserId(), '2014Q4', entry);
    }
}