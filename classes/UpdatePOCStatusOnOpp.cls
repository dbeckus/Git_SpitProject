public class UpdatePOCStatusOnOpp implements Database.Batchable<sObject>
{
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([select Id, (select Id from Requests__r limit 1) from Opportunity]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Opportunity> targets = new List<Opportunity>();
        for(sObject obj : scope)
        {
            Opportunity opp = (Opportunity)obj;
            if(opp.Requests__r.size() > 0)
            {
                opp.POC_History__c = true;
                opp.Bypassing_Validation__c = true;
                targets.add(opp);
            }
        }
        if(targets.size() > 0)
        {
            update targets;
        }
    }
    
    public Void finish(Database.BatchableContext context)
    {
    }
}