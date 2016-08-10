@isTest
public class LeadLayoutPreviewControllerTest
{
    @isTest static void test()
    {
        LeadLayoutPreviewController controller = new LeadLayoutPreviewController(new ApexPages.StandardController(new Lead()));
        List<SelectOption> rt = controller.allRecordTypes;
        List<SelectOption> rg = controller.allRoleGroupings;
        controller.RecordTypeToDisplay = 'Converted';
        controller.RoleGroupToDisplay = 'Outside Sales';
        controller.refresh();
    }
}