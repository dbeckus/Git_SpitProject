@isTest
public class OpportunityLayoutPreviewControllerTest
{
    @isTest static void test()
    {
        OpportunityLayoutPreviewController controller = new OpportunityLayoutPreviewController(new ApexPages.StandardController(new Opportunity()));
        List<SelectOption> ps = controller.allSalesProcesses;
        List<SelectOption> gs = controller.allStageGroupings;
        controller.SalesProcessToDisplay = 'Deleted';
        controller.StageToDisplay = 'Closed';
        controller.refresh();
    }
}