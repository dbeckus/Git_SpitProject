trigger TriggerActiveAssetCountFromAsset on Asset (after insert,after delete, after undelete, after update) {
    Set<Id> acctIds= new Set<Id>();
    
    if(Trigger.isDelete)
    {
        for(Asset asset : Trigger.old)
        {
            if(asset.AccountId!=null && asset.Status!='Customer Evaluation' && !asset.Trigger_Asset_Count_Status_on_Account__c)
            {
                acctIds.add(asset.AccountId);
            }
        }
    }
    else if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(Asset asset : Trigger.New)
        {
            if(asset.AccountId!=null && asset.Status!='Customer Evaluation' && !asset.Trigger_Asset_Count_Status_on_Account__c)
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
            if(asset.Status!='Customer Evaluation' )
            {
                if(!asset.Trigger_Asset_Count_Status_on_Account__c && (oldAsset.Contract_Number__c != asset.Contract_Number__c || oldAsset.Status != asset.Status ))
                {
                    if( asset.AccountId != null && !acctIds.contains(asset.AccountId))
                    {
                        acctIds.add(asset.AccountId);
                    }
                }
                if(oldAsset.AccountId!=asset.AccountId )
                {
                    if(asset.AccountId != null && !acctIds.contains(asset.AccountId) && !asset.Trigger_Asset_Count_Status_on_Account__c)
                    {
                        acctIds.add(asset.AccountId);
                    }
                    if(oldAsset.AccountId != null && !acctIds.contains(oldAsset.AccountId) && !oldAsset.Trigger_Asset_Count_Status_on_Account__c)
                    {
                        acctIds.add(oldAsset.AccountId);
                    }
                }
            } 
        }
    }
    
    if(acctIds.size()>0)
    {
        AssetHelper.TriggerActiveAssetCount(acctIds);
    }
    
    
}