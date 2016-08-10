trigger LeadTransition on Lead (after insert, after update) {

    List<Lead> leads = Trigger.new;
    List<String> ids = new List<String>();
    for(Lead l : leads)
    {
        ids.add(l.id); 
    }
    List<Lead_Transition__c> transitions = [SELECT Id, Converted_to_Opp__c, IQL_Campaign__c, IQL_Date__c, Lead__c, Marketing_Nurture__c, Marketing_Qualified__c, MN_Campaign__c, MN_Date__c, MQL_Campaign__c, MQL_Date__c, OPP_Campaign__c, OPP_Date__c, REJ_Campaign__c, REJ_Date__c, Rejected__c, SAL_Campaign__c, SAL_Date__c, Sales_Accepted__c, Sales_Qualifying__c, Won_Business__c, WON_Campaign__c, WON_Date__c FROM Lead_Transition__c WHERE Lead__c in :ids];
    for(Lead lead : leads) 
    {
        Lead_Transition__c t;
        if(Trigger.isInsert)
        {
            t = new Lead_Transition__c(Marketing_Nurture__c = 1, Lead__c = lead.id, MN_Date__c = System.now(), MN_Campaign__c = lead.Last_Mkt_Campaign_Id__c);
            transitions.add(t);
        }
        else
        {
            for(Lead_Transition__c ltc : transitions)
            {
                if(ltc.Lead__c == lead.id && ltc.Rejected__c != 1)
                {
                    t = ltc;
                }
            }
        }
        if(t == null)
        {
            t = new Lead_Transition__c(Marketing_Nurture__c = 1, Lead__c = lead.id, MN_Date__c = System.now(), MN_Campaign__c = lead.Last_Mkt_Campaign_Id__c);
            transitions.add(t);
        }
        try
        {
            if(t.get(Lead_Matrix__c.getValues(lead.Status).Transition_State__c) != 1)
            {
                t.put(Lead_Matrix__c.getValues(lead.Status).Transition_State__c,1);
                t.put(Lead_Matrix__c.getValues(lead.Status).Date__c,System.now());
               t.put(Lead_Matrix__c.getValues(lead.Status).Campaign__c, lead.Last_Mkt_Campaign_Id__c);
            }
        }
        catch(Exception e)
        {
            
        }
        if (lead.IsConverted)
        {
            if( t.Converted_to_Opp__c != 1)
            {
                t.Converted_to_Opp__c = 1;
                t.OPP_Date__c = System.Now();
                t.OPP_Campaign__c = lead.Last_Mkt_Campaign_Id__c;
            }
        }
    }
    upsert transitions;
}