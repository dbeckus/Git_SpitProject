@IsTest
public class TestCloudPortalPostAssetsJob {
   @IsTest
    public static void TestBatchAssets_ExistingAccount()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898',Sync_Virtual_Assets_with_CP__c=true,Unity_Orch_Location__c='US East (N. Virginia) (Current Production)',Unity_Orch_Admin_User__c='abc@123.com',Unity_Orch_Domain__c='test12212');
        insert acc;
        
        Api_Configuration__c apicOnfig= new Api_Configuration__c(Base_Endpoint__c='https://portaleng.silverpeaksystems.net/portal',Endpoint_URL__c='https://portaleng.silverpeaksystems.net/portal/apis/rest',Environment_Name__c='Cloud Portal Testing',UserName__c='abc@silver-peak.com',Password__c='test');
        insert apicOnfig;
        
        Product2 baseProduct = new Product2();
        baseProduct.Name = 'EC-BASE-1Y';
        baseProduct.ProductCode = 'EC-BASE';
        baseProduct.Model__c = 'EC-BASE';
        baseProduct.Family='Virtual Image';
        baseProduct.Product_Type__c ='EDGECONNECT';
        insert baseProduct;
        
        Product2 boostProduct = new Product2();
        boostProduct.Name = 'EC-BOOST-1Y';
        boostProduct.ProductCode = 'EC-BOOST';
        boostProduct.Model__c = 'EC-BOOST';
        boostProduct.Family='Virtual Image';
        boostProduct.Product_Type__c ='EDGECONNECT';
        insert boostProduct;
        
        Product2 plusProduct = new Product2();
        plusProduct.Name = 'EC-PLUS-1Y';
        plusProduct.ProductCode = 'EC-PLUS';
        plusProduct.Model__c = 'EC-PLUS';
        plusProduct.Family='Virtual Image';
        plusProduct.Product_Type__c ='EDGECONNECT';
        insert plusProduct;
        
        Product2 saasProduct = new Product2();
        saasProduct.Name = 'EC-SAAS-1Y';
        saasProduct.ProductCode = 'EC-SAAS';
        saasProduct.Model__c = 'EC-SAAS';
        saasProduct.Family='Virtual Image';
        saasProduct.Product_Type__c ='EDGECONNECT';
        insert saasProduct;
        
        Product2 orchProduct = new Product2();
        orchProduct.Name = 'EC-ORCH-AAS-S-1Y';
        orchProduct.ProductCode = 'EC-ORCH-AAS-S';
        orchProduct.Model__c = 'EC-ORCH-AAS-S';
        orchProduct.Family='Virtual Image';
        orchProduct.Product_Type__c ='EDGECONNECT';
        insert orchProduct;
        
         Product2 spProd = new Product2();
        spProd.Name = 'EC-SP-B-1000';
        spProd.ProductCode = 'EC-SP-B-1000';
        spProd.Model__c = 'EC-SP-B-1000';
        spProd.Family='Virtual Image';
        spProd.Product_Type__c ='EC-SP-Perpetual';
        insert spProd;
           Product2 spProd1 = new Product2();
        spProd1.Name = 'EC-SP';
        spProd1.ProductCode = 'EC-SP-B-1000';
        spProd1.Model__c = 'EC-SP-B-1000';
        spProd1.Family='Virtual Image';
        spProd1.Product_Type__c ='EC-SP-Perpetual';
        insert spProd1;
        
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = baseProduct.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c = 10;
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        License__c objLicense= new License__c();
        objLicense.AssetId__c=asset.Id;
        objLicense.License_Expiration__c=Date.today().addYears(1);
        insert objLicense;
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = boostProduct.Id;
        asset1.Status = 'Customer Subscription Active';
        asset1.Quantity = 1;
        asset1.Bandwidth_Nodes__c = 10;
        asset1.Sync_With_Cloud_Portal__c=true;
        asset1.Cloud_Portal_Sync_Status__c='Pending';
        insert asset1;
        objLicense= new License__c();
        objLicense.AssetId__c=asset1.Id;
        objLicense.License_Expiration__c=Date.today().addYears(1);
        Asset asset2= new Asset();
        asset2.Name = '001BBC039649_t';
        asset2.SerialNumber = '001BBC039649_t';
        asset2.AccountId = acc.Id;
        asset2.Product2Id = plusProduct.Id;
        asset2.Status = 'Customer Subscription Active';
        asset2.Quantity = 1;
        asset2.Licenses_Nodes__c = 10;
        asset2.Sync_With_Cloud_Portal__c=true;
        asset2.Cloud_Portal_Sync_Status__c='Pending';
        insert asset2;
        objLicense= new License__c();
        objLicense.AssetId__c=asset2.Id;
        objLicense.License_Expiration__c=Date.today().addYears(1);
        Asset asset3= new Asset();
        asset3.Name = '001BBC039649_t';
        asset3.SerialNumber = '001BBC039649_t';
        asset3.AccountId = acc.Id;
        asset3.Product2Id = saasProduct.Id;
        asset3.Status = 'Customer Subscription Active';
        asset3.Quantity = 1;
        asset3.Sync_With_Cloud_Portal__c=true;
        asset3.Cloud_Portal_Sync_Status__c='Pending';
        insert asset3;
        objLicense= new License__c();
        objLicense.AssetId__c=asset3.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        insert objLicense;
        
