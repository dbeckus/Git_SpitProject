@IsTest
public class TestPORenewalAssetsController {
    
    @IsTest
    public static void TestPoRenewalAssets_EdgeConnect()
    {
        
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',email='test@abc.com',  AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        Test.startTest();
        
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
        Test.stopTest();
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset firstAssetRec= [Select Id,Licenses_Nodes__c,AccountId,Product2.Family, Status,Product2.Name from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(10,firstAssetRec.Licenses_Nodes__c);
        System.debug('Asset Account'+firstAssetRec.accountId);
        System.debug(' Account'+testAccount.Id);
        System.debug(' Product2.Family'+firstAssetRec.Product2.Family);
        System.debug(' Product2.Name'+firstAssetRec.Product2.Name);
        System.debug(' Status'+firstAssetRec.Status);
        // Create one more virtual product with the same prouduct
        
        pageRef = new PageReference('/apex/POAssetsRenewal?Id=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController poStdController = new ApexPages.StandardController(testPO);
        PORenewalAssetsController renewController = new PORenewalAssetsController(poStdController);
        renewController.AssetList = renewController.RetreiveAssets(true);
        renewController.AssetTypeSelection ='2';
        //renewController.License.License_Expiration__c = Date.today().addyears(3);
        List<Asset> outputAssets= new List<Asset>();
        for(Asset asset :renewController.AssetList)
        {
            asset.Is_Selected_For_Renewal__c =true;
            asset.Renewal_Date__c =Date.today().addyears(3);
            outputAssets.add(asset);
        }
        renewController.AssetList = outputAssets;
        renewController.SaveAssets();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name,Product2Id from Asset where Product2.Family='Virtual Image' and Product2Id=:testProduct.Id and  AccountId in (Select AccountId from Opportunity where Id=:testPO.Opportunity__c)];
        System.debug('Product2Id'+ asset[0].Product2Id );
        System.debug('testProduct'+ testProduct );
        System.assertEquals(Date.today().addyears(3),asset[0].License_End_Date__c);
        
        
        
    }
    @IsTest
    public static void TestPoRenewalAssets_EdgeConnect_Orch()
    {
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-ORCH', Family='Virtual Image', Product_Category__c='GMS', Model__c='EC-ORCH' , IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',email='test@abc.com',  AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        Test.startTest();
        
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
        
        Test.stopTest();
        
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset firstAssetRec= [Select Id,Licenses_Nodes__c,AccountId,Product2.Family, Status,Product2.Name from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        System.assertEquals(10,firstAssetRec.Licenses_Nodes__c);
        System.debug('Asset Account'+firstAssetRec.accountId);
        System.debug(' Account'+testAccount.Id);
        System.debug(' Product2.Family'+firstAssetRec.Product2.Family);
        System.debug(' Product2.Name'+firstAssetRec.Product2.Name);
        System.debug(' Status'+firstAssetRec.Status);
        // Create one more virtual product with the same prouduct
        
        pageRef = new PageReference('/apex/POAssetsRenewal?Id=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController poStdController = new ApexPages.StandardController(testPO);
        PORenewalAssetsController renewController = new PORenewalAssetsController(poStdController);
        renewController.AssetList = renewController.RetreiveAssets(true);
        renewController.AssetTypeSelection ='2';
        //renewController.License.License_Expiration__c = Date.today().addyears(3);
        List<Asset> outputAssets= new List<Asset>();
        for(Asset asset :renewController.AssetList)
        {
            asset.Is_Selected_For_Renewal__c =true;
            asset.Renewal_Date__c =Date.today().addyears(3);
            outputAssets.add(asset);
        }
        renewController.AssetList = outputAssets;
        renewController.SaveAssets();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name,Product2Id from Asset where Product2.Family='Virtual Image' and Product2Id=:testProduct.Id and  AccountId in (Select AccountId from Opportunity where Id=:testPO.Opportunity__c)];
        System.debug('Product2Id'+ asset[0].Product2Id );
        System.debug('testProduct'+ testProduct );
        System.assertNotEquals(Date.today().addyears(3),asset[0].License_End_Date__c);
    }
    @IsTest
    public static void TestPoRenewalAssets_WanOp()
    {
        
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='acme',Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Contact testContact = new Contact(LastName='acme',email='test@abc.com',  AccountId=testAccount.Id);
        insert testContact;
        Purchase_Order__c testPO = new Purchase_Order__c(Name = 'acme', Email_Contact__c=testContact.Id, Opportunity__c=testOpp.Id);
        insert testPO;
        
        Shipment__c testShipment = new Shipment__c();  
        
        PageReference pageRef = new PageReference('/apex/NewVirtualShipment?poId=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testShipment);
        NewVirtualShipmentController controller = new NewVirtualShipmentController(stdController);
        controller.TempAsset.ContactId = testContact.Id;
        
        controller.AssetLines[0].Asset.Product2Id = testProduct.Id;
        controller.AssetLines[0].Asset.Quantity = 1;
        controller.AssetLines[0].Asset.Evaluation_End_Date__c = Date.newInstance(2016, 1, 1);
        controller.AssetLines[0].Asset.Status = 'Customer Subscription';
        controller.addLine();
        
        ApexPages.currentPage().getParameters().put('rowIndex', '1');
        controller.removeLine();
        
        controller.save();
        
        System.assert(testShipment.Id != null);
        System.assertEquals(1, [SELECT count() FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id]);
        Asset firstAssetRec= [Select Id,AccountId,Product2.Family, Status,Product2.Name from Asset where Id in (SELECT Asset__c FROM Shipped_Line__c WHERE Shipment_Id__c = :testShipment.Id) LIMIT 1];
        // Create one more virtual product with the same prouduct
        Test.startTest();
        pageRef = new PageReference('/apex/POAssetsRenewal?Id=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController poStdController = new ApexPages.StandardController(testPO);
        PORenewalAssetsController renewController = new PORenewalAssetsController(poStdController);
        renewController.AssetList = renewController.RetreiveAssets(false);
        renewController.AssetTypeSelection ='1';
        
        List<Asset> outputAssets= new List<Asset>();
        for(Asset asset :renewController.AssetList)
        {
            asset.Is_Selected_For_Renewal__c =true;
            asset.Renewal_Date__c =Date.today().addyears(3);
            outputAssets.add(asset);
        }
        renewController.AssetList = outputAssets;
        renewController.SaveAssets();
        Test.stopTest();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name,Product2Id from Asset where Product2.Family='Virtual Image' and Product2Id=:testProduct.Id and  AccountId in (Select AccountId from Opportunity where Id=:testPO.Opportunity__c)];
        
        System.assertEquals(Date.today().addyears(3),asset[0].License_End_Date__c);
        
        
        
    }
}