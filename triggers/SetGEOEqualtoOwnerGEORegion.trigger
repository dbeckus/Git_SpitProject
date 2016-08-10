/*
 *the trigger would set the Lead-GEO = Lead Owner-GEORegion
 */ 
trigger SetGEOEqualtoOwnerGEORegion on Lead (before update, before insert) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<Id> LeadIds = new Set<Id>(); 
        for(Lead ld: Trigger.New)
        {  
            LeadIds.add(ld.OwnerId);
        }
        
        List<User> users = [select Id , GEO_Region__c from User where Id in :LeadIds];
        for(Lead ld: Trigger.New)
        {
            for(User user: users)
            {
                if((user.Id == ld.OwnerId)&&(ld.GEO__c != user.GEO_Region__c))
                {
                    ld.GEO__c = user.GEO_Region__c;
                }
            }
        }   
    }
}