        Asset asset4= new Asset();
        asset4.Name = '001BBC039649_t';
        asset4.SerialNumber = '001BBC039649_t';
        asset4.AccountId = acc.Id;
        asset4.Product2Id = orchProduct.Id;
        asset4.Status = 'Customer Subscription Active';
        asset4.Quantity = 1;
        asset4.Sync_With_Cloud_Portal__c=true;
        asset4.Cloud_Portal_Sync_Status__c='Pending';
        insert asset4;
        objLicense= new License__c();
        objLicense.AssetId__c=asset4.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        insert objLicense;
        
        Asset asset5= new Asset();
        asset5.Name = '001BBC039649_t';
        asset5.SerialNumber = '001BBC039649_t';
        asset5.AccountId = acc.Id;
        asset5.Product2Id = spProd.Id;
        asset5.Status = 'Customer Subscription Active';
        asset5.Quantity = 1;
        asset5.Sync_With_Cloud_Portal__c=true;
        asset5.Cloud_Portal_Sync_Status__c='Pending';
        insert asset5;
        objLicense= new License__c();
        objLicense.AssetId__c=asset5.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        insert objLicense;
        
        Asset asset6= new Asset();
        asset6.Name = '001BBC039649_t';
        asset6.SerialNumber = '001BBC039649_t';
        asset6.AccountId = acc.Id;
        asset6.Product2Id = spProd1.Id;
        asset6.Status = 'Customer Subscription Active';
        asset6.Quantity = 1;
        asset6.Sync_With_Cloud_Portal__c=true;
        asset6.Cloud_Portal_Sync_Status__c='Pending';
        insert asset6;
        objLicense= new License__c();
        objLicense.AssetId__c=asset6.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        insert objLicense;
        
        
        
        
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
     @IsTest
    public static void TestBatchAssets_GetExistingAccount_PostAsset()
    {
        Account acc= new Account(Name='acme_test',Sync_Virtual_Assets_with_CP__c=true);
        insert acc;
        Api_Configuration__c apicOnfig= new Api_Configuration__c(Base_Endpoint__c='https://portaleng.silverpeaksystems.net/portal',Endpoint_URL__c='https://portaleng.silverpeaksystems.net/portal/apis/rest',Environment_Name__c='Cloud Portal Testing',UserName__c='abc@silver-peak.com',Password__c='test');
        insert apicOnfig;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-6Y';
        product.ProductCode = 'EC-BASE';
        product.Model__c = 'EC-BASE';
        product.Family='Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Subscription Active';
        asset1.Quantity = 1;
        asset1.Sync_With_Cloud_Portal__c=true;
        asset1.Cloud_Portal_Sync_Status__c='Pending';
        insert asset1;
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        Test.stopTest();
    }
    
     @IsTest
    public static void TestBatchAssets_CreateNewAccount_PostAsset()
    {
        Account acc= new Account(Name='acme_test',Sync_Virtual_Assets_with_CP__c=true);
        insert acc;
     	Api_Configuration__c apicOnfig= new Api_Configuration__c(Base_Endpoint__c='https://portaleng.silverpeaksystems.net/portal',Endpoint_URL__c='https://portaleng.silverpeaksystems.net/portal/apis/rest',Environment_Name__c='Cloud Portal Testing',UserName__c='abc@silver-peak.com',Password__c='test');
        insert apicOnfig;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        CloudPortalAccountHelper.CreateAccount(acc.Id, acc.Name);
        Test.stopTest();
    }
    
    @IsTest
    public static void TestBatchAssets_CreateNewAccount_PostAsset_Error()
    {
        Account acc= new Account(Name='acme_test',Sync_Virtual_Assets_with_CP__c=true);
        insert acc;
     	Api_Configuration__c apicOnfig= new Api_Configuration__c(Base_Endpoint__c='https://portaleng.silverpeaksystems.net/portal',Endpoint_URL__c='https://portaleng.silverpeaksystems.net/portal/apis/rest',Environment_Name__c='Cloud Portal Testing',UserName__c='abc@silver-peak.com',Password__c='test');
        insert apicOnfig;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(500, 'OK', 'String body', new Map<String, String> ()));
        CloudPortalAccountHelper.CreateAccount(acc.Id, acc.Name);
        Test.stopTest();
    }
  
}