@IsTest
public class TestCloudPortalProvisionAssetsJob {
    @IsTest
    public static void TestBatchProvision()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898');
        insert acc;
       
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
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        asset1.Sync_With_Cloud_Portal__c=true;
        asset1.Cloud_Portal_Sync_Status__c='Pending';
        insert asset1;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalProvisionAssetsJob obj= new CloudPortalProvisionAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
    @IsTest
    public static void TestBatchDecommission()
    {
        Account acc= new Account(Name='acme',Cloud_Portal_Account_Id__c='123666669898');
        insert acc;
       
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
        asset.Sync_With_Cloud_Portal__c=true;
        asset.Cloud_Portal_Sync_Status__c='Pending';
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        //asset1.Sync_With_Cloud_Portal__c=true;
        //asset1.Cloud_Portal_Sync_Status__c='Pending';
        insert asset1;
        
        asset1.AccountId= acc1.Id;
        update asset1;
        Test.setMock(HttpCalloutMock.class, new CloudPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        CloudPortalProvisionAssetsJob obj= new CloudPortalProvisionAssetsJob();
        Database.executeBatch(obj);
        
        Test.stopTest();
    }
}