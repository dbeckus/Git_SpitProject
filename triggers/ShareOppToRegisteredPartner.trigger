/* 
 * shares opp to portal users of the RegisteringPartner
 */
trigger ShareOppToRegisteredPartner on Opportunity (after insert, after update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        List<Opportunity> oppsNeedSharing = new List<Opportunity>();
        List<Id> oppIdsNeedSharing = new List<Id>();
        for(Opportunity opp : trigger.new)
        {
            if(Trigger.isInsert)
            {
               /* if(opp.Registering_Partner__c!=null)
                {
                    oppsNeedSharing.add(opp);
                }*/
                if(opp.LeadSource=='Deal Registration')
                {
                    oppsNeedSharing.add(opp);
                    oppIdsNeedSharing.add(opp.Id);
                }
            }
            else if(Trigger.isUpdate)
            {
                if(opp.LeadSource=='Deal Registration')
                {
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if(isChanged(oldOpp, opp, new String[] { 'LeadSource', 'OwnerId', 'Registered_Distributor_Contact__c', 'Registering_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registering_Partner__c'}))
                    {
                        oppsNeedSharing.add(opp);
                        oppIdsNeedSharing.add(opp.Id);
                    }
                }
            }
        }
        
        if(oppsNeedSharing.size() > 0)
        {
            if(System.isFuture())
            {
                ShareLeadAndOpportunityToPartnerHelper.shareOpportunities(oppsNeedSharing);
            }
            else
            {
                ShareLeadAndOpportunityToPartnerHelper.willShareOpportunities(oppIdsNeedSharing);
            }
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