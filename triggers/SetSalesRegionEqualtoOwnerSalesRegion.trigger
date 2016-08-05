/*
 *the trigger would set the Opportunity-Sales Region = Opportunity Owner-Sales Region
 */ 
trigger SetSalesRegionEqualtoOwnerSalesRegion on Opportunity (before update, before insert) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<Id> oppIds = new Set<Id>(); 
        for(Opportunity opp: Trigger.New)
        {  
            oppIds.add(opp.OwnerId);
        }
        
        List<User> users = [select Id , Sales_Region__c from User where Id in :oppIds];
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