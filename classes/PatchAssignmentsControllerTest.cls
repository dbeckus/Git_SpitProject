@isTest
public class PatchAssignmentsControllerTest
{
    @isTest
    static void testMyTeamLeads()
    {
        Lead ld = new Lead(LastName='acme', Company='acme', Status='Marketing Nurturing');
        insert ld;
        ld.RSM__c = UserInfo.getUserId();
        update ld;
        
        PatchAssignmentsController controller = new PatchAssignmentsController();
        controller.Bucket = 'Marketing';
        List<PatchAssignmentsController.LeadInfo> result = controller.LeadList;
        System.assert(result.size() > 0);
        
        PageReference ref = Page.PatchAssignments;
        Test.setCurrentPage(ref);
        ref.getParameters().put('orderBy', 'Company');
        PatchAssignmentsController controller2 = new PatchAssignmentsController();
        controller2.Keyword = 'acme';
        result = controller2.LeadList;
    }
    
    @isTest
    static void testCatchall()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', RSM__c=UserInfo.getUserId(), Active__c=true, Catchall__c=true);
        insert patch;
        Lead ld = new Lead(LastName='acme', Company='acme', Status='Marketing Nurturing', Patch__c=patch.Id);
        insert ld;
        ld.RSM__c = UserInfo.getUserId();
        update ld;
        
        PatchAssignmentsController controller = new PatchAssignmentsController();
        Set<String> statuses = controller.getLeadStatuses();
        System.assert(statuses.size() > 0);
        System.assert(controller.CatchallList.size() > 0);
        
        controller.Bucket = 'Marketing';
        controller.Catchall = patch.Id;
        List<PatchAssignmentsController.LeadInfo> result = controller.LeadList;
        System.assert(result.size() > 0);
    }
}