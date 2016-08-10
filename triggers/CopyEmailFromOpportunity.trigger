/*
 *   Copies the Emails of Owner and Technical Responsible from Opportunity to PO
 */
trigger CopyEmailFromOpportunity on Purchase_Order__c (before insert, before update) 
{
    Set<Id> oppIds = new Set<Id>();
    for(Purchase_Order__c po : Trigger.new)
    {
        if(po.Opportunity__c != null)
        {
            oppIds.add(po.Opportunity__c);
        }
    }
    List<Opportunity> opps = [select Id, Owner.Email, Technical_Responsible__r.Email from Opportunity where Id in :oppIds];
    
    Map<Id, Opportunity> oppId2opp = new Map<Id, Opportunity>();
    for(Opportunity opp : opps)
    {
        oppId2opp.put(opp.Id, opp);
    }
    
    for(Purchase_Order__c po : Trigger.new)
    {
        if(oppId2opp.containsKey(po.Opportunity__c))
        {
            Opportunity opp = oppId2opp.get(po.Opportunity__c);
            po.Owner_Email__c = opp.Owner.Email;
            if(opp.Technical_Responsible__r != null)
            {
                po.Technical_Resposible_Email__c = opp.Technical_Responsible__r.Email;
            }
        }
    }
}