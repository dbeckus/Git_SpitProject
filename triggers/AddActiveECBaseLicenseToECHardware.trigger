trigger AddActiveECBaseLicenseToECHardware on Asset (after insert, after update) {
    Set<Id> assetIds= new Set<Id>();
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
    if(assetIds.size()>0)
    {
        for(Asset toUpdateAsset:[Select Id,Product2Id,Product2.Product_Category__c,Product2.Name,Product2.Family,AccountId,Active_EC_Base_License__c from Asset where Id in: assetIds and Product2.Name like 'EC%'])
        {
            if(toUpdateAsset.Product2.Product_Category__c=='Appliance' && toUpdateAsset.Product2.Family=='Product')
            {
                
                hardwareECAssetIds.put(toUpdateAsset.Id,toUpdateAsset.AccountId);
            }
            
            if(toUpdateAsset.Product2.Product_Category__c=='Subscription' && toUpdateAsset.Product2.Family=='Virtual Image' && toUpdateAsset.Product2.Name.startsWith('EC-BASE' ))
            {
                softwareECBaseAssetIds.put(toUpdateAsset.Id,toUpdateAsset.AccountId);
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
                List<Asset> lstBaseLicenses= [Select Id from Asset where AccountId=:acctId and Product2.Family='Virtual Image' and Status in('Customer subscription Active','Customer Evaluation') and Product2.Name like 'EC-BASE-%' order by CreatedDate desc];
                if(lstBaseLicenses!=null && lstBaseLicenses.size()>0)
                {
                    hardwareAssetToUpdate = new Asset(Id=assetId,Active_EC_Base_License__c=lstBaseLicenses[0].Id);
                    lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                }
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
                Id acctId= softwareECBaseAssetIds.get(assetId);
                Set<Id> ids = (new Map<Id, Asset>([Select Id from Asset where AccountId=:acctId and Product2.Family='Product' and Product2.Name like 'EC-%' order by CreatedDate desc])).keySet();
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