public with sharing class RvAccountToAccountBatchProcess implements Database.Batchable<Sobject>, Database.Stateful
{
    public Database.Querylocator start(Database.BatchableContext BC)
    {
         return Database.getQueryLocator([select Id, rvpe__SFAccount__c  FROM rvpe__RVAccount__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<rvpe__RVAccount__c> rvas)
    {
        List<String> accIds = (List<String>)TriggerTools.getValueFromField(rvas, 'rvpe__SFAccount__c', new List<String>());
        List<Account> accs = [SELECT id, RV_Account__c FROM Account WHERE id in :accIds AND RV_Account__c = null];
        for(rvpe__RVAccount__c rva : rvas)
        {
        	Map<String,Object> rules = new Map<String,Object>();
        	rules.put('id',rva.rvpe__SFAccount__c);
        	Account acc = (Account)TriggerTools.listContainsObject(rules, accs);
        	if(acc != null)
        	{
        		acc.RV_Account__c = rva.id;
        	}
        }
        database.update(accs,false);
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }
}