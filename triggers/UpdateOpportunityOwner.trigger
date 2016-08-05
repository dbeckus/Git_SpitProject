trigger UpdateOpportunityOwner on Request__c (before insert, before update) 
{
    Map<Id, Opportunity> opportunities = new Map<Id, Opportunity>();
    Map<Id, User> users = new Map<Id, User>();
    for(Request__c request : trigger.new)
    {
        if(request.Opportunity__c != null)
        {
            opportunities.put(request.Opportunity__c, null);
        }
    }
    for(Opportunity opportunity : [select Id, OwnerId from Opportunity where Id in : opportunities.keySet()])
    {
        opportunities.put(opportunity.Id, opportunity);
        users.put(opportunity.OwnerId, null);
    }
    for(User user : [select Id, Name from User where Id in: users.keySet()])
    {
        users.put(user.Id, user);
    }   
    for(Request__c request : trigger.new)
    {
        if(request.Opportunity__c != null)
        {
            request.Opportunity_Owner__c = users.get(opportunities.get(request.Opportunity__c).OwnerId).Name;       
        }
    }
}