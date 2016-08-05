/**
 *  Called by the Open RMA buttons.
 */

global class NewRMAHelper
{
    /**
     * A valid asset is status != 'Pending Return - xxx' and not in another RMA.
     */
    webService static String getValidAssetIds(String assetIdsStr)
    {
        String validAssetIds = '';
        Set<String> assetIds = splitAssetIds(assetIdsStr);
        assetIds = removeInvalidAssets(assetIds);
        if(!assetIds.isEmpty())
        {
            for(String assetId : assetIds)
            {
                validAssetIds += assetId;
                validAssetIds += ',';
            }
        }
        return validAssetIds;
    }
    
    webService static Boolean createRmaOnPOC(String assetIdsStr)
    {
        Set<String> assetIds = splitAssetIds(assetIdsStr);
        return createRmaWithAssetStatus(assetIds, null, 'Pending Return – Eval');
    }
    
    public static Boolean createRmaWithAssetStatus(Set<String> assetIds, String contactId, String assetStatus)
    {
        List<Asset> assets = [select Id, Product2Id, Contact.Email, POCRequest__r.Name, POCRequest__r.POC_Contact__c, POCRequest__r.Evaluation_Product_1__c, POCRequest__r.Ship_To_Location_1__c, AccountId from Asset where Id in :assetIds];
        if(!assets.isEmpty())
        {
            RMA__c rma = getNewRMA(assets[0], contactId);
            Savepoint sp = Database.setSavepoint();
            try
            {   
                upsert rma;
            }
            catch(Exception ex)
            {
                throw(ex);
            }
            
            List<RMA_Item__c> rmaItems = new List<RMA_Item__c>();
            Id rmaItemRecordTypeId = [select Id from RecordType where Name = 'Eval Return' and SobjectType = 'RMA_Item__c' limit 1].Id;
            for(Asset asset : assets)
            {
                RMA_Item__c rmaItem = getNewRMAItem(rma.Id, asset.Id, asset.Product2Id, rmaItemRecordTypeId);
                rmaItems.add(rmaItem);
                asset.Status = assetStatus;
                asset.Evaluation_End_Date__c = Date.today();
            }
            
            try
            {
                insert rmaItems;
                update assets;
                return true;
            }
            catch(Exception ex)
            {
                Database.rollback(sp); 
                throw(ex);
            }
        }
        return false;
    }
    
    public static Set<String> splitAssetIds(String assetIdsStr)
    {
        Set<String> assetIds = new Set<String>();
        if(assetIdsStr != null)
        {
            assetIds.addAll(assetIdsStr.replaceAll('\'', '').split(','));
        }
        return assetIds;
    }
    
    /**
     * Removes the selected assets that can't create RMA.
     */
    private static Set<String> removeInvalidAssets(Set<String> assetIds)
    {
        for(Asset asset : [select Id from Asset where Id in :assetIds and Status like '%Pending Return%'])
        {
            assetIds.remove(String.valueOf(asset.Id).substring(0,15));
        }
        for(RMA_Item__c rmaItem : [select Asset__c from RMA_Item__c where Asset__c in :assetIds and status__c <> 'Received'])
        {
            assetIds.remove(String.valueOf(rmaItem.Asset__c).substring(0,15));
        } 
        return assetIds;
    }
    
    private static RMA__c getNewRMA(Asset asset, String contactId)
    {
        RMA__c rma =  new RMA__c();
        Id rmaRecordTypeId = [select Id from RecordType where Name = 'Eval RMA' and SobjectType = 'RMA__c' limit 1].Id;
        rma.RecordTypeId = rmaRecordTypeId;
        rma.Type__c = 'Eval Return';
        rma.Status__c = 'Initiated';
        rma.Request__c = asset.POCRequest__r.Id;
        rma.Account__c = asset.AccountId;
        rma.Contact__c = contactId;
        rma.Contact_Email_Loc_2__c = asset.Contact.Email;
        rma.Contact_Loc_1__c = asset.POCRequest__r.POC_Contact__c;
        rma.Product__c = asset.POCRequest__r.Evaluation_Product_1__c; 
        rma.Address1__c = asset.POCRequest__r.Ship_To_Location_1__c;
        return rma;
    }
    
    private static RMA_Item__c getNewRMAItem(String rmaId, String assetId, String productId, String recordTypeId)
    {
        RMA_Item__c rmaItem = new RMA_Item__c();
        rmaItem.RMA__c = rmaId;
        rmaItem.Asset__c = assetId;
        rmaItem.Product2__c = productId;
        rmaItem.Type__c = 'Return - Refurbish and Stock';
        rmaItem.Status__c = 'Awaiting Return';
        rmaItem.RecordTypeId = recordTypeId;
        return rmaItem;
    }
    
    @isTest
    static void testGetValidAssetIds()
    {
        List<Asset> assets = createTestAssets();
        Asset asset1 = assets[0];
        Asset asset2 = assets[1];
        String assetIds = String.valueOf(asset1.Id).subString(0,15) + ',' + String.valueOf(asset2.Id).subString(0,15);
        
        //Success.
        System.assertNotEquals('', NewRMAHelper.getValidAssetIds(assetIds));
        
        //Tests when the status of asset is Pending Return.
        asset1.Status = 'Pending Return - Eval';
        update asset1;
        System.assertNotEquals('', NewRMAHelper.getValidAssetIds(assetIds));
        asset2.Status = 'Pending Return - CPO';
        update asset2;
        System.assertEquals('', NewRMAHelper.getValidAssetIds(assetIds));
        
        //Tests when asset is on an RMA.
        asset2.Status = 'Conditional PO';
        update asset2;
        Id rmaRecordTypeId = [select Id from RecordType where Name = 'Eval RMA' and SobjectType = 'RMA__c' limit 1].Id;
        RMA__c rma =  new RMA__c(Type__c = 'Eval Return', Status__c = 'Initiated', Account__c = asset1.AccountId, RecordTypeId = rmaRecordTypeId);
        insert rma;
        Id rmaItemRecordTypeId = [select Id from RecordType where Name = 'Eval Return' and SobjectType = 'RMA_Item__c' limit 1].Id;
        RMA_Item__c rmaItem = new RMA_Item__c(RMA__c = rma.Id, Asset__c = asset1.Id, Type__c = 'Return - Refurbish and Stock', Status__c = 'Not Dispatched', RecordTypeId = rmaItemRecordTypeId);
        insert rmaItem;
        System.assertNotEquals('', NewRMAHelper.getValidAssetIds(assetIds));
        rmaItem.Asset__c = asset2.Id;
        update rmaItem;
        System.assertEquals('', NewRMAHelper.getValidAssetIds(assetIds));
    }
    
    @isTest
    static void testCreateRMAOnPOC()
    {
        List<Asset> assets = createTestAssets();
        Asset asset1 = assets[0];
        Asset asset2 = assets[1];
        String assetIds = String.valueOf(asset1.Id).subString(0,15) + ',' + String.valueOf(asset2.Id).subString(0,15);
        
        system.assertEquals(true, NewRMAHelper.createRMAOnPOC(assetIds));
    }
    
    public static List<Asset> createTestAssets()
    {
        Account acc = new Account(Name = 'acme', Type = 'Eval');
        insert acc;
        Contact con = new Contact(LastName = 'acme', AccountId = acc.Id, Email = 'acme@acme.com');
        insert con;
        Product2 prd = new Product2(Name = 'acme');
        insert prd;
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(Name = 'acme1', SerialNumber = 'acme1', Quantity = 1.00, Status = 'Conditional PO', Product2Id = prd.Id, AccountId = acc.Id, ContactId = con.Id);
        Asset asset2 = new Asset(Name = 'acme2', SerialNumber = 'acme2', Quantity = 1.00, Status = 'Conditional PO', Product2Id = prd.Id, AccountId = acc.Id, ContactId = con.Id);
        assets.add(asset1);
        assets.add(asset2);
        insert assets;
        return assets;
    }
}