/*
 * helper class for sales development module.
 */
public class SalesDevelopmentHelper
{
    public static Id getSDcampaign()
    {
        if(SilverPeakUtils.IsProduction())
        {
            return '70150000000pcqE';     //production
        }
        else
        {
            List<Campaign> campaigns = [select Id from Campaign where Name = 'Sales Development'];
            if(campaigns.size() > 0)
            {
                return campaigns[0].Id;
            }
            else
            {
                return null;
            }
        }
    }
    
    public static Id getMPcampaign()
    {
        return null;
    }
    
    @future
    public static void willResetPrimaryCampaignSource(List<Id> oppIds)
    {
        ResetPrimaryCampaignSource(oppIds);
    }
    
    public static void ResetPrimaryCampaignSource(List<Id> oppIds)
    {
        Id sdCampaignId = getSDcampaign();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        List<Lead> leads = [select Id, ConvertedOpportunityId, (select Id, CampaignId from CampaignMembers where CampaignId!=:sdCampaignId order by CreatedDate desc limit 1) from Lead where ConvertedOpportunityId in :oppIds];
        for(Lead ld : leads)
        {
            for(CampaignMember cm : ld.CampaignMembers)
            {
                oppToUpdate.add(new Opportunity(Id=ld.ConvertedOpportunityId, CampaignId=cm.CampaignId));
            }
        }
        if(oppToUpdate.size() > 0)
        {
            SilverPeakUtils.BypassingTriggers = true;
            update oppToUpdate;
            SilverPeakUtils.BypassingTriggers = false;
        }
    }
}