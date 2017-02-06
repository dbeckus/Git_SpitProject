@isTest
public class OpportunityControllerTest
{
    @isTest
    static void testEdit()
    {
        DynamicLayout__c layout0 = new DynamicLayout__c(Name='default 0', Object__c='Opportunity', LayoutSet__c='0');
        DynamicLayout__c layout1 = new DynamicLayout__c(Name='default 1', Object__c='Opportunity', LayoutSet__c='1');
        DynamicLayout__c layout2 = new DynamicLayout__c(Name='default 2', Object__c='Opportunity', LayoutSet__c='2');
        insert new List<DynamicLayout__c> { layout0, layout1, layout2 };
        
        DynamicLayoutElement__c element01 = new DynamicLayoutElement__c(Name='e1', LayoutNumber__c='default 0', Type__c='Section', FieldSet__c='acme', SectionColumns__c=2, SectionName__c='Info', Sequence__c=1);
        DynamicLayoutElement__c element02 = new DynamicLayoutElement__c(Name='e2', LayoutNumber__c='default 0', Type__c='Button', ButtonLabel__c='Edit', ButtonName__c='OpportunityEdit', Sequence__c=1);
        DynamicLayoutElement__c element03 = new DynamicLayoutElement__c(Name='e3', LayoutNumber__c='default 0', Type__c='RelatedList', ChildObject__c='Quote__c', ChildObjectLabel__c='Quotes', RelatedField__c='Opportunity__c', Sequence__c=1);
        DynamicLayoutElement__c element11 = new DynamicLayoutElement__c(Name='e4', LayoutNumber__c='default 1', Type__c='Section', FieldSet__c='acme', SectionColumns__c=2, SectionName__c='Info', Sequence__c=1);
        DynamicLayoutElement__c element12 = new DynamicLayoutElement__c(Name='e5', LayoutNumber__c='default 1', Type__c='Button', ButtonLabel__c='Edit', ButtonName__c='OpportunityEdit', Sequence__c=1);
        DynamicLayoutElement__c element13 = new DynamicLayoutElement__c(Name='e6', LayoutNumber__c='default 1', Type__c='RelatedList', ChildObject__c='Quote__c', ChildObjectLabel__c='Quotes', RelatedField__c='Opportunity__c', Sequence__c=1);
        DynamicLayoutElement__c element21 = new DynamicLayoutElement__c(Name='e7', LayoutNumber__c='default 2 ', Type__c='Section', FieldSet__c='acme', SectionColumns__c=2, SectionName__c='Info', Sequence__c=1);
        DynamicLayoutElement__c element22 = new DynamicLayoutElement__c(Name='e8', LayoutNumber__c='default 2', Type__c='Button', ButtonLabel__c='Edit', ButtonName__c='OpportunityEdit', Sequence__c=1);
        DynamicLayoutElement__c element23 = new DynamicLayoutElement__c(Name='e9', LayoutNumber__c='default 2', Type__c='RelatedList', ChildObject__c='Quote__c', ChildObjectLabel__c='Quotes', RelatedField__c='Opportunity__c', Sequence__c=1);
        insert new List<DynamicLayoutElement__c> { element01, element02, element03, element11, element12, element13, element21, element22, element23 };
        
        Test.startTest();
        
        Opportunity newOpp = new Opportunity(Name='acme', StageName='Qualified', CloseDate=Date.today());
        insert newOpp;
        
        OpportunityController controller = new OpportunityController(new ApexPages.standardController(newOpp));
        Boolean isAdmin = controller.IsAdmin;
        System.assertEquals(true, controller.IsEditable);
        controller.IsOverridable = true;
        controller.checkOverrideability();
        System.assert(controller.LayoutConfig != null);
        OpportunityController.LayoutInfo layoutInfo = controller.DynamicPageLayout;
        OpportunityController.RelatedListInfo relList = controller.FullList;
        String buttons = controller.ButtonDefinitions;
        System.assert(controller.PredefinedButtons != null);
        String pList = controller.PredefinedLists;
        String pFields = controller.PredefinedReadOnlyFields;
        String process = controller.getCurrentSalesProcess();
        String astages = controller.getCurrentStage();
        String sp = controller.Stage2Probability;
        controller.deleteChildObject();
        controller.save();
        OpportunityController.respondButtonClick('OpportunityEdit', newOpp.Id);
        
        Test.stopTest();
    }
}