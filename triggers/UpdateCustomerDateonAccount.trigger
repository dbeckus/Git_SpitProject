trigger UpdateCustomerDateonAccount on Asset (after insert,after update) {
    Set<Id> setAcctIds= new Set<Id>();
    Map<Id,Date> mapWanOpIds= new Map<Id,Date>();
    Map<Id,Date> mapECIds= new Map<Id,Date>();
    if(Trigger.isInsert)
    {
        for(Asset counter: Trigger.New)
        {
            if(counter.AccountId!=null && counter.Status!='Customer Evaluation' && counter.Ship_Date__c!=null)
            {
                setAcctIds.add(counter.AccountId);                
            }
        }
    }
    if(Trigger.isUpdate)
    {
        for(Asset counter: Trigger.New)
        {
            Asset oldAsset= Trigger.oldMap.get(counter.Id);
            if(counter.AccountId!=null && counter.Status!='Customer Evaluation' &&(counter.AccountId!=oldAsset.AccountId || counter.Ship_Date__c!=oldAsset.Ship_Date__c || counter.Status!=oldAsset.Status))
            {
                
                setAcctIds.add(counter.AccountId);    
                if(counter.AccountId!=oldAsset.AccountId)
                {
                    setAcctIds.add(oldAsset.AccountId);    
                }
            }
        } 
    }
    List<account> lstAccountToUpdate= new List<Account>();
    if(setAcctIds.size()>0)
    {
        List<Account> lstECAccount=[Select Id, (select Id,Name,Ship_Date__c from Assets where Product2.Name like 'EC%' and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Owned','Customer Subscription Expired' ) order by Ship_Date__c asc LIMIT 1) from Account where Id in:setAcctIds];
        List<Account> lstWanOpAccount=[Select Id, (select Id,Name,Ship_Date__c from Assets where Product2.Product_Type__c='NX/VX' and Status in('Customer Subscription','Customer Owned','Customer Subscription Expired' ) order by Ship_Date__c asc LIMIT 1) from Account where Id in:setAcctIds];
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
        for(Id accId: setAcctIds)
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