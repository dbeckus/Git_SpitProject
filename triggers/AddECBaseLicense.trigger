trigger AddECBaseLicense on Asset (after insert,after update) {
    Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
    Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
    Set<Id> setAccIds=new Set<Id>();
    for(Asset asset: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Product_Family__c=='Product' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Owned'))
            {
                hardwareECAssetIds.put(asset.Id,asset);
                setAccIds.add(asset.AccountId);
            }
            
            if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Model__c.startsWith('EC-BASE' ) && asset.Product_Family__c=='Virtual Image' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Subscription Active'))
            {
                softwareECBaseAssetIds.put(asset.Id,asset);
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
                    hardwareECAssetIds.put(asset.Id,asset);
                    setAccIds.add(asset.AccountId);
                }
                
                if(asset.Product_Quote_Type__c=='EDGECONNECT' && asset.Model__c.startsWith('EC-BASE' )&& asset.Product_Family__c=='Virtual Image' && (asset.Status=='Customer Evaluation' || asset.Status=='Customer Subscription Active'))
                {
                    softwareECBaseAssetIds.put(asset.Id,asset);
                    setAccIds.add(asset.AccountId);
                }
                
            }
        }
    }
    Map<string,Id> firstECBaseLicense= new  Map<string,Id>();
    List<Asset> lstHardwareAssetToUpdate=new List<Asset>();
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
        for(Id assetId :hardwareECAssetIds.keySet())
        {
            Asset assetData=hardwareECAssetIds.get(assetId);
            string status=assetData.Status=='Customer Evaluation'?'Customer Evaluation':'Customer Subscription Active';
            Id baseLicense= firstECBaseLicense.get(assetData.AccountId+'|'+status);
            Asset hardwareAssetToUpdate = new Asset(Id=assetId,Active_EC_Base_License__c=baseLicense);
            lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
        }
    }
    if(softwareECBaseAssetIds.size()>0)
    {
        for(Id assetId : softwareECBaseAssetIds.keySet())
        {
            Asset assetData=softwareECBaseAssetIds.get(assetId);
            string status='Customer Owned';
            if(assetData.Status=='Customer Evaluation')
                status='Customer Evaluation';
            Set<Id> ids = (new Map<Id, Asset>([Select Id from Asset where AccountId=:assetData.AccountId and Product2.Family='Product' and Status=:status and Product2.Product_Type__c like 'EDGECONNECT' order by CreatedDate desc])).keySet();
            if(ids!=null && ids.size()>0)
            {
                for(Id hardWareId : ids)
                {
                    Asset hardwareAssetToUpdate = new Asset(Id=hardWareId,Active_EC_Base_License__c=assetId);
                    lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                }
                
            }
        }
    }
    if(lstHardwareAssetToUpdate.size()>0)
    {
        update lstHardwareAssetToUpdate;
    }
}