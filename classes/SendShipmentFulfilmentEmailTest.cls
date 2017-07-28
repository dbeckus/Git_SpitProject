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
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-SP-BASE',Product_Type__c='EC-SP-Perpetual',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
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
    
}