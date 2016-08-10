@isTest
public class PatchOverrideControllerTest
{
    @isTest
    static void test()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        PageReference ref = new PageReference('/apex/PatchOverride?id=' + ld.Id);
        Test.setCurrentPage(ref);
        PatchOverrideController controller = new PatchOverrideController();
        controller.reassign();
    }
}