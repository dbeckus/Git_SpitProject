@IsTest
public class TestTriggerDecomissionOnAssets {
    @IsTest
    public static void DecomissionAsset()
    {
        Account acc= new Account(Name='acme');
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
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        insert asset1;
        Test.startTest();
        asset1.AccountId=acc1.Id;
        update asset1;
        Test.stopTest();
        List<Asset> lstAsset=[Select Id,Cloud_Portal_Sync_Status__c,Sync_With_Cloud_Portal__c from Asset where AccountId=:acc.Id];
        System.assertEquals(lstAsset[0].Cloud_Portal_Sync_Status__c,'Pending');
        System.assertEquals(lstAsset[0].Sync_With_Cloud_Portal__c,true);
        
        
    }
    
    @IsTest
    public static void ProvisionAsset()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account newacc= new Account(Name='new acme');
        insert newacc;
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
        insert asset;
        
        Asset asset1= new Asset();
        asset1.Name = '001BBC039649_t';
        asset1.SerialNumber = '001BBC039649_t';
        asset1.AccountId = acc.Id;
        asset1.Product2Id = product.Id;
        asset1.Status = 'Customer Owned';
        asset1.Quantity = 1;
        insert asset1;
        Test.startTest();
        asset1.AccountId=acc1.Id;
        asset1.Status='Silver Peak Inventory';
        update asset1;
        
        asset1.AccountId=newacc.Id;
        asset1.Status='Customer Owned';
        update asset1;
        Test.stopTest();
       
        
        
    }
    
}