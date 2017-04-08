@IsTest
public class TestCalculateActiveAssetCount {
    
    @IsTest
    public static void AssetCountInsert()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Licenses_Nodes__c=10;
        insert asset;
        Test.startTest();
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        ID batchid=Database.executeBatch(obj,1);
        //System.abortJob(batchid);
        Test.stopTest();
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
    @IsTest
    public static void AssetCountUpd_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
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
        Test.startTest();
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        ID batchid=Database.executeBatch(obj,1);
        //System.abortJob(batchid);
        Test.stopTest();
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
    }
    @IsTest
    public static void AssetCountDel_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
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
        Test.startTest();
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        ID batchid=Database.executeBatch(obj,1);
        //System.abortJob(batchid);
        Test.stopTest();
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        
    }
    @IsTest
    public static void AssetCountUnDel_Zero()
    {
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
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
        Test.startTest();
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        ID batchid=Database.executeBatch(obj,1);
        //System.abortJob(batchid);
        Test.stopTest();
        actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
    @IsTest
    public static void AssetCountChangeAcctname_Zero()
    {
        
        Account acc= new Account(Name='acme');
        insert acc;
        System.debug(acc.Id);
        Account acc1= new Account(Name='acme1test');
        insert acc1;
        System.debug(acc1.Id);
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Product_Type__c = 'EDGECONNECT';
        product.Family = 'Virtual Image';
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
        
        List<Account> lstAcc=[Select Id from Account where Trigger_Active_Asset_Count__c=true];
        System.debug('Before Batch '+ lstAcc.size());
        System.debug(lstAcc[0].Id);
        System.debug(lstAcc[1].Id);
       
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        Database.executeBatch(obj,1);
       
        Account actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(0, actualAcc.Active_Asset_Count__c);
        actualAcc=[Select Id,Active_Asset_Count__c from Account where Id=:acc1.Id];
        System.assertEquals(1, actualAcc.Active_Asset_Count__c);
        
    }
}