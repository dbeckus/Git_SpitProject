public with sharing class LeadContactCount implements Database.Batchable<Sobject>, Database.Stateful
{

	public Database.Querylocator start(Database.BatchableContext BC)
    {
         return Database.getQueryLocator([SELECT id, Email FROM Lead WHERE isConverted = false ORDER BY Email ASC]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead> objs)
    {
    	List<AOLead__c> aoleads = new List<AOLead__c>();
    	List<String> emails = (List<String>)TriggerTools.getValueFromField(objs, 'Email', new List<String>());
    	List<Contact> contacts = [SELECT id, Email FROM Contact WHERE Email in :emails];
    	List<AOEmail__c> aoeamails = [SELECT id, Email__c FROM AOEmail__c WHERE Email__c in :emails];
        for(Lead l : objs)
        {
        	Map<String,Object> r = new Map<String,Object>();
        	r.put('Email',l.Email);
        	if(TriggerTools.listContainsObject(r, contacts) != null)
        	{
				Map<String,Object> rules = new Map<String,Object>();
				rules.put('Email__c',l.email);
	        	AOEmail__c temp = (AOEmail__c)TriggerTools.listContainsObject(rules, aoeamails);
	        	if(temp == null)
	        	{
	        		temp = new AOEmail__c(Email__c = l.Email);
	        		insert temp;
	        		aoeamails.add(temp);
	        	}
	        	aoleads.add(new AOLead__c(AOEmail__c = temp.id, Lead__c = l.id));
        	}
        }
        upsert aoleads;
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }

}