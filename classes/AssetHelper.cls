public class AssetHelper {
    
    
    
    public static Map<Id,Account> CalculateCustomerDate_NoGroup(Set<Id> ecAcctIds,Set<Id> wanOpAcctIds)
    {
        System.debug('ECDates');
        Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
        Map<Id,Date> mapECIds= new Map<Id,Date>();
        Set<Id> acctIds= new Set<Id>();
        Map<Id,account> lstAccountToUpdate= new Map<Id,Account>();
        List<Asset> ecAggr=null;
        List<Asset> wanOppAggr=null;
        if(ecAcctIds!=null && ecAcctIds.size()>0)
        {
            ecAggr=[Select AccountId, Ship_Date__c,EC_Customer_Date__c  from Asset where AccountId in:ecAcctIds and Product2.Name like 'EC%' and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Owned','Customer Subscription Expired' ) Order by Ship_Date__c asc];
        }
        if(wanOpAcctIds!=null && wanOpAcctIds.size()>0)
        {
            wanOppAggr=[Select AccountId,WAN_OP_Customer_Date__c, Ship_Date__c from Asset where AccountId in:wanOpAcctIds and Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned','Customer Subscription Expired' ) Order by Ship_Date__c asc];
        }
        
        System.debug('ecAggr'+ecAggr);
        System.debug('wanOppAggr'+wanOppAggr);
        if(ecAggr!=null&& ecAggr.size()>0)
        {
            if(ecAggr[0].Ship_Date__c!=ecAggr[0].EC_Customer_Date__c)
            {
                mapECIds.put(ecAggr[0].AccountId,ecAggr[0].Ship_Date__c);
                acctIds.add(ecAggr[0].AccountId);
            }
            
        }
        if(wanOppAggr!=null&& wanOppAggr.size()>0)
        {
            if(wanOppAggr[0].Ship_Date__c!=wanOppAggr[0].WAN_OP_Customer_Date__c)
            {
                mapWanOpIds.put(wanOppAggr[0].AccountId,wanOppAggr[0].Ship_Date__c);
                acctIds.add(wanOppAggr[0].AccountId);
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
                System.debug('Dates added here');
                System.debug(newAcc.EC_Customer_Date__c);
                System.debug(newAcc.WAN_OP_Customer_Date__c);
                lstAccountToUpdate.put(newAcc.Id, newAcc);
            }
            
        }
        return lstAccountToUpdate;
        
    }
    
}