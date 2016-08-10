/*
* Updates role field on contact role after opportunity is updated or created
*/
trigger UpdatesOpportunityContactRole on Opportunity (after insert, after update) 
{
    Set<ID> ids = Trigger.newMap.keySet();
    List<OpportunityContactRole>lstContactRole= new List<OpportunityContactRole>();
    
    List<OpportunityContactRole> oppCR = [select id, role from OpportunityContactRole where 
                                          opportunityid in :ids AND role = null];
    Decimal oppCrCount = [select count () from OpportunityContactRole where 
                          opportunityid in :ids AND role != null];
    if(oppCrCount == 0 && oppCR.size() > 0)
    {
        oppCR[0].Role = 'Contact';
        lstContactRole.add(oppCR[0]);
        
    }
    if(lstContactRole.size()>0)
    {
        update lstContactRole;
    }
}