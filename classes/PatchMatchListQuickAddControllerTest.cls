@isTest
public class PatchMatchListQuickAddControllerTest
{
    @isTest
    static void test()
    {
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true);
        insert patch;
        PatchCriteriaRule__c rule = new PatchCriteriaRule__c(Patch__c=patch.Id);
        insert rule;
        
        PageReference ref = Page.PatchMatchListQuickAdd;
        ref.getParameters().put('ruleId', rule.Id);
        Test.setCurrentPage(ref);
        PatchMatchListQuickAddController controller = new PatchMatchListQuickAddController();
        controller.Values = '1, 2, 3';
        controller.save();
        
        System.assertEquals(3, [select count() from PatchMatchList__c where Patch_Criteria_Rule__c=:rule.Id]);
    }
}