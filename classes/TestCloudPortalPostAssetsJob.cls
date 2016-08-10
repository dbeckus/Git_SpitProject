@IsTest
public class TestCloudPortalPostAssetsJob {
    @IsTest
    public static void TestBatchAssets_ExistingAccount()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898');
        insert acc;
        
        Product2 baseProduct = new Product2();
        baseProduct.Name = 'EC-BASE-1Y';
        baseProduct.ProductCode = 'EC-BASE';
        baseProduct.Model__c = 'EC-BASE';
        baseProduct.Family='Virtual Image';
        insert baseProduct;
        
        Product2 boostProduct = new Product2();
        boostProduct.Name = 'EC-BOOST-1Y';
        boostProduct.ProductCode = 'EC-BOOST';
        boostProduct.Model__c = 'EC-BOOST';
        boostProduct.Family='Virtual Image';
        insert boostProduct;
        
        Product2 plusProduct = new Product2();
        plusProduct.Name = 'EC-PLUS-1Y';
        plusProduct.ProductCode = 'EC-PLUS';
        plusProduct.Model__c = 'EC-PLUS';
        plusProduct.Family='Virtual Image';
        insert plusProduct;
        
        Product2 saasProduct = new Product2();
        saasProduct.Name = 'EC-SAAS-1Y';
        saasProduct.ProductCode = 'EC-SAAS';
        saasProduct.Model__c = 'EC-SAAS';
        saasProduct.Family='Virtual Image';
        insert saasProduct;
        
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
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
     @IsTest
    public static void TestBatchAssets_GetExistingAccount_PostAsset()
    {
        Account acc= new Account(Name='acme_test');
        insert acc;
        
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
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
        Database.executeBatch(obj);
        Test.stopTest();
    }
}