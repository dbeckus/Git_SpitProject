/* 
 * Updates the EOM date according to ship date configured in custom setting
 */
trigger UpdateEOM on Asset (before insert, before update) 
{
    List<Asset> assets = new List<Asset>();
    List<EOMDate__c> EOMDates = [select Model__c, EOMDate__c, ShipDate__c from EOMDate__c];
    for(Asset asset : Trigger.new)
    {
        if(Trigger.isInsert)
        {
            if(asset.End_of_Maintenance__c == null)
            {
                assets.add(asset);
            }
        }
        else if(Trigger.isUpdate)
        {
            Asset oldAsset = Trigger.oldMap.get(asset.Id);
            if(asset.Ship_Date__c != oldAsset.Ship_Date__c)
            {
                assets.add(asset);
            }            
        }
    }
    
    for(Asset asset : assets)
    {
        Date minEomDate = Date.newInstance(3000, 01, 01);
        List<EOMDate__c> assetEOMs = new List<EOMDate__c>();
        for(EOMDate__c eom : EOMDates)
        {
            if(asset.Model__c == eom.Model__c && asset.Ship_Date__c < eom.ShipDate__c)
            {
                if(minEomDate > eom.EOMDate__c)
                {
                    minEomDate = eom.EOMDate__c;
                }
            }
        }
        asset.End_of_Maintenance__c = (minEomDate == Date.newInstance(3000, 01, 01) ? null : minEomDate);
    }
}