trigger AddActiveECBaseLicenseToECHardware on Asset (after insert, after update) {
    Set<Id> assetIds= new Set<Id>();
    Set<Id> accountIds= new Set<Id>();
    Map<Id,Id> firstECBaseLicense= new  Map<Id,Id>();
    for(Asset asset: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            assetIds.add(asset.Id);
        }
        if(Trigger.IsUpdate)
        {
            Asset oldAsset= Trigger.OldMap.get(asset.Id);
            if(oldAsset.AccountId!=asset.AccountId)
            {
                assetIds.add(asset.Id);
            }
        }
    }
    Map<Id,Id> hardwareECAssetIds= new  Map<Id,Id>();
    Map<Id,Id> softwareECBaseAssetIds= new  Map<Id,Id>();
    Map<Id,string> hardwareECAssetStatus= new  Map<Id,string>();
    Map<Id,string> softwareECAssetStatus= new  Map<Id,string>();
    if(assetIds.size()>0)
    {
        for(Asset toUpdateAsset:[Select Id,Status,Product2Id,Product2.Product_Category__c,Product2.Name,Product2.Family,AccountId,Active_EC_Base_License__c from Asset where Id in: assetIds and Product2.Name like 'EC%' and Product2.Product_Type__c ='EDGECONNECT'])
        {
            accountIds.add(toUpdateAsset.AccountId);
            if(toUpdateAsset.Product2.Product_Category__c=='Appliance' && toUpdateAsset.Product2.Family=='Product')
            {
                hardwareECAssetIds.put(toUpdateAsset.Id,toUpdateAsset.AccountId);
                hardwareECAssetStatus.put(toUpdateAsset.Id,toUpdateAsset.Status);
            }
            
            if(toUpdateAsset.Product2.Product_Category__c=='Subscription' && toUpdateAsset.Product2.Family=='Virtual Image' && toUpdateAsset.Product2.Name.startsWith('EC-BASE' ))
            {
                softwareECBaseAssetIds.put(toUpdateAsset.Id,toUpdateAsset.AccountId);
                softwareECAssetStatus.put(toUpdateAsset.Id,toUpdateAsset.Status);
            }
            
        }
        List<Asset> lstHardwareAssetToUpdate=null;
        // Assign Base Software Base License to the Hardware asset
        if(hardwareECAssetIds.size()>0)
        {
            Asset hardwareAssetToUpdate=null;
            lstHardwareAssetToUpdate= new List<Asset>();
            for(Id assetId : hardwareECAssetIds.keySet())
            {
                Id acctId= hardwareECAssetIds.get(assetId);
                string hardwareStatus=hardwareECAssetStatus.get(assetId);
                string ecStatus='Customer Subscription Active';
                
                if(hardwareStatus=='Customer Evaluation')
                {
                    ecStatus='Customer Evaluation';
                }
                List<Asset> lstBaseLicenses=[Select Id,AccountId,Status from Asset where AccountId in:accountIds and Product2.Family='Virtual Image' and Status=:ecStatus and Product2.Name like 'EC-BASE-%' and Product2.Product_Type__c ='EDGECONNECT'];
                if(lstBaseLicenses!=null && lstBaseLicenses.size()>0)
                {
                    for(Asset item: lstBaseLicenses)
                    {
                        firstECBaseLicense.put(item.AccountId,item.Id);
                    }
                }
                hardwareAssetToUpdate = new Asset(Id=assetId,Active_EC_Base_License__c= firstECBaseLicense.containsKey(acctId)? firstECBaseLicense.get(acctId):null);
                lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                
            }
            if(lstHardwareAssetToUpdate.size()>0)
            {
                update lstHardwareAssetToUpdate;
            }
        }
        // If the EC BASE license is created, then assign this ID to all hardware asset
        if(softwareECBaseAssetIds.size()>0)
        {
            Asset hardwareAssetToUpdate=null;
            lstHardwareAssetToUpdate = new List<Asset>();
            for(Id assetId : softwareECBaseAssetIds.keySet())
            {
                string ecStatus='Customer Owned';
                Id acctId= softwareECBaseAssetIds.get(assetId);
                string softwareStatus=softwareECAssetStatus.get(assetId);
                if(softwareStatus=='Customer Evaluation')
                {
                    ecStatus='Customer Evaluation';
                }
                Set<Id> ids = (new Map<Id, Asset>([Select Id from Asset where AccountId=:acctId and Product2.Family='Product' and Status=:ecStatus and Product2.Name like 'EC-%' order by CreatedDate desc])).keySet();
                if(ids!=null && ids.size()>0)
                {
                    for(Id hardWareId : ids)
                    {
                        hardwareAssetToUpdate = new Asset(Id=hardWareId,Active_EC_Base_License__c=assetId);
                        lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                    }
                    
                }
            }
            if(lstHardwareAssetToUpdate.size()>0)
            {
                update lstHardwareAssetToUpdate;
            }
        }
    }
}