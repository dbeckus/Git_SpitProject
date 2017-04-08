@IsTest
public class TestCalculateAssetCountBatch {
    @IsTest
    public static void TestCalculateAssetCount()
    {
      
        Account acc = new Account(Name='Test Data');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contract con= new Contract();
        con.AccountId=acc.Id;
        con.Contract_Type__c='Gold';
        insert con;
        con.Status='Activated';
        update con;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Product_Type__c='EDGECONNECT', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Asset ecAssetData= new Asset();
        ecAssetData.Name='test Account';
        ecAssetData.Status='Customer Subscription Active';
        ecAssetData.Product2Id=testProduct.Id;
        ecAssetData.AccountId=acc.id;
        ecAssetData.Quantity=1;
        ecAssetData.SerialNumber = '001BBC039649_t';
        insert ecAssetData;
        
        Product2 testProduct1 = new Product2(Name='VX-1000',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Product_Type__c='NX/VX',Family='Virtual Image', IsActive=true);
        insert testProduct1;
        Asset assetData= new Asset();
        assetData.Name='test Account';
        assetData.Status='Customer Subscription';
        assetData.Product2Id=testProduct1.Id;
        assetData.AccountId=acc.id;
        assetData.Quantity=1;
        assetData.SerialNumber = '001BBC039649_t';
        insert assetData;
        
        Product2 testProduct2 = new Product2(Name='VX-3000',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual',Product_Type__c='NX/VX', Family='Virtual Image', IsActive=true);
        insert testProduct2;
        assetData= new Asset();
        assetData.Name='test Account';
        assetData.Status='Customer Owned';
        assetData.Product2Id=testProduct2.Id;
        assetData.AccountId=acc.id;
        assetData.Quantity=1;
        assetData.SerialNumber = '001BBC039649_t';
        assetData.Contract_Number__c=con.Id;
        insert assetData;
        
        Product2 testProduct3 = new Product2(Name='NX-7700',Product_Category__c='Product', Forecast_Category__c = 'Product',Product_Type__c='NX/VX', Family='Product', IsActive=true);
        insert testProduct3;
        assetData= new Asset();
        assetData.Name='test Account';
        assetData.Status='Customer Owned';
        assetData.Product2Id=testProduct3.Id;
        assetData.AccountId=acc.id;
        assetData.Quantity=1;
        assetData.SerialNumber = '001BBC039649_t';
        assetData.Contract_Number__c=con.Id;
        insert assetData;
        
        Product2 testProduct4 = new Product2(Name='EC-L-1Y',Product_Category__c='Product', Forecast_Category__c = 'Product', Product_Type__c='EDGECONNECT',Family='Product', IsActive=true);
        insert testProduct4;
        assetData= new Asset();
        assetData.Name='test Account';
        assetData.Status='Customer Owned';
        assetData.Product2Id=testProduct4.Id;
        assetData.AccountId=acc.id;
        assetData.Quantity=1;
        assetData.SerialNumber = '001BBC039649_t';
        assetData.Active_EC_Base_License__c = ecAssetData.Id;
        insert assetData;
        
        Test.startTest();
        CalculateActiveAssetCountBatch obj= new CalculateActiveAssetCountBatch();
        Database.executeBatch(obj,1);
        Account acc1= [Select Id, Active_Asset_count__c from Account where Id=:acc.Id];
        System.assertEquals(5,acc1.Active_Asset_count__c);
        Test.stopTest();
        
        
        
        
    }
    @IsTest
    public static void TestCalculateAssetCount_EC()
    {}
    @IsTest
    public static void TestCalculateAssetCount_SP()
    {}
    @IsTest
    public static void TestCalculateAssetCount_VX()
    {}
}