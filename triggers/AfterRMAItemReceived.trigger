/*
 * This trigger will update the asset details when unit on RMA line is marked received.
 */

trigger AfterRMAItemReceived on RMA_Item__c (after update)
{
    Set<Id> assetIds= new Set<Id>();
    for(RMA_Item__c rmaItem : [select Asset__c, Status__c from RMA_Item__c where Id in :trigger.NewMap.keyset() and Status__c = 'Received' and Product2__r.Product_Category__c in ('Appliance', 'GMS')]) //only for the system and not a replacement product.
    {
        if(rmaItem.Status__c != trigger.oldMap.get(rmaItem.Id).Status__c)
        {
            assetIds.add(rmaItem.Asset__c);
        }
    }
    
    if(!assetIds.isEmpty())
    {
        List<Account> accounts = [select Id from Account where Name = 'Silver Peak Systems' limit 1];
        Id silverPeakSystemId = (!accounts.isEmpty()) ? accounts[0].Id : null;
        
        List<Asset> assets = [select AccountId, ContactId, Status, Ship_To_Location__c, Description, GMS_Nodes__c, Installed_At_Location__c, Ship_Date__c, Warranty_Start_Date__c, Warranty_End_Date__c, Evaluation_Start_Date__c, Evaluation_End_Date__c, POCRequest__c from Asset where Id in :assetIds];
        for(Asset asset : assets)
        {
            asset.ContactId = null;
            asset.Status = 'Silver Peak Inventory';
            asset.Description = null;
            asset.Ship_To_Location__c = null;
            asset.Installed_At_Location__c = null;
            asset.Ship_Date__c = null;
            asset.Warranty_Start_Date__c = null;
            asset.Warranty_End_Date__c = null;
            asset.Evaluation_Start_Date__c = null;
            asset.Evaluation_End_Date__c = null;
            asset.End_of_Software_Support__c = null;
            asset.GMS_Nodes__c = null;
            asset.POCRequest__c = null;
            asset.Customer_Notes__c= null;
            if(silverPeakSystemId != null)
            {
                asset.AccountId = silverPeakSystemId;
            }
        }
        update assets;
    }
}