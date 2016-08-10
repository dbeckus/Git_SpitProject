/* 
 * shares opp to portal users of the RegisteringPartner
 */
trigger ShareOppToRegisteredPartner on Opportunity (after insert, after update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        for(Opportunity opp : trigger.new)
        {
            if(Trigger.isInsert)
            {
                /*if(opp.Registering_Partner__c!=null)
                {
                    oppsNeedSharing.add(opp);
                }*/
                if(opp.LeadSource=='Deal Registration')
                {
                    oppsNeedSharing.add(opp);
                }
            }
            else if(Trigger.isUpdate)
            {
                if(opp.LeadSource=='Deal Registration')
                {
                    oppsNeedSharing.add(opp);
                }
                /*Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if(isChanged(oldOpp, opp, new String[] {'OwnerId', 'Registered_Distributor_Contact__c', 'Registering_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registering_Partner__c'}))
                {
                    oppsNeedSharing.add(opp);
                }*/
            }
        }
        
        if(oppsNeedSharing.size() > 0)
        {
            ShareLeadAndOpportunityToPartnerHelper.shareOpportunities(oppsNeedSharing);
        }
    }
    
    //checks if the fields are changed in the sObjects
    private Boolean isChanged(sObject oldObj, sObject newObj, String[] fields)
    {
        for(String field : fields)
        {
            Object oldValue = oldObj.get(field);
            Object newValue = newObj.get(field);
            if(oldValue != newValue)
            {
                return true;
            }
        }
        return false;
    }
}