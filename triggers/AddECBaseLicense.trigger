trigger AddECBaseLicense on Asset (after insert,after update) {
    Map<Id,Id> hardwareECAssetIds= new  Map<Id,Id>();
    Map<Id,Id> softwareECBaseAssetIds= new  Map<Id,Id>();
    Set<Id> setAccIds=new Set<Id>();
    for(Asset asset: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Product_Family__c=='Product' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Owned'))
            {
                hardwareECAssetIds.put(asset.Id,asset.AccountId);
                setAccIds.add(asset.AccountId);
            }
            
            if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Product_Family__c=='Virtual Image' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Subscription Active'))
            {
                softwareECBaseAssetIds.put(asset.Id,asset.AccountId);
                setAccIds.add(asset.AccountId);
            }
            
        }
        if(Trigger.IsUpdate)
        {
            Asset oldAsset= Trigger.OldMap.get(asset.Id);
            if(oldAsset.AccountId!=asset.AccountId)
            {
                if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Product_Family__c=='Product' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Owned'))
                {
                    hardwareECAssetIds.put(asset.Id,asset.AccountId);
                    setAccIds.add(asset.AccountId);
                }
                
                if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Product_Family__c=='Virtual Image' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Subscription Active'))
                {
                    softwareECBaseAssetIds.put(asset.Id,asset.AccountId);
                    setAccIds.add(asset.AccountId);
                }
                
            }
        }
    }
    Map<string,Id> firstECBaseLicense= new  Map<string,Id>();
    if(hardwareECAssetIds.size()>0)
    {
        List<Asset> lstBaseLicenses=[Select Id,AccountId,Status from Asset where AccountId in:setAccIds and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Evaluation') and Product2.Name like 'EC-BASE-%' and Product2.Product_Type__c ='EDGECONNECT'];
        if(lstBaseLicenses!=null && lstBaseLicenses.size()>0)
        {
            for(Asset item: lstBaseLicenses)
            {
                firstECBaseLicense.put(item.AccountId+'|'+item.Status,item.Id);
            }
        }
        for(Id assetId : hardwareECAssetIds.keySet())
        {
            
        }
    }
    if(softwareECBaseAssetIds.size()>0)
    {
        for(Id assetId : softwareECBaseAssetIds.keySet())
        {
        }
    }
    
}