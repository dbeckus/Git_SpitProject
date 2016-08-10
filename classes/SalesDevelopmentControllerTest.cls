@isTest
public class SalesDevelopmentControllerTest
{
    @isTest
    static void testRetrieve()
    {
        Campaign c = new Campaign(Name='acme', Sales_Targeting__c=true);
        insert c;
        Lead l = new Lead(LastName='acme', Company='acme');
        insert l;
        CampaignMember member = new CampaignMember(CampaignId=c.Id, LeadId=l.Id, Status='Sent');
        insert member;
        
        SalesDevelopmentController controller  = new SalesDevelopmentController();
        System.assertEquals(1, controller.PageOptions.size());
        controller.refreshZero();
        controller.previousPage();
        controller.nextPage();
    }
    
    @isTest
    static void testUpdate()
    {
        Campaign c = new Campaign(Name='acme', Sales_Targeting__c=true);
        insert c;
        Lead l = new Lead(LastName='acme', Company='acme');
        insert l;
        CampaignMember member = new CampaignMember(CampaignId=c.Id, LeadId=l.Id, Status='Sent');
        insert member;
        
        SalesDevelopmentController controller  = new SalesDevelopmentController();
        
        controller.SelectedIds = l.Id;
        controller.updateStatus();
        
        controller.SelectedIds = l.Id;
        controller.updateOwner();
        
        controller.SelectedIds = l.Id;
        controller.removeFromCampaign();
    }
}