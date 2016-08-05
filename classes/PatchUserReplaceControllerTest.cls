@isTest
public class PatchUserReplaceControllerTest
{
    @isTest
    static void test()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true, RSM__c=UserInfo.getUserId(), ProcessingSequence__c=1);
        insert patch;
        
        PageReference ref = new PageReference('/apex/PatchUserReplace?uid=' + UserInfo.getUserId() + '&pid=' + patch.Id);
        Test.setCurrentPage(ref);
        PatchUserReplaceController controller = new PatchUserReplaceController();
        List<SelectOption> patches = controller.Patches;
        System.assertEquals(2, patches.size());
        controller.save();
    }
}