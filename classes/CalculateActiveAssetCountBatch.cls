public class CalculateActiveAssetCountBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful 
{
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CalculateActiveAssetCountBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,AccountId from Asset where Is_Customer_Asset__c=true ]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        
        List<Asset> lstAsset= (List<Asset>)scope;
        List<Account> lstAccountToUpdate= new List<Account>();
        List<Asset> lstAssetToUpdate= new List<Asset>();
        Map<Id,Account> mapAccountCount= new Map<Id,Account>();
        Map<Id,Account> mapCustomerDate= new Map<Id,Account>();
        Set<Id> accIds= new Set<Id>();
        for(Asset item: lstAsset)
        {
            accIds.add(item.AccountId);
        }
        mapAccountCount=CalculateAssetCount(accIds);
        mapCustomerDate=CalculateCustomerDate(accIds);
        for(Id accountId: accIds)
        {
            Account acc= new Account(Id=accountId);
            if(mapAccountCount.containsKey(accountId))
            {
                Account outputAcc=mapAccountCount.get(accountId);
                acc.Active_Asset_Count__c=outputAcc.Active_Asset_Count__c;
            }
            
            if(mapCustomerDate.containsKey(accountId))
            {
                Account outputAcc=mapCustomerDate.get(accountId);
                System.debug('outputAcc.WAN_OP_Customer_Date__c'+outputAcc.WAN_OP_Customer_Date__c);
                System.debug('outputAcc.EC_Customer_Date__c'+outputAcc.EC_Customer_Date__c);
                if(outputAcc.WAN_OP_Customer_Date__c!=null)
                    acc.WAN_OP_Customer_Date__c=outputAcc.WAN_OP_Customer_Date__c;
                if(outputAcc.EC_Customer_Date__c!= null)
                    acc.EC_Customer_Date__c=outputAcc.EC_Customer_Date__c;   
            }
            
            lstAccountToUpdate.add(acc);
        }
        System.Savepoint sp= Database.setSavepoint();
        try
        {
            if(lstAccountToUpdate.size()>0)
            {
                update lstAccountToUpdate;
            }
            for(Asset item: lstAsset)
            {
                lstAssetToUpdate.add(new Asset(Id=item.Id,Is_Customer_Asset__c=false));
            }
            if(lstAssetToUpdate.size()>0)
            {
                update lstAssetToUpdate;
            }
        }
        catch(Exception ex)
        {
            Database.Rollback(sp);
            System.debug(ex);
            SilverPeakUtils.logException(ex);
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
            System.scheduleBatch(obj, 'Trigger Asset Count and Customer Date', 60, 1);
        }
        
    }
    
    
    private static Map<Id,Account> CalculateAssetCount(Set<Id> setAccIds)
    {
        
        AggregateResult[] lstVirtualAssets=[Select AccountId, Count(Id)counter from Asset where AccountId in:setAccIds and Status in('Customer Subscription','Customer Subscription Active')and Product2.Family='Virtual Image' and (not Product2.Name='EC-ORCH') GROUP BY AccountID];
        AggregateResult[] lstVirtualOwnedAssets=[Select AccountId, Count(Id)counter from Asset where AccountId in:setAccIds and Status ='Customer Owned' and Product2.Family='Virtual Image' and Contract_Number__r.Status='Activated' GROUP BY AccountID];
        AggregateResult[] lstHdwrECAssets=[Select AccountId, Count(Id)counter from Asset where AccountId in:setAccIds and Status ='Customer Owned' and Product2.Family='Product' and Product2.Product_Type__c='EDGECONNECT' and Active_EC_Base_License__c!=null and Active_EC_Base_License__r.Status='Customer Subscription Active'  GROUP BY AccountID];
        AggregateResult[] lstHdwrAssets=[Select AccountId, Count(Id)counter from Asset where AccountId in:setAccIds and Status ='Customer Owned' and Product2.Family='Product' and Product2.Product_Type__c not in ('EDGECONNECT') and Contract_Number__c!=null and Contract_Number__r.Status='Activated'  GROUP BY AccountID];
        Map<Id,integer> mapVirtualAssets= new Map<Id,integer>();
        Map<Id,integer> mapVirtualOwnedAssets= new Map<Id,integer>();
        Map<Id,integer> mapHdwrECAssets= new Map<Id,integer>(); 
        Map<Id,integer> mapHdwrAssets= new Map<Id,integer>();
        
        Map<Id,Account> mapAccountToUpdate= new Map<Id,Account>();
        if(lstVirtualAssets!=null && lstVirtualAssets.size()>0)
        {
            mapVirtualAssets=GetCountfromList(lstVirtualAssets);
        }
        if(lstVirtualOwnedAssets!=null && lstVirtualOwnedAssets.size()>0)
        {
            mapVirtualOwnedAssets=GetCountfromList(lstVirtualOwnedAssets);
        }
        if(lstHdwrECAssets!=null && lstHdwrECAssets.size()>0)
        {
            mapHdwrECAssets=GetCountfromList(lstHdwrECAssets);
        }
        if(lstHdwrAssets!=null && lstHdwrAssets.size()>0)
        {
            mapHdwrAssets=GetCountfromList(lstHdwrAssets);
        }
        for(Id accId :setAccIds)
        {
            integer assetCount=0;
            if(mapVirtualAssets.containsKey(accId))
            {
                assetCount+=mapVirtualAssets.get(accId);
            }
            if(mapVirtualOwnedAssets.containsKey(accId))
            {
                assetCount+=mapVirtualOwnedAssets.get(accId);
            }
            if(mapHdwrECAssets.containsKey(accId))
            {
                assetCount+=mapHdwrECAssets.get(accId);
            }
            if(mapHdwrAssets.containsKey(accId))
            {
                assetCount+=mapHdwrAssets.get(accId);
            }
            mapAccountToUpdate.put(accId,new Account(Id=accId,Active_Asset_Count__c=assetCount));
        }
        
        return mapAccountToUpdate;
    }
    
    private static Map<Id,Account> CalculateCustomerDate(Set<Id> setAccIds)
    {
        Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
        Map<Id,Date> mapECIds= new Map<Id,Date>();
        Map<Id,account> lstAccountToUpdate= new Map<Id,Account>();
        AggregateResult[] ecAggr=[Select AccountId, Min(Ship_Date__c)  custDate  from Asset where AccountId in:setAccIds and Product2.Name like 'EC%' and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Owned','Customer Subscription Expired' ) GROUP BY ACCOUNTID];
        AggregateResult[] wanOppAggr=[Select AccountId, Min(Ship_Date__c) custDate  from Asset where AccountId in:setAccIds and Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned','Customer Subscription Expired' ) GROUP BY ACCOUNTID];
        if(ecAggr!=null&& ecAggr.size()>0)
        {
            for(AggregateResult ar: ecAggr)
            {
                Id accId= (Id) ar.get('AccountId');
                Date custDate=Date.valueOf(ar.get('custDate'));
                mapECIds.put(accId,custDate);
            }
        }
        if(wanOppAggr!=null&& wanOppAggr.size()>0)
        {
            for(AggregateResult ar: wanOppAggr)
            {
                Id accId= (Id) ar.get('AccountId');
                Date custDate=Date.valueOf(ar.get('custDate'));
                mapWanOpIds.put(accId,custDate);
            }
        }
        for(Id accId: setAccIds)
        {    
            Account newAcc= new Account(Id=accId);
            if(mapWanOpIds.containsKey(accId))
            {
                Date dt=mapWanOpIds.get(accId);
                if(dt!=null){
                    newAcc.WAN_OP_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}
            }
            if(mapECIds.containsKey(accId))
            {
                Date dt=mapECIds.get(accId);
                if(dt!=null){
                    newAcc.EC_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}
            }
            if(newAcc.EC_Customer_Date__c!=null || newAcc.WAN_OP_Customer_Date__c!=null)
            {
                System.debug(newAcc);
                lstAccountToUpdate.put(newAcc.Id, newAcc);
            }
            
        }
        return lstAccountToUpdate;
        
    }
    private static Map<Id,integer> GetCountfromList(AggregateResult[] lstAsset)
    {
        Map<Id,integer> mapReturnData= new Map<Id,integer>();
        if(lstAsset!=null && lstAsset.size()>0)
        {
            for(AggregateResult ar:lstAsset)
            {
                mapReturnData.put((Id)ar.get('AccountId'),(integer)ar.get('counter'));
            }
        }
        
        return mapReturnData;
    }
}