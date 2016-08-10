/*
 * Update Opportunity Contact Role (Evaluator) after POC is created
 */
trigger UpdateOpportunityContactRoleFromPOC on Request__c (after insert) 
{
    if(Trigger.isInsert)
    {
        List<Id> oppsAffected = getOppsNeedRole();
        Set<String> exstingRoles = getContactRoles(oppsAffected);
        List<OpportunityContactRole> newRoles = new List<OpportunityContactRole>();
        for(Request__c request : Trigger.new)
        {
            String contactRoleKey = request.Opportunity__c + ':' +  request.POC_Contact__c;
            if(!exstingRoles.contains(contactRoleKey))
            {
                newRoles.add(new OpportunityContactRole(OpportunityId=request.Opportunity__c, ContactId=request.POC_Contact__c, Role='Evaluator'));
            }
        }
        if(newRoles.size() > 0)
        {
            Database.insert(newRoles, false);
        }
    }
    

    
    private List<Id> getOppsNeedRole()
    {
        List<Id> result = new List<Id>();
        for(Request__c request : Trigger.new)
        {
            if(request.Opportunity__c != null && request.POC_Contact__c != null)
            {
                result.add(request.Opportunity__c);
            }
        }
        return result;
    }
    
    private Set<String> getContactRoles(List<Id> oppIds)
    {
        Set<String> result = new Set<String>();
        for(OpportunityContactRole contactRole : [select Id, OpportunityId, ContactId from OpportunityContactRole where OpportunityId in :oppIds])
        {
            result.add(contactRole.OpportunityId + ':' + contactRole.ContactId);
        }
        return result;
    }
}