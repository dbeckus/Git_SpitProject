@IsTest
public class TestUpdateActiveAssetCount {
    
    @IsTest
    public static void AssetCountInsert()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
    
    @IsTest
    public static void AssetCountUpd_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        asset.Status='Write-Off';
        update asset;
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
    }
    
    @IsTest
    public static void AssetCountDel_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        delete asset;
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
    }
    @IsTest
    public static void AssetCountUnDel_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        delete asset;
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
        undelete asset;
        actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
    
     @IsTest
    public static void AssetCountChangeAcctname_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account acc1= new Account(Name='acme1');
        insert acc1;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        asset.AccountId=acc1.Id;
        update asset;
        
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc1.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
}