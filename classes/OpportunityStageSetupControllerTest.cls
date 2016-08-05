@isTest
public class OpportunityStageSetupControllerTest
{
    @isTest
    static void test()
    {
        OpportunityStageTransition__c transition = new OpportunityStageTransition__c(Name='T1', FromStage__c='Discovery', ToStage__c='Qualified');
        insert transition;
        
        OpportunityStageSetupController controller = new OpportunityStageSetupController();
        controller.init();
        controller.save();
        System.assertEquals(1, [select count() from OpportunityStageTransition__c]);
    }
}