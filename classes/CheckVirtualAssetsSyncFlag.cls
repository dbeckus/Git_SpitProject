public class CheckVirtualAssetsSyncFlag implements Schedulable, Database.Batchable<sObject>, Database.Stateful {    
    
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new AutomatePOCRenewalExtensions(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([SELECT AccountId, Id, Cloud_Portal_Sync_Status__c, Sync_With_Cloud_Portal__c FROM Asset where Sync_With_Cloud_Portal__c =true and Product2.Family='Virtual Image']);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Asset> lstAssets=  (List<Asset>) scope;
        List<Account> lstAccounts= new List<Account>();
        Set<Id> setAccIds= new Set<Id>();
        if(lstAssets.size()>0)
        {
            for(Asset item: lstAssets)
            {
                setAccIds.add(item.AccountId);
            }
            for(Id item: setAccIds)
            {
                lstAccounts.add(new Account(Id=item,Sync_Virtual_Assets_with_CP__c=true));
            }
            if(lstAccounts.size()>0)
            {
                update lstAccounts;
            }
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CheckVirtualAssetsSyncFlag obj= new CheckVirtualAssetsSyncFlag();
            System.scheduleBatch(obj, 'Check Virtual Assets Sync Flag', 30, 1);
        }
    }
    
    
    
}