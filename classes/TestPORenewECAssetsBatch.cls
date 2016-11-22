@IsTest
public class TestPORenewECAssetsBatch {
    @IsTest
    public static void Test1()
    {
        Account testAccount = new Account(Name='acme');
        testAccount.EC_Customer_Date__c=Date.today();
        insert testAccount;
        
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Type__c='EDGECONNECT', IsActive=true);
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
        // Create one more virtual product with the same prouduct
        
        pageRef = new PageReference('/apex/POAssetsRenewal?Id=' + testPO.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController poStdController = new ApexPages.StandardController(testPO);
        PORenewalAssetsController renewController = new PORenewalAssetsController(poStdController);
        renewController.AssetList = renewController.RetreiveAssets(true);
        renewController.AssetTypeSelection ='2';
        renewController.RenewalAsset= new Asset(Renewal_Start_Date__c=Date.today(),Renewal_Date__c=Date.today().addyears(3));
        //renewController.License.License_Expiration__c = Date.today().addyears(3);
        List<Asset> outputAssets= new List<Asset>();
        for(Asset asset :renewController.AssetList)
        {
            asset.Is_Selected_For_Renewal__c =true;
            asset.Renewal_Nodes__c=8;
            asset.Renewal_Date__c =Date.today().addyears(3);
            outputAssets.add(asset);
        }
        renewController.AssetList = outputAssets;
        renewController.SaveAssets();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name,Product2Id,Licenses_Nodes__c,Renewal_Nodes__c from Asset where Product2.Family='Virtual Image' and Product2Id=:testProduct.Id and  AccountId in (Select AccountId from Opportunity where Id=:testPO.Opportunity__c)];
        System.debug('Product2Id'+ asset[0].Product2Id );
      
        //System.assertEquals(Date.today().addyears(3),asset[0].License_End_Date__c);
        //System.assertEquals(10,asset[0].Licenses_Nodes__c);
        //System.assertEquals(8,asset[0].Renewal_Nodes__c);
        
        PORenewECAssetsBatch obj= new PORenewECAssetsBatch();
        Database.executeBatch(obj,1);
        
    }

}