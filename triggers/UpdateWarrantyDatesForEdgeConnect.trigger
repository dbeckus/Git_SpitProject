trigger UpdateWarrantyDatesForEdgeConnect on Asset (after insert,after update) {
    Set<Id> assetIds= new Set<Id>();
    
    for(Asset toUpdateAsset: Trigger.New)
    {
        if(Trigger.isInsert)
        {
            assetIds.add(toUpdateAsset.Id);
        }
        else if(Trigger.isUpdate)
        {
            
            Asset oldAsset = Trigger.oldMap.get(toUpdateAsset.Id);
            if(toUpdateAsset.Product2Id!=oldAsset.Product2Id  || toUpdateAsset.Ship_Date__c != oldAsset.Ship_Date__c)
            {
                assetIds.add(toUpdateAsset.Id);
            }         
        }
        
    }
    if(!assetIds.isEmpty())
    {
        
        List<Asset> finalAssets= new List<Asset>();
        List<Asset> lstAssets = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id in: assetIds  and Product2.Family ='Product' and Product2.Name like 'EC%'];
        integer yearsCounter=0;
        for(Asset newAsset: lstAssets)
        {
            if(newAsset.Ship_Date__c!=null)
            {
                newAsset.Warranty_Start_Date__c = newAsset.Ship_Date__c;
                newAsset.End_of_Software_Support__c= newAsset.Ship_Date__c.addYears(5);
                yearsCounter=  GetYearsFromString(newAsset.product2.Name);
                newAsset.Warranty_End_Date__c = newAsset.Warranty_Start_Date__c.addYears(yearsCounter); 
                finalAssets.add(newAsset);
            }
        }   
        if(finalAssets.size()>0)
        {update finalAssets;}
        
    }
    
    public static integer GetYearsFromString(string inputData)
    {
        integer outputNumber=1;        
        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(inputData);
        while(m.find()) {
            outputNumber=integer.valueOf(m.group());
        }
        return outputNumber;
    }
}