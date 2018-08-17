@isTest
public class SendShipmentFulfilmentEmailTest
{
    @isTest
    static void test()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id, Email='test@test.com');
        insert ct;
        Shipment__c ship = new Shipment__c(Shipment_Account__c=acc.Id, Shipment_Contact__c=ct.Id, Ship_Date__c=Date.today());
        insert ship;
        
        SendShipmentFulfilmentEmailController controller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(ship));
        controller.send();
    }
    
    @isTest
    static void test_EC_Renewal()
    {
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        Test.stopTest();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        
    }
    
    @isTest
    static void test_EC_ServiceProvider()
    {
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today(),ECSP__c=true,Service_Provider_Account_Type__c='EC-SP-Term',Service_Provider_Admin_User__c='abc@abc.com');
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-SP-BASE',Product_Type__c='EC-SP-Term',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Status = 'Customer Owned';
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        Test.stopTest();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset lstAsset= [SELECT Id,Status FROM Asset WHERE Id in(Select Asset__c from Shipped_Line__c where Shipment_Id__c = :testShipment.Id)];
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        
    }
    @isTest
    static void test_EC_Addon()
    {
        Account testAccount = new Account(Name='acme', EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.startTest();        
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
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        
        testShipment = new Shipment__c();  
        
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(testShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        controller.save();
        
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        Test.stopTest();
        
        
    }
    
    @isTest
    static void test_EC_InitialFulfillmentWithDiffEndDates()
    {
        Account testAccount = new Account(Name='acme', EC_Customer_Date__c=Date.today(), Unity_Orch_Admin_User__c='acme@test.com', Unity_Orch_Location__c='US East (N. Virginia) (Current Production)', Unity_Orch_Domain__c='testacme');
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct1 = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true, SteelBrick_Category__c='EC-BASE');
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name='EC-PLUS-1Y',Model__c='EC-PLUS-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true, SteelBrick_Category__c='EC-PLUS');
        insert testProduct2;
        Product2 testProduct3 = new Product2(Name='EC-ORCH-AAS-L-1Y',Model__c='EC-ORCH-AAS-L-1Y',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT', SteelBrick_Category__c='EC-ORCH-AAS');
        insert testProduct3;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        Test.startTest();        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct1.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 1, 1);
        controller.addLine();
        controller.AssetLines[1].Asset.Product2Id = testProduct2.Id;
        controller.AssetLines[1].Asset.Quantity = 1;
        controller.AssetLines[1].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[1].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 1, 1);
        controller.addLine();
        controller.AssetLines[2].Asset.Product2Id = testProduct3.Id;
        controller.AssetLines[2].Asset.Quantity = 1;
        controller.AssetLines[2].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 1, 2);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '3');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(3, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        Test.stopTest();
    }
    
    @isTest
    static void test_EC_AddonUnityOrch()
    {
        Account testAccount = new Account(Name='acme', EC_Customer_Date__c=Date.today(), Unity_Orch_Admin_User__c='acme@test.com', Unity_Orch_Location__c='US East (N. Virginia) (Current Production)', Unity_Orch_Domain__c='testacme');
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct1 = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image',SteelBrick_Category__c='EC-BASE' ,  IsActive=true);
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name='EC-ORCH-AAS-L-1Y',Model__c='EC-ORCH-AAS-L-1Y',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true, SteelBrick_Category__c='EC-ORCH-AAS', Product_Type__c='EDGECONNECT');
        insert testProduct2;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct1.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Test.startTest();
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        testShipment = new Shipment__c();  
        
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(testShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct2.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 6, 6);
        controller.addLine(); 
        system.debug('added lines');
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        
        System.debug('testShipment.Id:'+ testShipment.Id);
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        Test.stopTest();   
    } 
    
    @isTest
    static void test_EC_MultipleAddons()
    {
        Account testAccount = new Account(Name='acme', EC_Customer_Date__c=Date.today(), Unity_Orch_Admin_User__c='acme@test.com', Unity_Orch_Location__c='US East (N. Virginia) (Current Production)', Unity_Orch_Domain__c='testacme');
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct1 = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image',SteelBrick_Category__c='EC-BASE' ,  IsActive=true);
        insert testProduct1;
        Product2 testProduct2 = new Product2(Name='EC-PLUS-1Y',Model__c='EC-PLUS-1Y',Product_Type__c='EDGECONNECT',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', SteelBrick_Category__c='EC-PLUS',  IsActive=true);
        insert testProduct2;
        Product2 testProduct3 = new Product2(Name='EC-ORCH-AAS-L-1Y',Model__c='EC-ORCH-AAS-L-1Y',Product_Category__c='GMS', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true, SteelBrick_Category__c='EC-ORCH-AAS', Product_Type__c='EDGECONNECT');
        insert testProduct3;
        Contact testContact = new Contact(LastName='acme',AccountId=testAccount.Id,Email='abc@abc.com');
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct1.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Test.startTest();
        SendShipmentFulfilmentEmailController sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        
        testShipment = new Shipment__c();  
        
        pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        stdController = new ApexPages.StandardController(testShipment);
        controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct2.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 6, 6);
        controller.addLine(); 
        
        controller.AssetLines[1].Asset.Product2Id = testProduct3.Id;
        controller.AssetLines[1].Asset.Quantity = 1;
        controller.AssetLines[1].Asset.Evaluation_End_Date__c = Date.newInstance(2018, 6, 6);
        controller.addLine(); 
        system.debug('added lines');
        
        ApexPages.currentPage().getParameters().put('rowIndex', '2');
        controller.removeLine();
        
        controller.save();
        
        System.debug('testShipment.Id:'+ testShipment.Id);
        System.assert(testShipment.Id != null);
        System.assertEquals(2, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        sendShipmentFulfilmentEmailcontroller = new SendShipmentFulfilmentEmailController(new ApexPages.StandardController(testShipment));
        sendShipmentFulfilmentEmailcontroller.send();
        Test.stopTest();  
    } 
    
}