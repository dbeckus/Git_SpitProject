trigger TriggerProvisionDecomissionOnAssets on Asset (after insert,after update) {
    List<Asset> assetIds= new List<Asset>();
    List<Asset> assetsToDesync= new List<Asset>();
    List<Account> assetAcctIds= new List<Account>();
    Set<Id> oldAcctIds= new Set<Id>();
    Id silverpeakSystemsId='00130000007mEjX';
    if(SilverPeakUtils.IsProduction())
    {
        silverpeakSystemsId='00130000007mEjX';
    }
    else
    {
        List<Account> spAccount=[select Id from Account where Name='Silver Peak Systems'];
        if(spAccount!=null && spAccount.size()>0)
        {
            silverpeakSystemsId=spAccount[0].Id;
            
        }
    }
    List<Asset> toUpdateAssets= new List<Asset>();
    toUpdateAssets=[Select Id,Sync_With_Cloud_Portal__c,Status,AccountId,Account.Name from Asset where Id in: trigger.NewMap.keyset() and Product2.Family ='Product' and Product2.Name like 'EC%'];
    if(toUpdateAssets.size()>0)
    {
        for(Asset toUpdateAsset:toUpdateAssets)
        {
            if(Trigger.isInsert)
            {
                string acctId=toUpdateAsset.Account.Id;
                if(acctId!=silverpeakSystemsId)
                {
                    oldAcctIds.add(toUpdateAsset.AccountId);
                }
                
            }
            else if(Trigger.isUpdate)
            {
                
                Asset oldAsset = Trigger.oldMap.get(toUpdateAsset.Id);
                // decommission asset
                if(toUpdateAsset.AccountId == silverpeakSystemsId && oldAsset.AccountId != toUpdateAsset.AccountId)
                {
                    oldAcctIds.add(oldAsset.AccountId);
                }
                //provision an existing asset to another account
                if(oldAsset.AccountId != toUpdateAsset.AccountId && oldAsset.AccountId == silverpeakSystemsId && oldAsset.Status =='Silver Peak Inventory')
                {
                    string acctName=toUpdateAsset.Account.Name;
                    if(!acctName.toLowerCase().contains('silver peak'))
                    {
                        oldAcctIds.add(toUpdateAsset.AccountId);
                    }
                }
                
                
            }
        }
        
    }
    System.debug( oldAcctIds.size());
    if(oldAcctIds.size()>0)
    {
        assetIds.addAll([select Id from Asset where AccountId in:oldAcctIds and Product2.family='Product' and Product2.Name like 'EC%' and status not in ('Silver Peak Inventory','Write-Off','Obsolete RMA Unit–Supp Transferred–WO')]);
    }
    if(assetIds.size()>0)
    {
        for(Asset item: assetIds)
        {
            item.Cloud_Portal_Sync_Status__c='Pending';
            item.Sync_With_Cloud_Portal__c=true;
            
        }
        
        update assetIds;
    }
    for(Id acctId:oldAcctIds)
    {
        assetAcctIds.add(new Account(Id=acctId,Sync_With_Cloud_Portal__c=true));
    }
    if(assetAcctIds.size()>0)
    {
        update assetAcctIds;
    }
    
    // remove sync flag 
    /*
    assetsToDesync=[Select Id,Sync_With_Cloud_Portal__c, Cloud_Portal_Sync_Status__c from Asset where AccountId=:silverpeakSystemsId and Sync_With_Cloud_Portal__c=true and Product2.Family ='Product' and Product2.Name like 'EC%' ];
    if(assetsToDesync.size()>0)
    {
        for(Asset item: assetsToDesync)
        {
            item.Sync_With_Cloud_Portal__c=false;
            item.Cloud_Portal_Sync_Status__c='';
        }
        
        update assetsToDesync;
    }*/
    
    
}