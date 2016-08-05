@isTest
public class LeadControllerTest
{
    @isTest static void test()
    {
        DynamicLayout__c layout = new DynamicLayout__c(Name='default', Object__c='Lead');
        insert layout;
        DynamicLayoutElement__c element1 = new DynamicLayoutElement__c(Name='e1', LayoutNumber__c='default', Type__c='Section', FieldSet__c='acme', SectionColumns__c=2, SectionName__c='Info', Sequence__c=1);
        DynamicLayoutElement__c element2 = new DynamicLayoutElement__c(Name='e2', LayoutNumber__c='default', Type__c='Button', ButtonLabel__c='Edit', ButtonName__c='LeadEdit', Sequence__c=1);
        DynamicLayoutElement__c element3 = new DynamicLayoutElement__c(Name='e3', LayoutNumber__c='default', Type__c='RelatedList', ChildObject__c='Quote__c', ChildObjectLabel__c='Quotes', RelatedField__c='Opportunity__c', Sequence__c=1);
        insert new List<DynamicLayoutElement__c> { element1, element2, element3 };
        
        Test.startTest();
        
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        
        LeadController controller = new LeadController(new ApexPages.StandardController(ld));
        System.assertEquals(true, controller.IsEditable);
        System.assert(controller.PageLayout != null);
        LeadController.LayoutInfo layoutInfo = controller.PageLayout;
        String buttons = controller.ButtonDefinitions;
        System.assert(controller.PredefinedButtons != null);
        System.assert(controller.PredefinedInlineEditingFields != null);
        System.assert(controller.PredefinedReadOnlyFields != null);
        System.assert(controller.CampaignContacts != null);
        controller.save();
        Test.stoPTest();
    }
}