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
    if(acctIds.size() > 0)
    {
        List<Account> updatingAccounts = new List<Account>();
        List<AggregateResult> result = [select count(Id) c, AccountId a from Asset where AccountId in :acctIds and Status in ('Customer Owned','Customer Subscription Active','Customer Subscription') group by AccountId];
        for(Id accId : acctIds)
        {
            Boolean found = false;
            for(AggregateResult r : result)
            {
                Id resultAccId = (Id)r.get('a');
                if(resultAccId == accId)
                {
                    Decimal assetCount = (Decimal)r.get('c');
                    updatingAccounts.add(new Account(Id = accId, Active_Asset_Count__c = assetCount));
                    found = true;
                    break;
                }
            }
            if(!found) 
            {
                updatingAccounts.add(new Account(Id = accId, Active_Asset_Count__c = 0));
            }
        }
        update updatingAccounts;
    }
}