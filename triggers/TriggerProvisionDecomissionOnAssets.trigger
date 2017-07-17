trigger TriggerProvisionDecomissionOnAssets on Asset (after insert,after update) {
    List<Asset> assetIds= new List<Asset>();
    List<Asset> assetsToDesync= new List<Asset>();
    List<Account> assetAcctIds= new List<Account>();
    Set<Id> oldAcctIds= new Set<Id>();
    Set<Id> decommissionAcctIds= new Set<Id>();
    Set<Id> oldAcctIdsToUpdate= new Set<Id>();
    Id silverpeakSystemsId='00130000007mEjX';
    if(SilverPeakUtils.IsProduction())
    {
        silverpeakSystemsId='00130000007mEjX';
    }
    else
    {
        List<Account> spAccount=[select Id from Account where Name='Silver Peak Systems'];
        System.debug('SilverPeakId'+ spAccount );
        if(spAccount!=null)
        {
            silverpeakSystemsId=spAccount[0].Id;
        }
    }
    for(Asset toUpdateAsset:Trigger.New)
    {
        if(Trigger.isInsert)
        {
            if(toUpdateAsset.AccountId!=null)
            {
                string acctId=toUpdateAsset.AccountId;
                if(acctId!=silverpeakSystemsId && (toUpdateAsset.Product_Quote_Type__c=='EDGECONNECT'|| toUpdateAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| toUpdateAsset.Product_Quote_Type__c=='EC-SP-Metered') && toUpdateAsset.Product_Family__c=='Product')
                {
                    if(toUpdateAsset.status !='Silver Peak Inventory' && toUpdateAsset.status !='Write-Off'&& toUpdateAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                    { 
                        assetIds.add(new Asset(Id=toUpdateAsset.Id,Cloud_Portal_Sync_Status__c='Pending',Sync_With_Cloud_Portal__c=true));
                        oldAcctIdsToUpdate.add(acctId);
                    }
                }
            }
        }
        else if(Trigger.isUpdate)
        {
            
            Asset oldAsset = Trigger.oldMap.get(toUpdateAsset.Id);
            // decommission asset
            if(toUpdateAsset.AccountId == silverpeakSystemsId && oldAsset.AccountId != toUpdateAsset.AccountId)
            {
                if(oldAsset.AccountId!=null)
                {
                    decommissionAcctIds.add(oldAsset.AccountId);
                }
                
            }
            //provision an existing asset to another account
            if(oldAsset.AccountId != toUpdateAsset.AccountId && oldAsset.AccountId == silverpeakSystemsId && oldAsset.Status =='Silver Peak Inventory')
            {
                if(toUpdateAsset.AccountId!=null && (toUpdateAsset.Product_Quote_Type__c=='EDGECONNECT'|| toUpdateAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| toUpdateAsset.Product_Quote_Type__c=='EC-SP-Metered') && toUpdateAsset.Product_Family__c=='Product')
                {
                    if(toUpdateAsset.status !='Silver Peak Inventory' && toUpdateAsset.status !='Write-Off'&& toUpdateAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                    { 
                        assetIds.add(new Asset(Id=toUpdateAsset.Id,Cloud_Portal_Sync_Status__c='Pending',Sync_With_Cloud_Portal__c=true));
                        oldAcctIdsToUpdate.add(toUpdateAsset.AccountId);
                    }
                }
                
            }
        }
    }
   
    if(assetIds.size()>0)
    {
        update assetIds;
    }
    if(oldAcctIdsToUpdate.size()>0)
    {
        for(Id acctId:oldAcctIdsToUpdate)
        {
            assetAcctIds.add(new Account(Id=acctId,Sync_With_Cloud_Portal__c=true));
        }
    }
    if(decommissionAcctIds.size()>0)
    {
        for(Id acctId:decommissionAcctIds)
        {
            assetAcctIds.add(new Account(Id=acctId,Sync_With_Cloud_Portal__c=true));
        }
    }
    
    if(assetAcctIds.size()>0)
    {
        update assetAcctIds;
    }
    
    
}