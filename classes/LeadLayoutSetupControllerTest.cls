@isTest
public class LeadLayoutSetupControllerTest
{
    @isTest static void test()
    {
        LeadLayoutSetupController controller = new LeadLayoutSetupController();
        controller.init();
        controller.Buttons[0].Lead.OutSideSales.IsChecked = true;
        controller.save();
        
        System.assertEquals(1, [select count() from DynamicLayoutElement__c]);
    }
}