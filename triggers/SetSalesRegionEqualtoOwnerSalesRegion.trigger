/*
 *the trigger would set the Opportunity-Sales Region = Opportunity Owner-Sales Region
 */ 
trigger SetSalesRegionEqualtoOwnerSalesRegion on Opportunity (before update, before insert) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<Id> ownerIds = new Set<Id>(); 
        if(Trigger.isInsert)
        {
            for(Opportunity opp: Trigger.New)
            {  
                ownerIds.add(opp.OwnerId);
            }
        }
        else if(Trigger.isUpdate)
        {
            for(Opportunity opp: Trigger.New)
            {  
                Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                if(oldOpp.OwnerId != opp.OwnerId)
                {
                    ownerIds.add(opp.OwnerId);
                }
            }
        }
        
        if(ownerIds.size() > 0)
        {
            List<User> users = [select Id , Sales_Region__c from User where Id in :ownerIds];
            for(Opportunity opp: Trigger.New)
            {
                for(User user: users)
                {
                    if((user.Id == opp.OwnerId)&&(opp.Sales_Region__c != user.Sales_Region__c))
                    {
                        opp.Sales_Region__c = user.Sales_Region__c;
                    }
                }
            } 
        }  
    }
}