global class ShareLeadAndOpportunityToPartnerBatch implements Database.Batchable<sObject>
{
    String query = null;
    
    global ShareLeadAndOpportunityToPartnerBatch(String queryStr)
    {
        this.query = queryStr;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<sObject> scope)
    {
        List<Lead> leads = new List<Lead>();
        List<Opportunity> opps = new List<Opportunity>();
        for(sObject obj : scope)
        {
            if(obj instanceOf Lead)
            {
                leads.add((Lead)obj);
            }
            else if(obj instanceOf Opportunity)
            {
                opps.add((Opportunity)obj);
            }
        }
        if(leads.size() > 0)
        {
            ShareLeadAndOpportunityToPartnerHelper.shareLeads(leads);
        }
        if(opps.size() > 0)
        {
            ShareLeadAndOpportunityToPartnerHelper.shareOpportunities(opps);
        }
    }
    
    global void finish(Database.BatchableContext bc){}
}