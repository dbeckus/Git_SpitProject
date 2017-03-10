/*
* Controller for page ShippingInputForm and ShippingInputFormInternal
* ShippingInputFormInternal page is a slimmed version of ShippingInputForm with hard-coded account id.
*/
public class ShippingInputFormController
{    
    private static final String SP_Account_Id = '00130000007mEjX';  //"Silver Peak Systems" account for the internal shipment page.
    
    public ShippingInputFormController()
    {
        Shipment = new Shipment__c();
        ShippedLineList = new List<ShipLineInfo>();
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String pocId = ApexPages.currentPage().getParameters().get('pocId');
        String poId = ApexPages.currentPage().getParameters().get('poId');
        String currentUrl = ApexPages.currentPage().getUrl().toLowerCase();
        if(currentUrl.indexOf('?') > 0)
        {
            currentUrl = currentUrl.substring(0, currentUrl.indexOf('?'));
        }
        if(currentUrl.contains('/shippinginputforminternal'))
        {
            accountId = SP_Account_Id;
            Shipment.Shipment_Account__c = SP_Account_Id;
            Shipment.SendTrackingInformation__c = false;
        }
        else if(accountId != null && accountId != '')
        {
            List<Account> accounts = [Select Id, Name, (Select Id From Contacts), Owner.Email From Account where Id = :accountId limit 1];
            if(accounts.size() > 0)
            {
                Shipment.Shipment_Account__c = accounts[0].Id;
                Shipment.SendTrackingInformation__c = true;
            }            
        }
        else if(pocId != null && pocId != '')
        {
            List<Request__c> requests = [select Id, Opportunity__r.AccountId, POC_Contact__c from Request__c where Id=:pocId limit 1];
            if(requests.size() > 0)
            {
                Shipment.Shipment_Account__c = requests[0].Opportunity__r.AccountId;
                Shipment.Shipment_Contact__c = requests[0].POC_Contact__c;
                Shipment.POC_Request__c = requests[0].Id;
                Shipment.SendTrackingInformation__c = true;
            }
        }
        else if(poId != null && poId != '')
        {
            List<Purchase_Order__c> pos = [select Id, Name, Opportunity__r.AccountId, Email_Contact__c from Purchase_Order__c where Id = :poId limit 1];
            if(pos.size() > 0)
            {
                Shipment.Shipment_Account__c = pos[0].Opportunity__r.AccountId;
                Shipment.Shipment_Contact__c = pos[0].Email_Contact__c;
                Shipment.PurchaseOrder__c = pos[0].Id;
                Shipment.PurchaseOrderNumber__c = pos[0].Name;
                Shipment.SendTrackingInformation__c = true;             
                
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an Account or a POC Request')); 
            IsError = true;
        }
    }
    
    public String SNSets {get;set;}
    public List<ShipLineInfo> ShippedLineList {get;set;}
    public Shipment__c Shipment {get;set;}    
    public Boolean IsError {get;set;}
    public Asset TempAsset {get;set;}    //for data binding only, will never save this record.
    public String ShipToLocation {get;set;}
    public String Comments {get;set;}
    //private Account account {get; set;}
    
    public PageReference Process()
    {       
        ShippedLineList = new List<ShipLineInfo>();
        if(SNSets != null && SNSets != '')
        {
            String[] splits = SNSets.split('(\r\n)|,|\n|\r');
            Set<string> SNoSets = new Set<string>();
            for(String sno : splits)
            {
                if(sno != null && sno != '')
                {
                    sno = sno.trim();
                    if(!SNoSets.Contains(sno))
                    {
                        if(isValidSerialNumber(sno))
                        {
                            SNoSets.add(sno);
                        }
                        else
                        {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Incorrect Serial Number: ' + sno));
                            break;
                        }
                    }                  
                }
            }
            ShippedLineList = GetShipLineInfo(SNoSets);
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input Serial Numbers'));  
        }
        return null;
    }
    
    public PageReference Save()
    {
        Boolean hasNullProd = false;
        if(ShippedLineList != null)
        {
            for(ShipLineInfo lineInfo : ShippedLineList)
            {
                if(lineInfo.SelectProductId == null && !lineInfo.AssetIsExisted)
                {    
                    hasNullProd  = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Asset ' + lineInfo.SerialNumber + ' requires a product'));
                }
            }
            if(hasNullProd)
            {
                return null;
            }
            SavePoint sp = Database.setSavepoint();
            try
            {
                List<Account> accounts = [select Id, Owner.Email from Account where Id=:Shipment.Shipment_Account__c];
                if(accounts.size() > 0)
                {
                    Shipment.AccountOwnerEmail__c = accounts[0].Owner.Email;
                }
                upsert Shipment;
                if(Shipment.PurchaseOrder__c != null)
                {
                    updatePurchaseOrder(Shipment.PurchaseOrder__c);
                }
                changePOCRequestActualDateAndStatus();
                List<Shipped_Line__c> lineItems = convertToSObjects(ShippedLineList);
                upsert lineItems;
                if(Shipment.To_Be_Swapped_Asset__c != null && ShippedLineList.size() > 0)
                {
                    updateRMAExchange(Shipment.To_Be_Swapped_Asset__c, ShippedLineList[0].AssetId, Shipment.PurchaseOrderNumber__c, Shipment.Email__c, Shipment.Secondary_Email__c, Shipment.Third_Email__c);
                }
                
                
                return new PageReference('/' + Shipment.Id);
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    @RemoteAction
    public static List<String> getAssetPartNumber(String productId)
    {
        List<String> result = new List<String>();
        List<Product2> products = [select ProductCode from Product2 where Id=:productId limit 1];
        if(products.size() > 0)
        {
            String productPN = products[0].ProductCode;
            for(ReplaceablePartNumberMatrix__c entry : [select Asset_PN__c from ReplaceablePartNumberMatrix__c where Product_PN__c=:productPN])
            {
                if(entry.Asset_PN__c != null)
                {
                    result.add(entry.Asset_PN__c);
                }
            }
        }
        return result;
    }
    @RemoteAction
    public static boolean IsProductGMS(String productId)
    {
        boolean result=true;
        List<Product2> products = [select Model__c from Product2 where Id=:productId limit 1];
        if(products.size() > 0)
        {
            if(products[0].Model__c!=null && products[0].Model__c.startswith('GX-'))
            {
                result=false;
            }
        }
        return result;
    }
    @RemoteAction
    public static boolean IsServiceProviderProduct(String productId)
    {
        boolean result=true;
        List<Product2> products = [select Product_Type__c from Product2 where Id=:productId limit 1];
        if(products.size() > 0)
        {
            if(products[0].Product_Type__c!=null && products[0].Product_Type__c=='EC-SP')
            {
                result=false;
            }
        }
        return result;
    }
    private List<ShipLineInfo> GetShipLineInfo(Set<String> SNoSets)
    {
        List<String> exitingSNSet = new List<String>();
        ShipLineInfo shipInfo;
        Set<String> removedDashesSno = new Set<String>();
        for(String SNo :SNoSets)
        {
            removedDashesSno.add(removeDashes(SNo));
        }    
        List<ShipLineInfo> ShipLineInfoLists = new List<ShipLineInfo>();
        List<Asset> exitingAssets = [select Id, Product2.ProductCode, Product2.Name, Product2Id, SerialNumber, Ship_Date__c, Status, GMS_Nodes__c, Evaluation_Start_Date__c,
                                     Evaluation_End_Date__c, Warranty_Start_Date__c, Warranty_End_Date__c, Part_Number__c,Contract_Number__r.StartDate,Contract_Number__r.EndDate from Asset
                                     where SerialNumber in : removedDashesSno];
        for(Asset aset : exitingAssets)
        {
            exitingSNSet.add(aset.SerialNumber);
            shipInfo= new ShipLineInfo();
            shipInfo.AssetId = aset.Id;
            shipInfo.TempAsset.GMS_Nodes__c = aset.GMS_Nodes__c;
            shipInfo.PostShipmentStatus = aset.Status;
            shipInfo.PriorStatus = aset.Status;
            shipInfo.TempAsset.Ship_Date__c = Shipment.Ship_Date__c;
            shipInfo.SerialNumber = aset.SerialNumber;
            shipInfo.ProductCode = aset.Product2.Name;
            shipInfo.PartNumber = aset.Part_Number__c;
            shipInfo.AssetIsExisted = true;
            shipInfo.TempAsset.Product2Id = aset.Product2Id;
            shipInfo.SendTrackingInfo = true;
            shipInfo.ShipmentEmail = '';     
            ShipLineInfoLists.add(shipInfo);                                 
        }
        removedDashesSno.removeAll(exitingSNSet);
        if(removedDashesSno.size()>0)
        {
            for(String SNo : removedDashesSno)
            {
                shipInfo = new ShipLineInfo();
                shipInfo.SerialNumber = SNo;
                shipInfo.AssetId = null;
                shipInfo.AssetIsExisted = false;                    
                shipInfo.GMSNodes = null;
                shipInfo.PostShipmentStatus = null;
                shipInfo.PriorStatus = null;
                shipInfo.TempAsset.Ship_Date__c = Shipment.Ship_Date__c;
                shipInfo.ProductCode = null;
                shipInfo.ProductId = null; 
                shipInfo.SelectProductId = null;
                shipInfo.SendTrackingInfo = true;
                shipInfo.ShipmentEmail = '';                  
                ShipLineInfoLists.add(shipInfo);
            }
        } 
        return ShipLineInfoLists;
    }
    
    private void updatePurchaseOrder(Id purchaseOrderId)
    {
        Purchase_Order__c po = new Purchase_Order__c(Id=purchaseOrderId, Status__c='Shipped - Complete', Ship_Date__c = Shipment.Ship_date__c ,Tracking_Information__c=Shipment.Tracking_Information__c);
        update po;
    }
    /**
* added the POCRequest__c exchange into this cdc 1-25-2012
**/
    private void updateRMAExchange(Id faultyAssetId, Id newAssetId, String RMANum, String Email1, String Email2, String Email3)
    {
        Asset faultyAsset = [select Id, Status, Ship_Date__c, Name, Contract_Number__c, POCRequest__c, End_of_Maintenance__c, GMS_Nodes__c, Evaluation_End_Date__c, Evaluation_Start_Date__c from Asset where Id=:faultyAssetId limit 1];
        Asset newAsset = new Asset(Id=newAssetId);
        
        newAsset.Status = faultyAsset.Status;
        newAsset.Ship_Date__c = faultyAsset.Ship_Date__c;
        newAsset.Contract_Number__c = faultyAsset.Contract_Number__c;
        newAsset.GMS_Nodes__c = faultyAsset.GMS_Nodes__c;
        newAsset.Evaluation_Start_Date__c = faultyAsset.Evaluation_Start_Date__c;
        newAsset.Evaluation_End_Date__c = faultyAsset.Evaluation_End_Date__c;
        newAsset.POCRequest__c = faultyAsset.POCRequest__c;
        newAsset.ReplacedSN__c = faultyAsset.Name;
        newAsset.ReplacedSNRMA__c = RMANum;
        newAsset.ReplaceSNEmail1__c = Email1;
        newAsset.ReplaceSNEmail2__c = Email2;
        newAsset.ReplaceSNEmail3__c = Email3;
        newAsset.SendReplacementNotice__c = True;
        faultyAsset.Contract_Number__c = null;
        faultyAsset.POCRequest__c = null;
        faultyAsset.Status = 'Pending Return – Support';
        update new List<Asset> { faultyAsset, newAsset };
            
            //ShipDate change on asset will fire a trigger to populate EOM date, we have to do second update
            newAsset = new Asset(Id=newAssetId, End_of_Maintenance__c=faultyAsset.End_of_Maintenance__c);
        update newAsset;
    }
    
    /**
* 1.If the POC Request - "Actual Ship Date" is blank, 
* stamp the POC request "Actual Ship Date" with the Ship Date entered on the Shipment
* 2.Set the POC Request status to Shipped if it is Approved to Ship
* 3. sets TargetEndDate on POC = target end date + 60d
**/
    private void changePOCRequestActualDateAndStatus()
    {
        
        List<Request__c> requests = [select Actual_Ship_Date__c, Status__c,POC_Type__c,Target_End_Date__c,Opportunity__r.Account.Partner_Type__c,Opportunity__r.Account.ECSP__c from Request__c where Id = : Shipment.POC_Request__c];
        if(!requests.isEmpty())
        {
            Request__c request = requests[0];
            if(request.Actual_Ship_Date__c == null)
            {
                request.Actual_Ship_Date__c = Shipment.Ship_Date__c;
            }
            if(request.Status__c == 'Open' || request.Status__c == 'Approved to Ship')
            {
                if(request.Opportunity__r.Account.ECSP__c)
                {request.Target_End_Date__c = (request.Target_End_Date__c == null) ? Shipment.Ship_Date__c.addDays(90) : request.Target_End_Date__c.addDays(90);}
                else if(request.POC_Type__c=='EdgeConnect')
                {request.Target_End_Date__c = (request.Target_End_Date__c == null) ? Shipment.Ship_Date__c.addDays(45) : request.Target_End_Date__c.addDays(45);}
                else
                {request.Target_End_Date__c = (request.Target_End_Date__c == null) ? Shipment.Ship_Date__c.addDays(60) : request.Target_End_Date__c.addDays(60);}
                request.Status__c = 'Shipped';
            }
            
            update requests[0];
            
            
            
        }
    }
    
    
    private List<Shipped_Line__c> convertToSObjects(List<ShipLineInfo> shippingItems)
    {
        List<Shipped_Line__c> result = new List<Shipped_Line__c>();
        Map<String, Asset> allAssetMap = new Map<String, Asset>();
        Map<String, Shipped_Line__c> shipLineMap = new Map<String, Shipped_Line__c>();
        List<Asset> allAssetList = new List<Asset>();
        for(ShipLineInfo shippingItem : shippingItems)
        {
            Shipped_Line__c shipLine = new Shipped_Line__c();
            shipLine.GMS_Nodes__c = shippingItem.TempAsset.GMS_Nodes__c;
            shipLine.Post_Shipment_Status__c = shippingItem.TempAsset.Status;
            shipLine.Prior_Status__c = shippingItem.PriorStatus;
            shipLine.Ship_Date__c = Shipment.Ship_Date__c;
            shipLine.Shipment_Id__c = Shipment.Id;
            shipLine.Asset__c = shippingItem.AssetId;
            Asset ast = getAssetInfo(shippingItem);
            allAssetList.add(ast);
            allAssetMap.put(shippingItem.SerialNumber, ast);
            shipLineMap.put(shippingItem.SerialNumber, ShipLine);
            result.add(shipLine);  
        }
        upsert allAssetList;
        for(String seriaNumber : allAssetMap.keyset())
        {
            Asset currentAssert = allAssetMap.get(seriaNumber);
            Shipped_Line__c currentShipLine = shipLineMap.get(seriaNumber);
            currentShipLine.Asset__c = currentAssert.Id;
        }
        Set<Id> createdAssetIds = new Set<Id>();
        for(ShipLineInfo shippingItem : shippingItems)
        {
            String sn = shippingItem.SerialNumber;
            Asset currentAssert = allAssetMap.get(sn);
            shippingItem.AssetId = currentAssert.Id;
            if(!shippingItem.AssetIsExisted)
            {
                createdAssetIds.add(shippingItem.AssetId);
            }
        }
        List<Asset> gmsAssets = [select Id, ContactId, GMS_Nodes__c, Model__c, SerialNumber from Asset where Id in :createdAssetIds and (Product2.Model__c='GX-V' Or Product2.Product_Category__c = 'GMS')];
        if(gmsAssets.size() > 0)
        {
            VirtualAssetManager.encryptlicenses(generateLicenses(gmsAssets));
        }
        return result;                 
    }
    
    private List<Id> generateLicenses(List<Asset> gmsAssets)
    {
        List<License__c> licenses = new List<License__c>();
        for(Asset ast : gmsAssets)
        {
            License__c license = new License__c(AssetId__c=ast.Id, Contact_for_Notification__c=ast.ContactId, Model__c=ast.Model__c, Start_Date__c=Date.today(), SerialNumber__c=ast.SerialNumber);
            try
            {
                license.Quantity__c = Integer.valueOf(ast.GMS_Nodes__c);
            }
            catch(Exception ex)
            {
            }
            licenses.add(license);
        }
        upsert licenses;
        List<Id> result = new List<Id>();
        for(License__c license : licenses)
        {
            result.add(license.Id);
        }
        return result;
    }
    
    private Asset getAssetInfo(ShipLineInfo ShipInfo)
    {
        Asset aset ;
        if(ShipInfo.AssetId != null)
        {
            aset = new Asset(Id = ShipInfo.AssetId);
            aset.POCRequest__c = Shipment.POC_Request__c;
            aset.Contract_Number__c = Shipment.Shipment_Contract__c;
            aset.AccountId = Shipment.Shipment_Account__c;
            aset.GMS_Nodes__c = ShipInfo.TempAsset.GMS_Nodes__c;
            aset.Status = ShipInfo.TempAsset.Status;
            aset.Ship_Date__c = ShipInfo.TempAsset.Ship_Date__c;
            aset.SerialNumber = ShipInfo.SerialNumber;
            aset.Product2Id = ShipInfo.TempAsset.Product2Id;
            aset.Ship_To_Location__c = ShipToLocation+ '  ( Tracking Information:: ' + Shipment.Tracking_Information__c + ')';
            aset.Description = Comments;
        }
        else
        {
            aset = new Asset();
            aset.POCRequest__c = Shipment.POC_Request__c;
            aset.Contract_Number__c = Shipment.Shipment_Contract__c;
            aset.AccountId = Shipment.Shipment_Account__c;
            aset.Name = ShipInfo.SerialNumber;
            aset.AccountId = Shipment.Shipment_Account__c;
            aset.GMS_Nodes__c = ShipInfo.TempAsset.GMS_Nodes__c;
            aset.Status = ShipInfo.TempAsset.Status;
            aset.Ship_Date__c = ShipInfo.TempAsset.Ship_Date__c;
            aset.SerialNumber = ShipInfo.SerialNumber;
            aset.Part_Number__c = ShipInfo.PartNumber;
            aset.Product2Id = ShipInfo.SelectProductId;
            aset.Ship_To_Location__c = ShipToLocation + '  ( Tracking Information:: ' + Shipment.Tracking_Information__c + ')';
            aset.Description = Comments;
            aset.Quantity = 1;
        }
        return aset;
    }
    
    public List<SelectOption> getProductList()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<Product2> productList = [select Id, Name from Product2 where IsActive = True and Family = 'Product' order by Name asc];
        for(Product2 product : productList)
        {
            options.add(new SelectOption(product.Id, product.Name));
        }
        if(options.size() > 0)
        {
            options.add(0, new SelectOption('', '--Choose a Product--'));
        }
        else
        {
            options.add(0, new SelectOption('', '--None Product--'));
        }
        return options;
    }
    
    public List<SelectOption> getPartNumberList()
    {
        List<SelectOption> result = new List<SelectOption>();
        Schema.DescribeFieldResult field = Asset.Part_Number__c.getDescribe();
        result.add(new SelectOption('', ' --None-- '));
        for(Schema.PicklistEntry entry : field.getPicklistValues())
        {
            result.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return result;
    }
    
    @TestVisible
    private Boolean isValidSerialNumber(String serialNumber)
    {
        return Pattern.matches('^([0-9a-fA-F]{2})(([\\-][0-9a-fA-F]{2}){5})$', serialNumber) || Pattern.matches('^([0-9a-fA-F]{2})(([0-9a-fA-F]{2}){5})$', serialNumber) || Pattern.matches('^([0-9a-fA-F]{4})(([\\.][0-9a-fA-F]{4}){2})$', serialNumber) || Pattern.matches('^([0-9]{10})$', serialNumber);
    }
    
    private String removeDashes(String serialNumber)
    {
        return serialNumber.replaceAll('\\.', '').replaceAll('\\-', '');
    }
    
    public class ShipLineInfo
    {
        public ShipLineInfo()
        {
            TempAsset  = new Asset();
        }
        public Id AssetId {get;set;}
        public String GMSNodes {get;set;}
        public String PostShipmentStatus {get;set;}
        public String PriorStatus {get;set;}
        public Date ShipDate {get;set;}
        public Id ShipmentId {get;set;}
        public String SerialNumber {get;set;}
        public String ProductCode {get;set;}
        public String PartNumber { get; set; }
        public Boolean AssetIsExisted {get;set;}
        public Asset TempAsset {get; set;}
        public Id ProductId {get;set;}
        public String SelectProductId {get;set;}
        public String ShipmentEmail {get; set;}
        public Boolean SendTrackingInfo {get; set;}
    }
}