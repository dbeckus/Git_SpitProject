/*
 * Sets Lead Source = Opportunity Source when Lead Source is Null or Lead Source value not in its picklist options
 */
trigger SetLeadSourceOnOpp on Opportunity (before insert, before update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Schema.Describefieldresult F = Opportunity.LeadSource.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        Set<String> options = new Set<String>();
        for(Schema.Picklistentry ple : P)
        {
            options.add(ple.getValue());
        }
        
        if(Trigger.isInsert)
        {
            for(Opportunity opp : Trigger.new)
            {
                if(opp.LeadSource == null)
                {
                    opp.LeadSource = opp.Opportunity_Source__c;
                }
            }
        }
        else
        {
            for(Opportunity opp : Trigger.new)
            {
                if(opp.Opportunity_Source__c != Trigger.oldMap.get(opp.Id).Opportunity_Source__c)
                {
                    if(!options.contains(opp.LeadSource))
                    {
                        opp.LeadSource = opp.Opportunity_Source__c;
                    }
                }
            }
        }
    }
}