public with sharing class ContactLeadCount implements Database.Batchable<Sobject>, Database.Stateful
{

	public Database.Querylocator start(Database.BatchableContext BC)
    {
         return Database.getQueryLocator([select id, Email FROM Contact ORDER BY Email ASC]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> objs)
    {
    	List<AOContact__c> aoContacts = new List<AOContact__c>();
    	List<String> emails = (List<String>)TriggerTools.getValueFromField(objs, 'Email', new List<String>());
    	List<Lead> leads = [SELECT id, Email FROM lead WHERE Email in :emails AND isConverted = false];
    	List<AOEmail__c> aoeamails = [SELECT id, Email__c FROM AOEmail__c WHERE Email__c in :emails];
        for(Contact c : objs)
        {
        	Map<String,Object> r = new Map<String,Object>();
        	r.put('Email',c.Email);
        	if(TriggerTools.listContainsObject(r, leads) != null)
        	{
				Map<String,Object> rules = new Map<String,Object>();
				rules.put('Email__c',c.email);
	        	AOEmail__c temp = (AOEmail__c)TriggerTools.listContainsObject(rules, aoeamails);
	        	if(temp == null)
	        	{
	        		temp = new AOEmail__c(Email__c = c.Email);
	        		insert temp;
	        		aoeamails.add(temp);
	        	}
	        	aoContacts.add(new AOContact__c(AOEmail__c = temp.id, Contact__c = c.id));
        	}
        }
        upsert aoContacts;
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }

}