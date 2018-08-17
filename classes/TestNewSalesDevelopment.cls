@isTest
public class TestNewSalesDevelopment
{
    @isTest
    static void testRetrieve()
    {
       
        Campaign c = new Campaign(Name='acme', Sales_Targeting__c=true);
        insert c;
        Campaign salesCamp = new Campaign(Name='Sales Development', Sales_Targeting__c=true);
        insert salesCamp;
        Lead l = new Lead(LastName='acme', Company='acme',Lifecycle_Stage__c='AQL');
        insert l;
        Contact con = new Contact(LastName='acme',Lifecycle_Stage__c='AQL');
        insert con;
        CampaignMember member = new CampaignMember(CampaignId=c.Id, LeadId=l.Id, Status='Sent');
        insert member;
         Test.startTest();
        NewSalesDevelopmentController controller  = new NewSalesDevelopmentController();
        controller.LifeCycleStage='AQL';
        controller.ListView='';
        System.assertEquals(1, controller.PageOptions.size());
        controller.refreshZero();
        controller.previousPage();
        controller.nextPage();
        Test.stopTest();
    }
    
    @isTest
    static void testUpdate()
    {
       
        Campaign c = new Campaign(Name='acme', Sales_Targeting__c=true);
        insert c;
        Campaign salesCamp = new Campaign(Name='Sales Development', Sales_Targeting__c=true);
        insert salesCamp;
        Lead l = new Lead(LastName='acme', Company='acme',Lifecycle_Stage__c='TAL');
        insert l;
        Contact con = new Contact(LastName='acme',Lifecycle_Stage__c='TAL');
        insert con;
        CampaignMember member = new CampaignMember(CampaignId=c.Id, LeadId=l.Id, Status='Sent');
        insert member;
         Test.startTest();
        NewSalesDevelopmentController controller  = new NewSalesDevelopmentController();
        controller.LifeCycleStage='TAL';
        controller.ListView='';
        controller.SelectedIds = l.Id;
        controller.updateStatus();
        
        controller.SelectedIds = l.Id;
        controller.updateOwner();
        
        controller.SelectedIds = l.Id;
        controller.removeFromCampaign();
        Test.stopTest();
    }
}