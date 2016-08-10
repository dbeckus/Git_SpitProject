trigger OpportunityTransition on Opportunity (after update) {

    List<Opportunity> opps = new List<Opportunity>();
    for(Opportunity opp : Trigger.new)
    {
        if(opp.IsWon)
        {
            opps.add(opp);
        }
    }
    if(opps.size() > 0)
    {
        List<Lead> leads = [SELECT Id, Last_Mkt_Campaign_Id__c FROM Lead WHERE ConvertedOpportunityId in :opps];
        List<String> ids = new List<String>();
        for(Lead l : leads)
        {
            ids.add(l.id);
        }
        List<Lead_Transition__c> transitions = [SELECT Id, Lead__c FROM Lead_Transition__c WHERE Lead__c in :ids];
        for(Lead_Transition__c t : transitions)
        {
            t.Won_Business__c = 1;
            t.WON_Date__c = System.now();
            for(Lead lead : leads)
            {
                if(lead.id == t.Lead__c)
                {
                    t.WON_Campaign__c = lead.Last_Mkt_Campaign_Id__c;
                }
            }
        }
        update transitions;
    }
}