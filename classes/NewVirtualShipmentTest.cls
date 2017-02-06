/**
* The test class of NewVirtualShipmentController.
*
* @author  Matt Yuan
* @created 4/15/2015
* @version 1.0
* @since   33.0
*
* @changelog
* 4/15/2015 Matt Yuan - Created.
*/

@isTest
public class NewVirtualShipmentTest
{
    @isTest
    static void testNewShipmentController()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='acme', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='NX/VX');
        insert testProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        System.debug(controller.ProductsList[0].Id);
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 2;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.today().addDays(100);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(2, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
    }
    
    
        @isTest
    static void testNewShipmentController_ECORCH()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-ORCH',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
         System.debug('testProduct'+testProduct.Id);
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        System.debug('controller.ProductsList[0].Id'+controller.ProductsList[0].Id);
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.today().addDays(100);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset assetRec= [Select Id, (Select Id,Quantity__c from Licenses__r) from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(100000, AssetRec.Licenses__r[0].Quantity__c);  
        
        
    }
     @isTest
    static void testNewShipmentController_EC_DatesMismatch()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct1 = new Product2(Name='EC-PLUS-1Y',Product_Category__c='Subscription', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name='EC-BASE-1Y',Product_Category__c='Subscription', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct2;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct1.id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.today().addDays(1);
        controller.addLine();
        controller.AssetLines[1].Asset.Product2Id = testProduct2.Id;
        controller.AssetLines[1].Asset.Quantity = 1;
        controller.AssetLines[1].Asset.Evaluation_End_Date__c = Date.today().addDays(2);
        ApexPages.currentPage().getParameters().put('rowIndex', '2');
        controller.removeLine();
        
        controller.save(); 
        
        
    }
    @isTest
    static void testNewShipmentController_UpdateAssetLicenseDate()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Product2 plusProduct = new Product2(Name='EC-PLUS-1Y',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert plusProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        
        
        Shipment__c othertestShipment = new Shipment__c();
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(othertestShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = plusProduct.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 2, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        Asset finalRec= [Select Id, License_End_Date__c from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :othertestShipment.Id) LIMIT 1];
        Asset assetRec= [Select Id, License_End_Date__c from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(assetRec.License_End_Date__c, finalRec.License_End_Date__c);
    }
    @isTest
    static void testNewShipmentController_ECBase1YUpdate()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c= Date.today();
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Contact testContactupdated = new Contact(LastName='updatedacme', AccountId=testAccount.Id);
        insert testContactupdated;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.AssetLines[0].Asset.End_of_Maintenance__c=Date.today().addYears(2);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset firstAssetRec= [Select Id,Licenses_Nodes__c from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(10,firstAssetRec.Licenses_Nodes__c);
        // Create one more virtual product with the same prouduct
        
        testShipment = new Shipment__c(); 
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(testShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContactupdated.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2017, 1, 1);
        controller.AssetLines[0].Asset.End_of_Maintenance__c=Date.today().addYears(2);
        
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset secondAssetRec= [Select Id,ContactId,Licenses_Nodes__c,(Select Id,Name,License_Expiration__c from licenses__r) from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(firstAssetRec.Id, secondAssetRec.Id);
        System.assertEquals(20,secondAssetRec.Licenses_Nodes__c);
        System.assertEquals(Date.newInstance(2017, 1, 1), secondAssetRec.Licenses__r[0].License_Expiration__c);
        System.assertEquals(secondAssetRec.ContactId,testContactupdated.Id);
    }
    
	@isTest
    static void testNewShipmentController_ECBOOST1YUpdate()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BOOST-1Y',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.stopTest();
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Bandwidth_Nodes__c = 10;
        controller.AssetLines[0].Asset.End_of_Maintenance__c=Date.today().addYears(2);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset firstAssetRec= [Select Id,Bandwidth_Nodes__c from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(10,firstAssetRec.Bandwidth_Nodes__c);
        // Create one more virtual product with the same prouduct
        
        testShipment = new Shipment__c(); 
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(testShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Bandwidth_Nodes__c = 10;
        
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();  
        controller.save();
        
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset secondAssetRec= [Select Id,Bandwidth_Nodes__c from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(firstAssetRec.Id, secondAssetRec.Id);
        System.assertEquals(20,secondAssetRec.Bandwidth_Nodes__c);
        
    }
    
}