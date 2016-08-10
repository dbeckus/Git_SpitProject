/*
 * copies Campaign's Type to Lead's Last_Campaign_Type__c
 * as well as sponsoring partner
 */
trigger CopyCampaignTypeToLead on CampaignMember (after insert) 
{
    Map<Id, Id> lead2Campaign = new Map<Id, Id>();
    Id sdCampaign = SalesDevelopmentHelper.getSDCampaign();
    for(CampaignMember campaignMember : Trigger.new)
    {
        if(campaignMember.LeadId != null && campaignMember.CampaignId != sdCampaign)
        {
            lead2Campaign.put(campaignMember.LeadId, campaignMember.CampaignId);
        }
    }
    
    Map<Id, String> campaignId2Type = new Map<Id, String>();
    Map<Id, String> campaignId2Name = new Map<Id, String>();
    Map<Id, Id> campaignId2Sponsor = new Map<Id, Id>();
    Set<Id> doNotTeleQualifyCampaigns = new Set<Id>();
    for(Campaign campaign : [select Id, Name, Type, Sponsoring_Partner__c, Do_Not_Tele_Qualify__c from Campaign where Id in :lead2Campaign.values()])
    {
        campaignId2Type.put(campaign.Id, campaign.Type);
        campaignId2Name.put(campaign.Id, campaign.Name);
        campaignId2Sponsor.put(campaign.Id, campaign.Sponsoring_Partner__c);
        if(campaign.Do_Not_Tele_Qualify__c)
        {
            doNotTeleQualifyCampaigns.add(campaign.Id);
        }
    }
    
    List<Lead> leads = new List<Lead>();
    for(String leadId : lead2Campaign.keySet())
    {
        Id campaignId = lead2Campaign.get(leadId);
        Lead newLead = new Lead(Id = leadId, 
                           Last_Campaign_Type__c = campaignId2Type.get(campaignId), 
                           Last_Campaign_Date__c = System.today(), 
                           Last_Mkt_Campaign_Id__c = campaignId, 
                           Last_Mkt_Campaign__c = campaignId2Name.get(campaignId),
                           Sponsoring_Partner__c = campaignId2Sponsor.get(campaignId));
        if(doNotTeleQualifyCampaigns.contains(campaignId))
        {
            newLead.Do_Not_Tele_Qualify__c = true;
        }
        leads.add(newLead);
    }
    if(leads.size() > 0)
    {
        try
        {
            SilverPeakUtils.BypassingTriggers = true;
            update leads;
            SilverPeakUtils.BypassingTriggers = false;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
    
    leads.clear();
    for(Lead lead : [select Last_Mkt_Campaign__c, MrktCampHist__c from Lead where Id in :lead2Campaign.keySet()])
    {
        if(lead.MrktCampHist__c != null)
        {
            lead.MrktCampHist__c = lead.Last_Mkt_Campaign__c + '\n' + lead.MrktCampHist__c;
        }
        else
        {
            lead.MrktCampHist__c = lead.Last_Mkt_Campaign__c;
        }
        leads.add(lead);
    }
    if(leads.size() > 0)
    {
        try
        {
            SilverPeakUtils.BypassingTriggers = true;
            update leads;
            SilverPeakUtils.BypassingTriggers = false;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
}