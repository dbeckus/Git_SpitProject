public class AssetHelper {
    
    
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
    
   
   public static void CalculateCustomerDate(Set<Id> ecAcctIds,Set<Id> wanOpAcctIds)
    {
        
        Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
        Map<Id,Date> mapECIds= new Map<Id,Date>();
        List<account> lstAccountToUpdate= new List<Account>();
        AggregateResult[] ecAggr=[Select AccountId, Min(Ship_Date__c) from Asset where AccountId in:ecAcctIds and Product2.Name like 'EC%' and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Owned','Customer Subscription Expired' ) GROUP BY ACCOUNTID];
        AggregateResult[] wanOppAggr=[Select AccountId, Min(Ship_Date__c) from Asset where AccountId in:wanOpAcctIds and Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned','Customer Subscription Expired' ) GROUP BY ACCOUNTID];
        
         /*if(dt!=null){
                    newAcc.WAN_OP_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}
        if(dt!=null){
                    newAcc.EC_Customer_Date__c=DateTime.newInstanceGmt(dt.year(), dt.month(), dt.day(), 23, 59, 59);}*/
        
        for(Id accId: ecAcctIds)
        {    
            Account newAcc= new Account(Id=accId);
           
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