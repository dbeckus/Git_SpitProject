@isTest
public class OpportunityLayoutSetupControllerTest
{
    @isTest
    static void test()
    {
        OpportunityLayoutSetupController controller = new OpportunityLayoutSetupController();
        controller.init();
        controller.Buttons[0].NewProcess.NewStage.IsChecked = true;
        controller.save();
        
        System.assertEquals(1, [select count() from DynamicLayoutElement__c]);
    }
}