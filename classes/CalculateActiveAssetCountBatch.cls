public class CalculateActiveAssetCountBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful 
{
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CalculateActiveAssetCountBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id from Account where Trigger_Active_Asset_Count__c=true]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Account> lstAccount= (List<Account>)scope;
        List<Account> lstAccountToUpdate= new List<Account>();
        for(Account item: lstAccount)
        {
            // Fetch virtual assets
            // Fetch virtual assets where contract is active
            decimal assetCount=0;
            List<Asset> lstVirtualAssets=[Select Id from Asset where AccountId=:item.Id and Status in('Customer Subscription','Customer Subscription Active')and Product2.Family='Virtual Image' and (not Product2.Name='EC-ORCH')];
            List<Asset> lstVirtualOwnedAssets=[Select Id from Asset where AccountId=:item.Id and Status ='Customer Owned' and Product2.Family='Virtual Image' and Contract_Number__r.Status='Activated'];
            List<Asset> lstHdwrECAssets=[Select Id from Asset where AccountId=:item.Id and Status ='Customer Owned' and Product2.Family='Product' and Product2.Product_Type__c='EDGECONNECT' and Active_EC_Base_License__r.Status='Customer Subscription Active'];
            List<Asset> lstECSPAssets=[Select Id from Asset where AccountId=:item.Id and Status ='Customer Owned' and Product2.Product_Type__c ='EC-SP' and Service_Provider_Status__c='Active'];
            List<Asset> lstHdwrAssets=[Select Id from Asset where AccountId=:item.Id and Status ='Customer Owned' and Product2.Family='Product' and Product2.Product_Type__c not in ('EDGECONNECT','EC-SP') and Contract_Number__r.Status='Activated'];
            if(lstVirtualAssets!=null && lstVirtualAssets.size()>0)
            {
                assetCount +=lstVirtualAssets.size();
            }
            if(lstVirtualOwnedAssets!=null && lstVirtualOwnedAssets.size()>0)
            {
                assetCount +=lstVirtualOwnedAssets.size();
            }
             if(lstHdwrECAssets!=null && lstHdwrECAssets.size()>0)
            {
                assetCount +=lstHdwrECAssets.size();
            }
             if(lstECSPAssets!=null && lstECSPAssets.size()>0)
            {
                assetCount +=lstECSPAssets.size();
            }
             if(lstHdwrAssets!=null && lstHdwrAssets.size()>0)
            {
                assetCount +=lstHdwrAssets.size();
            }
            
            lstAccountToUpdate.add(new Account(Id=item.Id,Active_Asset_Count__c=assetCount,Trigger_Active_Asset_Count__c=false));
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        
       // CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
       // System.scheduleBatch(obj, 'Calculate Active Asset Count', 180, 1);
    }
    
}