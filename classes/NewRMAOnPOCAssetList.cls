/**
 * called by 'Open RMA' button on POC Request page
 */
global class NewRMAOnPOCAssetList
{
    webService static String createRma(String assetIds)
    {
        String message;
        Set<String> assetIdsInSet = new Set<String>();
        if(assetIds != null)
        {
            assetIdsInSet.addAll(assetIds.replaceAll('\'', '').split(','));
        }
        if(assetIdsInSet.size() > 0)
        {
            List<Asset> assets = [select Id, Contact.email, POCRequest__r.Name, POCRequest__r.POC_Contact__c, POCRequest__r.Evaluation_Product_1__c, POCRequest__r.Ship_To_Location_1__c, AccountId from Asset where Id in :assetIdsInSet];
            Id RmaRecordTypeId = [select Id from RecordType where Name = 'Eval RMA' and SobjectType = 'RMA__c' limit 1].Id;
            
            if(assets.size() > 0)
            {
                RMA__c rma =  new RMA__c();
                rma.Type__c = 'Eval Return';
                rma.RecordTypeId = RmaRecordTypeId;
                rma.Request__c = assets[0].POCRequest__r.Id;
                rma.Status__c = 'Initiated';
                rma.Account__c = assets[0].AccountId;
                rma.Contact_Loc_1__c = assets[0].POCRequest__r.POC_Contact__c;
				rma.Contact_Email_Loc_2__c = assets[0].contact.email;
                rma.Product__c = assets[0].POCRequest__r.Evaluation_Product_1__c; 
                rma.Address1__c = assets[0].POCRequest__r.Ship_To_Location_1__c;
            
                Savepoint sp = Database.setSavepoint();
                try
                {   
                    upsert Rma;
                }
                catch(Exception ex)
                {
                    throw(ex);
                }
                
                List<RMA_Item__c> items = new List<RMA_Item__c>();
                Id itemRecordTypeId = [select Id from RecordType where Name='Eval Return' and SobjectType='RMA_Item__c' limit 1].Id;
                
                for(Asset asset : assets)
                {
                    RMA_Item__c item = new RMA_Item__c();
                    item.RMA__c = Rma.Id;
                    item.Asset__c = asset.Id;
                    item.Type__c = 'Return - Refurbish and Stock';
                    item.Status__c = 'Not Dispatched';
                    item.RecordTypeId = itemRecordTypeId; 
                    items.add(item);
					asset.Status = 'Pending Return – Eval';
					asset.Evaluation_End_Date__c = Date.today();

                } 
                try
                {
                    insert items;
					update assets;
                }
				catch(Exception ex)
				{
					Database.rollback(sp); 
					throw(ex);
				}
                message = 'The RMA was created.';
            }
        }
        return message;
    }
    
    @isTest
    static void testNewRmaOnPocAssetList()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id, Email='acme@acme.com');
        insert con;
        Product2 pro = new Product2(Name='acme');
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        String message;
        message = NewRMAOnPOCAssetList.createRma(asset.Id);
        System.assertEquals(message, 'The RMA was created.');
        //message = NewRMAOnPOCAssetList.createRma(asset.Id);
        //System.assertEquals(message, 'Failed to create RMA. One or more items already existed. Asset Name:acme;');
    }
}