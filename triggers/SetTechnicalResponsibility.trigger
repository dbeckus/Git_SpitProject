/*
 * if Technical_Responsibility__c is null, set Technical_Responsibility__c = Owner.Default_TR__c
* if Channel_Sales_Mgr__c  is null, set Channel_Sales_Mgr__c  = Owner.Channel_Sales_Mgr__c 
 */

trigger SetTechnicalResponsibility on Opportunity (before insert, before update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Map<Id, Id> defaultTRs = new Map<Id, Id>(); //key: User Id => value: User Default TR Id
        for(Opportunity opportunity : trigger.new)
        {
            if(opportunity.Technical_Responsible__c == null)
            {
                defaultTRs.put(opportunity.OwnerId, null);
            }
        }
        
        if(!defaultTRs.isEmpty())
        {
            for(User user : [select Id, Default_TR__c from User where Id in :defaultTRs.keySet() and Default_TR__c != null])
            {
                defaultTRs.put(user.Id, user.Default_TR__c);
            }
            for(Opportunity opportunity : trigger.new)
            {
                if(opportunity.Technical_Responsible__c == null)
                {
                    if(defaultTRs.containsKey(opportunity.OwnerId))
                    {
                        opportunity.Technical_Responsible__c = defaultTRs.get(opportunity.OwnerId);
                    }
                }
            }
        }
        Map<Id, Id> defaultCSRs = new Map<Id, Id>(); //key: User Id => value: User Default TR Id
        for(Opportunity opportunity : trigger.new)
        {
            if(opportunity.Channel_Sales_Mgr__c == null)
            {
                defaultCSRs.put(opportunity.OwnerId, null);
            }
        }
        
        if(!defaultCSRs.isEmpty())
        {
            for(User user : [select Id, Channel_Sales_Mgr__c from User where Id in :defaultCSRs.keySet() and Channel_Sales_Mgr__c != null])
            {
                defaultCSRs.put(user.Id, user.Channel_Sales_Mgr__c);
            }
            for(Opportunity opportunity : trigger.new)
            {
                if(opportunity.Channel_Sales_Mgr__c == null)
                {
                    if(defaultCSRs.containsKey(opportunity.OwnerId))
                    {
                        opportunity.Channel_Sales_Mgr__c = defaultCSRs.get(opportunity.OwnerId);
                    }
                }
            }
        }
    }
}