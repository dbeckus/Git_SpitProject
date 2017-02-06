@IsTest
public class TestSendWanOpFulfillmentEmail {
    
    @IsTest
    public static void TestSendEmail_VX()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='VX-2000',Model__c='VX-2000',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
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
        Test.startTest();
        testShipment.Send_Email__c=true;
        update testShipment;
        Test.stopTest();
        
    }
    @IsTest
    public static void TestSendEmail_VRX()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='VRX-6',Model__c='Velocity',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
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
        
        controller.AssetLines[0].Asset.Product2Id = controller.ProductsList[0].Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Licenses_Nodes__c = 10;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        Test.startTest();
        
        controller.save();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        List<Asset> lstAsset =[Select Id,Model__c,Key_Generated__c,Marketplace_Sourced_Opp__c from Asset where Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__c =:testShipment.id)];
        List<Asset> lstAssetToUpdate=new List<Asset>();
        for(Asset asset: lstAsset)
        {
            asset.Key_Generated__c=true;
            lstAssetToUpdate.add(asset);
        }
        update lstAssetToUpdate;
        testShipment.Send_Email__c=true;
        update testShipment;
        Test.stopTest();
        
        
        
        
    }
}