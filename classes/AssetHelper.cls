public class AssetHelper {
    
    @future
    public static void TriggerActiveAssetCount(Set<Id> acctIds)
    {
        List<Account> updatingAccounts= new List<Account>();
        if(acctIds.size() > 0)
        {
            for(Id counter: acctIds)
            {
                
                updatingAccounts.add(new Account(Id = counter, Trigger_Active_Asset_Count__c=true));
            }
        }
        if(updatingAccounts.size()>0)
        {
            
            update updatingAccounts;
        }
    }
    
    @future
   public static void CalculateCustomerDate(Set<Id> acctIds)
    {
        Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
        Map<Id,Date> mapECIds= new Map<Id,Date>();
        List<Account> lstECAccount=[Select Id, (select Id,Name,Ship_Date__c from Assets where Product2.Name like 'EC%' and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Owned','Customer Subscription Expired' ) order by Ship_Date__c asc LIMIT 1) from Account where Id in:acctIds];
        List<Account> lstWanOpAccount=[Select Id, (select Id,Name,Ship_Date__c from Assets where Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned','Customer Subscription Expired' ) order by Ship_Date__c asc LIMIT 1) from Account where Id in:acctIds];
        List<account> lstAccountToUpdate= new List<Account>();
        if(lstECAccount!=null && lstECAccount.size()>0)
        {
            for(Account acc: lstECAccount)
            {
                List<Asset> lstAsset = acc.Assets;
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    mapECIds.put(acc.Id,lstAsset[0].Ship_Date__c);
                    System.debug(lstAsset[0].Name);
                }
            }
        }
        if(lstWanOpAccount!=null && lstWanOpAccount.size()>0)
        {
            for(Account acc: lstWanOpAccount)
            {
                List<Asset> lstAsset = acc.Assets;
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    mapWanOpIds.put(acc.Id,lstAsset[0].Ship_Date__c);
                    System.debug(lstAsset[0].Name);
                }
            }
        }
        for(Id accId: acctIds)
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
                lstAccountToUpdate.add(newAcc);
            }
            
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
    
}