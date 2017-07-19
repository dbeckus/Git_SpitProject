trigger TriggerActiveAssetCountFromAsset on Asset (after insert,after delete, after undelete, after update) {
    Set<Id> acctIds= new Set<Id>();
   
    if(Trigger.isDelete)
    {
        for(Asset asset : Trigger.old)
        {
            if(asset.AccountId!=null && asset.Status!='Customer Evaluation')
            {
                acctIds.add(asset.AccountId);
            }
        }
    }
    else if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(Asset asset : Trigger.New)
        {
            if(asset.AccountId!=null && asset.Status!='Customer Evaluation')
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
            if(oldAsset.AccountId != asset.AccountId && asset.Status!='Customer Evaluation')
            {
                if(asset.AccountId != null && !acctIds.contains(asset.AccountId) )
                {
                    acctIds.add(asset.AccountId);
                }
                if(oldAsset.AccountId != null && !acctIds.contains(asset.AccountId) && oldAsset.Status!='Customer Evaluation' )
                {
                    acctIds.add(oldAsset.AccountId);
                }
            }
            if(oldAsset.Status != asset.Status && asset.Status!='Customer Evaluation')
            {
                if(asset.AccountId != null && !acctIds.contains(asset.AccountId) )
                {
                    acctIds.add(asset.AccountId);
                }
            }
            if(oldAsset.Contract_Number__c != asset.Contract_Number__c && asset.Status!='Customer Evaluation')
            {
                if(asset.AccountId != null && !acctIds.contains(asset.AccountId) )
                {
                    acctIds.add(asset.AccountId);
                }
            }
            
        }
    }
    
    if(acctIds.size()>0)
    {
        AssetHelper.TriggerActiveAssetCount(acctIds);
    }
    
  
}