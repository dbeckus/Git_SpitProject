@isTest
public class PatchRealignControllerTest
{
    @isTest
    static void test()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true, Owner__c=UserInfo.getUserId(), RSM__c=UserInfo.getUserId());
        insert patch;
        Account acc = new Account(Name='acme', Patch__c=patch.Id);
        insert acc;
        acc = [select Id, Patch__c from Account where Id=:acc.Id limit 1];
        System.assertEquals(patch.Id, acc.Patch__c);
        
        PageReference ref = new PageReference('/apex/PageRealign?id=' + patch.Id);
        Test.setCurrentPage(ref);
        PatchRealignController controller = new PatchRealignController();
        controller.init();
        controller.startProcess();
        controller.abortProcess();
    }
}