public with sharing class DeleteAllLead implements Database.Batchable<Sobject>, Database.Stateful{

	public Database.Querylocator start(Database.BatchableContext BC)
    {
         return Database.getQueryLocator([select Id FROM AOLead__c]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> objs)
    {
        delete objs;
    }
    
    public void finish(Database.BatchableContext BC) 
    {
        
    }

}