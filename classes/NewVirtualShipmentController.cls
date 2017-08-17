/**
* The controller class of NewVirtualShipment page.
*
* @author  Matt Yuan
* @created 4/15/2015
* @version 1.0
* @since   33.0
*
* @changelog
* 4/15/2015 Matt Yuan - Created.
*/

public with sharing class NewVirtualShipmentController
{
    private Asset_mac__c am;        
    private Shipment__c shipmentRecord;
    private List<Product2> products;     
    
    public NewVirtualShipmentController(ApexPages.StandardController std)
    {
        String poId = ApexPages.currentPage().getParameters().get('poId');
        shipmentRecord = (Shipment__c)std.getRecord();
        TempAsset = new Asset();
        PoOpp = null;
        List<Purchase_Order__c> purchaseOrders = [SELECT Id, Name, Email_Contact__c, Opportunity__r.Account.Id, Opportunity__c FROM Purchase_Order__c WHERE Id = :poId];
        if(purchaseOrders.size() <= 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Fatal, 'You need to select a Purchase Order.'));
            PO = null;
        }
        else
        {
            PO = purchaseOrders[0];
            shipmentRecord.Shipment_Account__c = PO.Opportunity__r.AccountId;
            shipmentRecord.Shipment_Contact__c = PO.Email_Contact__c;
            shipmentRecord.PurchaseOrder__c = PO.Id;
            shipmentRecord.IsVirtualShipment__c=true;
            if(PO.Opportunity__c != null && !Test.isRunningTest())
            {
                PoOpp = [select Id, Contract_Activation_Date__c, SBQQ__Contracted__c from Opportunity where Id = :PO.Opportunity__c];
                originalActivationDate = PoOpp.Contract_Activation_Date__c;
                if(PoOpp.Contract_Activation_Date__c == null)
                {
                    PoOpp.Contract_Activation_Date__c = Date.today();
                }   
            }       
        }
        
        AssetLines = new List<VirtualAssetManager.VirtualAsset>();
        addLine();
    }
    
    public Purchase_Order__c PO { get; set; }
    public Asset TempAsset { get; set; }
    public Opportunity PoOpp { get; set; }
    public Date originalActivationDate { set; get; }
    public List<VirtualAssetManager.VirtualAsset> AssetLines { get; set; }
    
    private Map<Id,String> ECProductIds {
        get{
            Map<Id,String> ecProdIds= new Map<Id,String>();
            try
            {
                List<Product2> productList=[Select Id,Name from Product2 where Name like 'EC%' and Family='Virtual Image' and Product2.Product_Type__c ='EDGECONNECT' ];
                for(Product2 prod : productList)
                {
                    ecProdIds.put(prod.Id,prod.Name);
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
            return ecProdIds;            
        }
    }
    private Map<Id,String> SPProductIds {
        get{
            Map<Id,String> spProdIds= new Map<Id,String>();
            try
            {
                List<Product2> productList=[Select Id,Name from Product2 where Name like 'EC%' and Family='Virtual Image' and Product2.Product_Type__c in('EC-SP-Perpetual','EC-SP-Term') ];
                for(Product2 prod : productList)
                {
                    spProdIds.put(prod.Id,prod.Name);
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                return null;
            }
            return spProdIds;            
        }
    }
    public List<Product2> ProductsList
    {
        get
        {
            if(products == null)
            {
                products = new List<Product2>();
                for(Product2 product : [SELECT Id, Name, ProductCode FROM Product2 WHERE Name != null AND Forecast_Category__c = 'Virtual' AND Family in ('Virtual Image', 'Service') AND IsActive = true ORDER BY Name])
                {
                    if(!product.Name.containsIgnoreCase('renewal'))
                    {
                        products.add(product);
                    }
                }
            }
            return products;
        }
    }
    
    //Adds a new asset line.
    public PageReference addLine()
    {    
        VirtualAssetManager.VirtualAsset newAssetInfo = new VirtualAssetManager.VirtualAsset();
        newAssetInfo.Asset = new Asset(Evaluation_Start_Date__c = Date.today(),Evaluation_End_Date__c = Date.today());
        //newAssetInfo.License = new License__c();
        AssetLines.add(newAssetInfo);
        return null;
    }
    
    //Removes a specified line
    public PageReference removeLine()
    {
        String rowIndex = ApexPages.currentPage().getParameters().get('rowIndex');
        try
        {
            Integer index = Integer.valueOf(rowIndex);
            /*if(index>0)
            {
                index=index-1;
            }*/
            AssetLines.remove(index);
        }
        catch(Exception ex)
        {}
        return null;
    }
    
    public PageReference save()
    {
        if(TempAsset.ContactId == null || shipmentRecord.Shipment_Account__c == null || shipmentRecord.Shipment_Contact__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select Account and Contact.'));
            return null;
        }
        if(!ValidateEndDatesForEdgeConnect())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Dates must match for all the EdgeConnect products.'));  
            return null;
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            if( POOpp != null && POOpp.Contract_Activation_Date__c != originalActivationDate)
            {
                POOpp.SBQQ__Contracted__c = true;
                update POOpp;
            }
            shipmentRecord.SendTrackingInformation__c = false;
            insert shipmentRecord;              
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
        String poNumber = (PO == null) ? null : PO.Name;
        List<VirtualAssetManager.VirtualAsset> extendAssets = new List<VirtualAssetManager.VirtualAsset>();
        
        List<Asset> updateExistingECAssets = new List<Asset>();
        // Retreive the EdgeConnect Asset Product Id and Asset Id.
        Map<string,Asset> lstExistingECAssets= RetreiveExistingAssetInfo(shipmentRecord.Shipment_Account__c);
        List<VirtualAssetManager.VirtualAsset> insertAssetLines = new List<VirtualAssetManager.VirtualAsset>();
        List<VirtualAssetManager.VirtualAsset> updateAssetLines = new List<VirtualAssetManager.VirtualAsset>();
        
        
        for(VirtualAssetManager.VirtualAsset virtualAsset : AssetLines)
        {  
            
            // If the Product selected is in the lstExistingECAssets, then we dont have to create a new asset. Simply add it to the existing assets.
            // for an Add o
            string updatedECProductName=ExcludeYearFromProduct(ECProductIds.get(virtualAsset.Asset.Product2Id));
            //string tobeUpdatedECProductName=lstExistingECAssets.c(virtualAsset.Asset.Product2Id);
            if(lstExistingECAssets!=null && lstExistingECAssets.containsKey(updatedECProductName))
            {
                
                Asset currAsset= lstExistingECAssets.get(updatedECProductName);
                VirtualAssetManager.VirtualAsset vasset= new VirtualAssetManager.VirtualAsset();
                vasset.Asset = currAsset;
                vasset.Asset.Evaluation_End_Date__c= virtualAsset.Asset.Evaluation_End_Date__c;
                if(currAsset.Product2.Name.contains('EC-ORCH'))
                {
                    vasset.Asset.Evaluation_End_Date__c=null;
                }
                
                vasset.Asset.ContactId = TempAsset.ContactId;
                
                if(currAsset.Product2.Name.contains('EC-BASE')|| currAsset.Product2.Name.contains('EC-PLUS')|| currAsset.Product2.Name.contains('EC-MINI'))
                {
                    vasset.Asset.EC_Old_Node_Count__c=currAsset.Licenses_Nodes__c;
                    vasset.Asset.Licenses_Nodes__c = (currAsset.Licenses_Nodes__c + virtualAsset.Asset.Licenses_Nodes__c) ;
                }
                if(currAsset.Product2.Name.contains('EC-BOOST'))
                {
                    vasset.Asset.EC_Old_Node_Count__c=currAsset.Bandwidth_Nodes__c;
                    vasset.Asset.Bandwidth_Nodes__c = (currAsset.Bandwidth_Nodes__c + virtualAsset.Asset.Bandwidth_Nodes__c) ;
                }
                updateAssetLines.add(vasset);
                
            }
            else
            {
                virtualAsset.Asset.AccountId = shipmentRecord.Shipment_Account__c;
                virtualAsset.Asset.ContactId = TempAsset.ContactId;
                virtualAsset.Asset.Shipment_Contact__c = shipmentRecord.Shipment_Contact__c;
                virtualAsset.Asset.PONumber__c = poNumber;
                virtualAsset.Asset.Reference__c = TempAsset.Reference__c;
                virtualAsset.Asset.End_Customer__c = TempAsset.End_Customer__c;
                virtualAsset.Asset.Term__c = TempAsset.Term__c;
                if(ECProductIds!=null && ECProductIds.size()>0 && ECProductIds.containsKey(virtualAsset.Asset.Product2Id))
                {
                    virtualAsset.Asset.Status='Customer Subscription Active';
                    virtualAsset.Asset.EC_Product_Name__c=ExcludeYearFromProduct(ECProductIds.get(virtualAsset.Asset.Product2Id));
                }
                //If the EC Orchestrator is selected, then hardcode the GMS Nodes to 10000
                if(ECProductIds!=null && ECProductIds.size()>0 && ECProductIds.containsKey(virtualAsset.Asset.Product2Id) &&  ECProductIds.get(virtualAsset.Asset.Product2Id) =='EC-ORCH' )
                {
                    virtualAsset.Asset.GMS_Nodes__c = '100000';
                    virtualAsset.Asset.Evaluation_End_Date__c = null;  
                }
                if(virtualAsset.Asset.Quantity == null)
                {
                    virtualAsset.Asset.Quantity = 1;
                }
                if(virtualAsset.Asset.Status == 'Customer Owned')
                {
                    virtualAsset.Asset.Evaluation_End_Date__c = null;      
                }
                
                //creates the specified quantity of assets
                if(virtualAsset.Asset.Quantity > 1)
                {
                    for(Integer i = 0; i < Integer.valueOf(virtualAsset.Asset.Quantity)-1; i++)
                    {
                        VirtualAssetManager.VirtualAsset newVirtualAsset = new VirtualAssetManager.VirtualAsset();
                        newVirtualAsset.Asset = virtualAsset.Asset.Clone(false, false, false, false);
                        //newVirtualAsset.License = virtualAsset.License.Clone(false, false, false, false);
                        extendAssets.add(newVirtualAsset);
                    }
                }
                insertAssetLines.Add(virtualAsset);
                
            }
        }
        
        //Update the assets for EC
        if(updateAssetLines!=null && updateAssetLines.size()>0)
        {
            try
            {
                
                //update updateAssetLines.Asset;
                VirtualAssetManager manager = new VirtualAssetManager();
                manager.VirtualAssets=updateAssetLines;
                Boolean succeeded = manager.updateECAssets();
                System.debug('Assets created');
                if(!succeeded)
                {
                    Database.rollback(sp);
                    return null;
                }
                else
                {
                    
                    InsertShippedLineRecords(shipmentRecord.Id, updateAssetLines);
                }
                
            }
            catch(DmlException ex)
            {
                System.debug(ex);
                ApexPages.addMessages(ex);
                Database.rollback(sp);
                return null;
            }  
        }
        
        insertAssetLines.addAll(extendAssets);
        if(insertAssetLines.size()>0)
        {
            for(VirtualAssetManager.VirtualAsset virtualAsset : insertAssetLines)
            {
                virtualAsset.Asset.Quantity = 1;
            }
            VirtualAssetManager manager = new VirtualAssetManager();
            manager.VirtualAssets = insertAssetLines;
            Boolean succeeded = manager.nameRankSerial();
            if(!succeeded)
            {
                Database.rollback(sp);
                return null;
            }
            else
            {
                succeeded = manager.updatesAssets();
            }
            if(!succeeded)
            {
                Database.rollback(sp);
                return null;
            }
            
            //Inserts ShippedLine records.
            try
            {
                InsertShippedLineRecords(shipmentRecord.Id, insertAssetLines);
            }
            catch(DmlException ex)
            {
                ApexPages.addMessages(ex);
                Database.rollback(sp);
                return null;
            }  
            
            //needs to set eval date on Asset to blank, said by Curtis
            List<Asset> createdAssets = new List<Asset>();
            for(VirtualAssetManager.VirtualAsset virtualAsset : insertAssetLines)
            {
                virtualAsset.Asset.Ship_Date__c = Date.today();
                virtualAsset.Asset.Evaluation_Start_Date__c = null;
                virtualAsset.Asset.Evaluation_End_Date__c = null;
                createdAssets.add(virtualAsset.Asset);
            }
            try
            {
                update createdAssets;
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                Database.rollback(sp);
                return null;
            }
            
            manager.willEncryptLicenses();
        }
        List<Asset> nullifyEvalUpdatedAssets = new List<Asset>();
        if(updateAssetLines!=null && updateAssetLines.size()>0)
        {
            for(VirtualAssetManager.VirtualAsset virtualAsset : updateAssetLines)
            {
                
                virtualAsset.Asset.Evaluation_End_Date__c = null;
                nullifyEvalUpdatedAssets.add(virtualAsset.Asset);
            }
        }
        try
        { 
            UpdateLicensesForEdgeConnectAssets(shipmentRecord.Id,shipmentRecord.Shipment_Account__c );
            if(nullifyEvalUpdatedAssets.size()>0){ update nullifyEvalUpdatedAssets;}
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
            return null;
        }
        
        PageReference resultPage = new PageReference('/' + shipmentRecord.Id);
        return resultPage;      
    }    
    private  boolean ValidateEndDatesForEdgeConnect()
    {
        Set<Date> setDates= new Set<Date>();
        for(VirtualAssetManager.VirtualAsset virtualAsset : AssetLines)
        {
            if(ECProductIds.containsKey(virtualAsset.Asset.Product2Id) && ECProductIds.get(virtualAsset.Asset.Product2Id) !='EC-ORCH')
            {
                setDates.add(virtualAsset.Asset.Evaluation_End_Date__c);
            }
        }
        System.debug('setDates'+ setDates.size());
        if(setDates.size()>0 && setDates.size()>1)
        {
            return false;
        }
        return true;
    }
    private static void UpdateLicensesForEdgeConnectAssets(Id shipmentId, Id accountId)
    {
        List<Asset> lstAssetsinShipment= [Select Id,license_End_Date__c from Asset where status='Customer Subscription Active' and Product2.Family='Virtual Image' and Product2.Name like 'EC-%' and Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c=: shipmentId)];
        System.debug('Shipment ID '+ shipmentId);
        System.debug('Account ID ' +accountId);
        System.debug('Assets in Shipment '+ lstAssetsinShipment.size());
        Date  newLicenseEndDate =null;
        List<License__c> lstLicenses= new List<License__c>();
        Set<Id> assetIds = new Set<Id>();
        if(lstAssetsinShipment!=null && lstAssetsinShipment.size()>0)
        {
            newLicenseEndDate = lstAssetsinShipment[0].license_End_Date__c;
            assetIds= (new Map<Id,Asset>(lstAssetsinShipment)).keySet();
            List<Asset> assetsToUpdate= new List<Asset>();
            assetsToUpdate=[Select Id, (Select Id,Name,License_Expiration__c from licenses__r ) from Asset where  AccountId =: accountId and Product2.Family='Virtual Image' and Product2.Name like 'EC-%' and status='Customer Subscription Active' and (not Id in:assetIds) and (NOT Product2.Name ='EC-ORCH')];
            System.debug('Assets not in Shipment '+ assetsToUpdate.size());
            if(assetsToUpdate.size()>0) 
            {
                for(Asset item: assetsToUpdate)
                {
                    
                    List<License__c> licenseItem = item.Licenses__r;
                    if(licenseItem!=null && licenseItem.size()>0)
                    {
                        
                        License__c license=licenseItem[0];
                        license.License_Expiration__c= newLicenseEndDate;
                        lstLicenses.add(license);                
                        
                    }
                }
                System.debug('Licenses  '+ lstLicenses.size());
                
                if(lstLicenses!=null && lstLicenses.size()>0)
                {
                    update lstLicenses;
                }
            }
        }
    }
    private static void InsertShippedLineRecords(Id shipmentRecordId,List<VirtualAssetManager.VirtualAsset> assetLines)
    {
        //Inserts ShippedLine records.
        List<Shipped_Line__c> shippedLineList = new List<Shipped_Line__c>();
        for(VirtualAssetManager.VirtualAsset assetInfo : assetLines)
        {
            shippedLineList.add(new Shipped_Line__c(Asset__c = assetInfo.Asset.Id, 
                                                    Shipment_Id__c = shipmentRecordId, 
                                                    Ship_Date__c=Date.today(), 
                                                    Eval_End__c=assetInfo.Asset.Evaluation_End_Date__c, 
                                                    Eval_Start__c=assetInfo.Asset.Evaluation_Start_Date__c, 
                                                    Prior_Status__c=assetInfo.Asset.Status));
        }
        insert shippedLineList;
        
    }
    
    // This method returns all the EC  shipments.
    private static Map<string,Asset> RetreiveExistingAssetInfo(Id shipmentAccountId)
    {
        
        Map<string,Asset> mapAssetItems = new Map<string,Asset>();   
        
        List<Id>productIds = new List<Id>();
        List<Product2> ecProducts= [Select Id from Product2 where Name like 'EC-%' and Family='Virtual Image' and Product_Type__c='EDGECONNECT'];
        
        for(Product2 prod :ecProducts)
        {
            productIds.Add(prod.Id);
        }
        //Purchase_Order__c purchaseOrder= [Select Id from Purchase_Order__c where Name=:poNumber LIMIT 1];
        //Account acc= Select Id from Account where Name
        //if(purchaseOrder!=null)
        // {
        //List<Shipped_Line__c> lstAssetInPONumber= [Select Asset__c from Shipped_Line__c where Shipment_Id__c in(Select Id from Shipment__C where PurchaseOrder__c =:purchaseOrder.Id)];
        List<Shipped_Line__c> lstAssetInAccount= [Select Asset__c from Shipped_Line__c where Shipment_Id__c in(Select Id from Shipment__c where Shipment_Account__c =:shipmentAccountId)];
        List<Id>assetIds = new List<Id>();
        for(Shipped_Line__c shippedLineItem :lstAssetInAccount)
        {
            assetIds.Add(shippedLineItem.Asset__c);
        } 
        List<Asset> lstAssets= [Select Id,Product2Id,Product2.Name,Quantity,Bandwidth_Nodes__c,Licenses_Nodes__c,Status from Asset where Id in :assetIds and status='Customer Subscription Active' and Product2Id in :productIds];
        for(Asset assetItem :lstAssets)
        {
            mapAssetItems.put(ExcludeYearFromProduct(assetItem.Product2.Name), assetItem);
        }
        // }
        
        return mapAssetItems;
    }
    
    public static string ExcludeYearFromProduct(string inputData)
    {
        if(inputData!=null)
        {
            integer idx= inputData.lastIndexOf('-');
            string text=inputData.substring(idx+1,inputData.length());
            if(GetYearsFromString(text)>0)
                return inputData.substring(0,idx);
            else
                return inputData;
        }  
        
        return '';
    }
    
    public static integer GetYearsFromString(string inputData)
    {
        integer outputNumber=0;
        
        Pattern p = Pattern.compile('(\\d+)Y');
        Matcher pm = p.matcher( inputData );
        
        if(pm!=null && pm.matches() ){
            if(pm.groupCount()>0)
            {
                outputNumber =integer.valueOf(pm.group(1));
            }
        }
        return outputNumber;
    }
    
    public PageReference cancel()
    {
        PageReference pageResult = new PageReference('/' + PO.Id);
        return pageResult;             
    }
}