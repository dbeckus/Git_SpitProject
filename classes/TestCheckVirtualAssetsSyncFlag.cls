@isTest
public class TestCheckVirtualAssetsSyncFlag {
    @isTest
    public static void TestAssetsCheckSyncFlag_Software()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Product2 testProduct = new Product2(Name='EC-BASE-5Y',Model__c='EC-BASE-5Y', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Asset asset= new Asset(Product2Id=testProduct.Id,AccountId=acc.Id,Status='Customer Subscription Active',Name='test',SerialNumber='tesr878',Sync_With_Cloud_Portal__c=true);
        insert asset;
        Test.startTest();
        CheckVirtualAssetsSyncFlag obj = new CheckVirtualAssetsSyncFlag();
        Database.executeBatch(obj,1);
        Test.stopTest();
    }
    
     @isTest
    public static void TestAssetsCheckSyncFlag_Hardware()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Product2 testProduct = new Product2(Name='acme', Forecast_Category__c = 'Product', Family='Product', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Asset asset= new Asset(Product2Id=testProduct.Id,AccountId=acc.Id,Status='Customer Owned',Name='test',SerialNumber='tesr878',Sync_With_Cloud_Portal__c=true);
        insert asset;
        Test.startTest();
        CheckVirtualAssetsSyncFlag obj = new CheckVirtualAssetsSyncFlag();
        Database.executeBatch(obj,1);
        Test.stopTest();
    }

}