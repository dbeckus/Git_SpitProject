@IsTest
public class TestAssetTriggerHandler {
    
    @IsTest
    public static void AssetCountInsert()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        Asset assetData=[Select Id,Is_Customer_Asset__c from Asset where Id=:asset.Id];
        System.assertEquals(true, assetData.Is_Customer_Asset__c);
        
    }
    @IsTest
    public static void AssetCountUpd_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        asset.Status='Write-Off';
        update asset;
        
        Asset assetData=[Select Id,Is_Customer_Asset__c from Asset where Id=:asset.Id];
        System.assertEquals(true, assetData.Is_Customer_Asset__c);
        
    }
    @IsTest
    public static void AssetCountUnDel_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        delete asset;
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
        undelete asset;
        
        Asset assetData=[Select Id,Is_Customer_Asset__c from Asset where Id=:asset.Id];
        System.assertEquals(true, assetData.Is_Customer_Asset__c);
        
    }
    @IsTest
    public static void DecomissionAsset()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account acc1= new Account(Name='Silver Peak Systems');
        insert acc1;
        Product2 product = new Product2();
        product.Name = 'EC-XS';
        product.ProductCode = 'EC-XS';
        product.Model__c = 'EC-XS';
        product.Family='Product';
        product.Product_Type__c='EDGECONNECT';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        insert asset1;
        Test.startTest();
        asset1.AccountId=acc1.Id;
        update asset1;
        Test.stopTest();
        List<Asset> lstAsset=[Select Id,Cloud_Portal_Sync_Status__c,Sync_With_Cloud_Portal__c from Asset where AccountId=:acc.Id];
        System.assertEquals(lstAsset[0].Cloud_Portal_Sync_Status__c,'Pending');
        System.assertEquals(lstAsset[0].Sync_With_Cloud_Portal__c,true);
        
        
    }
    @IsTest
    public static void ProvisionAsset()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account newacc= new Account(Name='new acme');
        insert newacc;
        Account acc1= new Account(Name='Silver Peak Systems');
        insert acc1;
        Product2 product = new Product2();
        product.Name = 'EC-XS';
        product.ProductCode = 'EC-XS';
        product.Model__c = 'EC-XS';
        product.Family='Product';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        insert asset1;
        Test.startTest();
        asset1.AccountId=acc1.Id;
        asset1.Status='Silver Peak Inventory';
        update asset1;
        
        asset1.AccountId=newacc.Id;
        asset1.Status='Customer Owned';
        update asset1;
        Test.stopTest();  
    }
    @IsTest
    public static void AddHardwareECLicenseAfterEcSoftware()
    {
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', Technical_Responsible__c =Userinfo.getUserId(), ForecastCategoryName ='Omitted', AccountId=testAccount.Id,Product_Type__c='Both');
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Product2 hardwareProd = new Product2(Name='EC-XS',Model__c='EC-XS',Product_Type__c='EDGECONNECT',Product_Category__c='Appliance', ProductCode='500210-001', Family='Product', IsActive=true);
        insert hardwareProd;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Contact testContactupdated = new Contact(LastName='updatedacme', AccountId=testAccount.Id);
        insert testContactupdated;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.startTest();
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Status = 'Customer Subscription Active';
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        try
        {
            controller.save();
        }
        catch(Exception ex)
        {
            System.debug(ex);
        }
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);   
        pageRef = new PageReference('/apex/ShippingInputForm?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController shipmentController = new ShippingInputFormController();
        shipmentController.SNSets = '123456789012';
        shipmentController.Process();
        shipmentController.getProductList();
        shipmentController.getPartNumberList();
        shipmentController.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = shipmentController.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        shipmentController.ShippedLineList[0].SelectProductId = hardwareProd.Id;
        shipmentController.ShippedLineList[0].TempAsset.Ship_Date__c = Date.today();
        shipmentController.ShippedLineList[0].TempAsset.Status = 'Customer Owned';
        shipmentController.save();
        System.debug('Shipment ID'+shipmentController.Shipment.Id);
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :shipmentController.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        //System.assertEquals(0, ApexPages.getMessages().size());
        List<Asset> lstHardwareAsset = [Select Id, Name,Active_EC_Base_License__c from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:shipmentController.Shipment.Id)];
        System.assertEquals(1, lstHardwareAsset.size());
        List<Asset> lstsoftwareAsset = [Select Id, Name,Active_EC_Base_License__c from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:testShipment.Id)];
        System.assertEquals(1, lstsoftwareAsset.size());
        System.assertEquals(lstsoftwareAsset[0].Id,lstHardwareAsset[0].Active_EC_Base_License__c);
        Test.StopTest();
        
    }
    @IsTest
    public static void AddHardwareECLicenseBeforeEcSoftware()
    {
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=testAccount.Id,Product_Type__c='Both');
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Product2 hardwareProd = new Product2(Name='EC-XS',Model__c='EC-XS',Product_Type__c='EDGECONNECT',Product_Category__c='Appliance', ProductCode='500210-001', Family='Product', IsActive=true);
        insert hardwareProd;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Contact testContactupdated = new Contact(LastName='updatedacme', AccountId=testAccount.Id);
        insert testContactupdated;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        //Id standardPricebookId = TestUtilities.getStandardPricebookId();
        //Id opportunityId = TestUtilities.createTestOpportunity(testAccount.Id, standardPricebookId);
        
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ShippingInputFormController shipmentController = new ShippingInputFormController();
        shipmentController.SNSets = '123456789012';
        shipmentController.Process();
        shipmentController.getProductList();
        shipmentController.getPartNumberList();
        shipmentController.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = shipmentController.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        shipmentController.ShippedLineList[0].SelectProductId = hardwareProd.Id;
        shipmentController.ShippedLineList[0].TempAsset.Ship_Date__c = Date.today();
        shipmentController.ShippedLineList[0].TempAsset.Status = 'Customer Owned';
        
        shipmentController.save();
        
        System.debug('Shipment ID'+shipmentController.Shipment.Id);
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :shipmentController.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        Shipment__c testShipment = new Shipment__c();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        System.debug('controller.ProductsList[0].Id'+controller.ProductsList[0].Id);
        controller.AssetLines[0].Asset.Product2Id = testProduct.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Status = 'Customer Subscription Active';
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        
        //System.assertEquals(0, ApexPages.getMessages().size());
        List<Asset> lstHardwareAsset = [Select Id, Name,Active_EC_Base_License__c,Status from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:shipmentController.Shipment.Id)];
        System.assertEquals(1, lstHardwareAsset.size());
        System.debug(lstHardwareAsset[0].Status);
        List<Asset> lstsoftwareAsset = [Select Id, Name,Active_EC_Base_License__c,Status from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:testShipment.Id)];
        System.assertEquals(1, lstsoftwareAsset.size());
        System.debug(lstsoftwareAsset[0].Status);
        System.assertEquals(lstsoftwareAsset[0].Id,lstHardwareAsset[0].Active_EC_Base_License__c);
        Test.stopTest();
        
    }
    @isTest
    static void testUpdateEOM()
    {
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        //ready for testing data
        EOMDate__c date1 = new EOMDate__c(Name='acme',Model__c='NX-2500', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('10/1/2012'));
        EOMDate__c date2 = new EOMDate__c(Name='acme2',Model__c='NX-5600', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('7/1/2016'));        
        EOMDate__c date3 = new EOMDate__c(Name='acme3',Model__c='NX-2700', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('2/1/2018'));
        EOMDate__c date4 = new EOMDate__c(Name='acme4',Model__c='NX-2700', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('2/1/2017'));
        EOMDate__c date5 = new EOMDate__c(Name='acme5',Model__c='NX-8504', ShipDate__c=Date.parse('9/1/2012'), EOMDate__c=Date.parse('10/1/2012'));
        insert new EOMDate__c[]{ date1, date2, date3, date4, date5 };
            
            Account testAccount = new Account(Name='acme');
        insert testAccount;    
        Contact testContact = new Contact(LastName = 'acme', AccountId = testAccount.Id);
        insert testContact;        
        Product2 product1 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-2500');
        Product2 product2 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-5600');
        Product2 product3 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-2700');
        Product2 product4 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual', Family = 'Virtual Image', Model__c = 'NX-8504');
        insert new Product2[]{ product1, product2, product3, product4 };
            
            //execute test
            Asset asset1 = new Asset(Name='acme', Ship_Date__c = Date.newInstance(2000,01,01), SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=product1.Id, AccountId=testAccount.Id, ContactId=testContact.Id);
        Asset asset2 = new Asset(Name='acme', Ship_Date__c = Date.newInstance(2000,01,01), SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=product2.Id, AccountId=testAccount.Id, ContactId=testContact.Id);
        insert new Asset[]{ asset1, asset2 };        
            
            system.assertEquals(Date.newInstance(2012, 10, 1), [select End_of_Maintenance__c from Asset where id = :asset1.id][0].End_of_Maintenance__c);
        system.assertEquals(Date.newInstance(2016, 7, 1), [select End_of_Maintenance__c from Asset where id = :asset2.id][0].End_of_Maintenance__c);        
        
        asset1.Product2Id = product3.Id;
        asset1.Ship_Date__c = Date.newInstance(2001,01,01);
        asset2.Product2Id = product4.Id;        
        asset2.Ship_Date__c = Date.newInstance(2001,01,01);        
        update new Asset[]{ asset1, asset2 };
            system.assertEquals(Date.newInstance(2017, 2, 1), [select End_of_Maintenance__c from Asset where id = :asset1.id][0].End_of_Maintenance__c);
        system.assertEquals(Date.newInstance(2012, 10, 1), [select End_of_Maintenance__c from Asset where id = :asset2.id][0].End_of_Maintenance__c);                
    }
    @IsTest
    public static void CheckSyncFlag()
    {
        
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today(),ECSP__c =false);
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems',EC_Customer_Date__c=Date.today());
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=testAccount.Id,Product_Type__c='Both');
        insert testOpp;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id, Target_End_Date__c=Date.today(),Opportunity__c=testOpp.Id);
        request.POC_Type__c='EdgeConnect';
        insert request;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Category__c='Subscription', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Test.startTest();
        Asset asset = new Asset(Name='001HHD898JJJ',AccountId=testAccount.Id,Product2Id=testProduct.Id,Status='Customer Evaluation',POCRequest__c=request.Id);
        insert asset;
        delete asset;
        Account acc=[Select Sync_Virtual_Assets_with_CP__c from Account where Id=:testAccount.Id];
        System.assertEquals(true, acc.Sync_Virtual_Assets_with_CP__c);
        test.stopTest();
    }
   
}