trigger UpdateActiveAssetCount on Asset (after insert, after update,after delete,after undelete) {
    Set<Id> acctIds= new Set<Id>();
    if(Trigger.isDelete)
    {
        for(Asset asset : Trigger.old)
        {
            if(asset.AccountId!=null)
            {
                acctIds.add(asset.AccountId);
            }
        }
    }
    else if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(Asset asset : Trigger.New)
        {
            if(asset.AccountId!=null)
            {
                acctIds.add(asset.AccountId);
            }
        }
    }
    else
    {
        //isUpdate
        for(Asset asset : Trigger.new)
        {
            Asset oldAsset = Trigger.oldMap.get(asset.Id);
            if(oldAsset.AccountId != asset.AccountId)
            {
                if(asset.AccountId != null)
                {
                    acctIds.add(asset.AccountId);
                }
                if(oldAsset.AccountId != null)
                {
                    acctIds.add(oldAsset.AccountId);
                }
            }
            if(oldAsset.Status != asset.Status)
            {
                if(asset.AccountId != null)
                {
                    acctIds.add(asset.AccountId);
                }
            }
            
        }
    }
    List<Account> updatingAccounts = new List<Account>();
    for(Id accId : acctIds)
    {
        Integer count = [select count() from Asset where AccountId=:accId and Status in ('Customer Owned','Customer Subscription Active','Customer Subscription')];
        Account updatingAcc = new Account(Id = accId, Active_Asset_Count__c = count);
        updatingAccounts.add(updatingAcc);
    }
    update updatingAccounts;

}