@IsTest
public class TestAddActiveECBaseLicenseToECHardware {
   /* public static void AddHardwareECLicenseAfterEcSoftware()
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
    
  */
  
}