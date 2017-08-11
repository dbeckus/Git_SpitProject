public class CheckVirtualAssetsSyncFlag implements Schedulable, Database.Batchable<sObject>, Database.Stateful {    
    
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CheckVirtualAssetsSyncFlag(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Name from Account where Id in (SELECT AccountId FROM Asset where Sync_With_Cloud_Portal__c =true)]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Account> lstAccounts=  (List<Account>) scope;
        List<Account> lstAccountsToUpdate= new List<Account>();
        Set<Id> setSoftwareAccIds= new Set<Id>();
        Set<Id> setHardwareAccIds= new Set<Id>();
        Set<Id> setAccIds= new Set<Id>();
        if(lstAccounts.size()>0)
        {
            for(Account acc :lstAccounts)
            {
                setAccIds.add(acc.Id);
            }
            List<Asset> lstAssets =[Select Id, AccountId, product2.Family from Asset where AccountId in:setAccIds and Sync_With_Cloud_Portal__c =true];
            if(lstAssets!=null && lstAssets.size()>0)
            {
                for(Asset item: lstAssets)
                {
                    if(item.Product2.Family=='Virtual Image')
                        setSoftwareAccIds.add(item.AccountId);
                    if(item.Product2.Family=='Product')
                        setHardwareAccIds.add(item.AccountId);
                }
                for(Id item: setAccIds)
                {
                    Account acc= new Account(Id=item);
                    if(setSoftwareAccIds.size()>0 && setSoftwareAccIds.contains(item))
                    {
                        acc.Sync_Virtual_Assets_with_CP__c=true;
                    }
                    if(setHardwareAccIds.size()>0 && setHardwareAccIds.contains(item))
                    {
                        acc.Sync_with_Cloud_Portal__c=true;
                    }
                    lstAccountsToUpdate.add(acc);
                }
                if(lstAccounts.size()>0)
                {
                    update lstAccountsToUpdate;
                }
            }
            
        }
        
    }
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CheckVirtualAssetsSyncFlag obj= new CheckVirtualAssetsSyncFlag();
            System.scheduleBatch(obj, 'Trigger Assets to sync in Cloud Portal', 30, 10);
        }
    }
    
    
    
}