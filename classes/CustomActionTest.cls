@isTest
public class CustomActionTest
{
    @isTest
    static void testOpportunity()
    {
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery');
        insert opp;
        
        CustomAction.OpportunityEdit a1 = new CustomAction.OpportunityEdit();
        a1.execute(null);
        
        CustomAction.OpportunityDelete a2 = new CustomAction.OpportunityDelete();
        a2.execute(null);
        
        CustomAction.OpportunityRenewal a3 = new CustomAction.OpportunityRenewal();
        a3.execute(null);
        
        CustomAction.OpportunityDefineChannel a4 = new CustomAction.OpportunityDefineChannel();
        a4.execute(null);
        
        CustomAction.OpportunityPatchLock a5 = new CustomAction.OpportunityPatchLock();
        a5.execute(opp.Id);
        
        CustomAction.OpportunityPatchUnlock a6 = new CustomAction.OpportunityPatchUnlock();
        a6.execute(opp.Id);
        
        CustomAction.OpportunityPatchOverride a7 = new CustomAction.OpportunityPatchOverride();
        a7.execute(null);
        
        CustomAction.OpportunityRevenueRecognitionChecklist a8 = new CustomAction.OpportunityRevenueRecognitionChecklist();
        a8.execute(null);
        
        CustomAction.OpportunityForwardLead a9 = new CustomAction.OpportunityForwardLead();
        a9.execute(null);
        
        CustomAction.OpportunityMerge a10 = new CustomAction.OpportunityMerge();
        a10.execute(null);
    }
    
    @isTest
    static void testLead()
    {
        Lead ld = new Lead(LastName='test', Company='test');
        insert ld;
        
        CustomAction.LeadEdit a1 = new CustomAction.LeadEdit();
        a1.execute(null);
        
        
        CustomAction.LeadClone a3 = new CustomAction.LeadClone();
        a3.execute(null);
        
        CustomAction.LeadConvert a4 = new CustomAction.LeadConvert();
        a4.execute(null);
        
        CustomAction.LeadMerge a5 = new CustomAction.LeadMerge();
        a5.execute(null);
        
        CustomAction.LeadDenyDealRegistration a6 = new CustomAction.LeadDenyDealRegistration();
        a6.execute(null);
        
        CustomAction.LeadRSMAccepted a7 = new CustomAction.LeadRSMAccepted();
        a7.execute(ld.Id);
        
        CustomAction.LeadRSMRejected a8 = new CustomAction.LeadRSMRejected();
        a8.execute(null);
        
        CustomAction.LeadISRQualified a9 = new CustomAction.LeadISRQualified();
        a9.execute(ld.Id);
        
        CustomAction.LeadISRRejected a10 = new CustomAction.LeadISRRejected();
        a10.execute(null);
        
        CustomAction.LeadPatchOverride a11 = new CustomAction.LeadPatchOverride();
        a11.execute(null);
        
        CustomAction.LeadPatchLock a12 = new CustomAction.LeadPatchLock();
        a12.execute(ld.Id);
        
        CustomAction.LeadPatchUnlock a13 = new CustomAction.LeadPatchUnlock();
        a13.execute(ld.Id);
        
        CustomAction.LeadDelete a2 = new CustomAction.LeadDelete();
        a2.execute(ld.Id);
    }
}