trigger UpdateECCustomerDate on Asset (after insert,after update) {
    Set<Id> setAcctIds= new Set<Id>();
    for(Asset counter: Trigger.New)
    {
        if(counter.AccountId!=null)
        {
            setAcctIds.add(counter.AccountId);                
        }
    }
    
    List<account> lstAccountToUpdate= new List<Account>();
    if(setAcctIds.size()>0)
    {
        List<Account> lstAccount=[Select Id from Account where Id in:setAcctIds and EC_Customer_Date__c=null];
        if(lstAccount!=null && lstAccount.size()>0)
        {
            for(Account accId: lstAccount)
            {
                List<Asset> lstAsset=[Select Id,CreatedDate from asset where AccountId=:accId.Id and Product2.Name like 'EC%' and Status in('Customer Subscription Active','Customer Owned' ) order by CreatedDate asc LIMIT 1];
                if(lstAsset!=null && lstAsset.size()>0)
                {
                    Account acc= new Account(Id=accId.Id);
                    acc.EC_Customer_Date__c=lstAsset[0].CreatedDate;
                    lstAccountToUpdate.add(acc);
                }
            }
        }
    }
    if(lstAccountToUpdate.size()>0)
    {
        update lstAccountToUpdate;
    }
}