trigger UpdateECCustomerDate on Asset (after insert,after update) {
    Set<Id> setAcctIds= new Set<Id>();
    
    if(Trigger.isInsert)
    {
        for(Asset counter: Trigger.New)
        {
            if(counter.AccountId!=null)
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
            if(counter.AccountId!=null && counter.AccountId!=oldAsset.AccountId)
            {
                setAcctIds.add(counter.AccountId);                
            }
        } 
    }
    
    List<account> lstAccountToUpdate= new List<Account>();
    if(setAcctIds.size()>0)
    {
        List<Account> lstAccount=[Select Id, (select Id,Name, CreatedDate from Assets where Product2.Name like 'EC%' and Status in('Customer Subscription Active','Customer Owned' ) order by CreatedDate asc LIMIT 1) from Account where Id in:setAcctIds and EC_Customer_Date__c=null];
        if(lstAccount!=null && lstAccount.size()>0)
        {
            for(Account acc: lstAccount)
            {
                List<Asset> lstAsset = acc.Assets;
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    Account newAcc= new Account(Id=acc.Id);
                    newAcc.EC_Customer_Date__c=lstAsset[0].CreatedDate;
                    newAcc.EC_Asset_Name__c=lstAsset[0].Name;
                    lstAccountToUpdate.add(newAcc);
                }
            }
        }
    }
    if(lstAccountToUpdate.size()>0)
    {
        update lstAccountToUpdate;
    }
}