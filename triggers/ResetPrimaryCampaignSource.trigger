/*
 * If Opp is converted from a lead, the primary campiagn source by standard SFDC feature is set to the last campaign on lead.
 * Business requirement wants to ignore Sales Dev campaign
 */
trigger ResetPrimaryCampaignSource on Opportunity (after insert) 
{
    List<Id> oppIds = new List<Id>();
    for(Opportunity opp : Trigger.new)
    {
        if(opp.CampaignId == SalesDevelopmentHelper.getSDcampaign())
        {
            oppIds.add(opp.Id);
        }
    }
    if(oppIds.size() > 0)
    {
        if(System.isFuture())
        {
            SalesDevelopmentHelper.ResetPrimaryCampaignSource(oppIds);
        }
        else
        {
            SalesDevelopmentHelper.willResetPrimaryCampaignSource(oppIds);
        }
    }
}