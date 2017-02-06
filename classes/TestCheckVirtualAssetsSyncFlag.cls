@isTest
public class TestCheckVirtualAssetsSyncFlag {
    @isTest
    public static void TestAssetsCheckSyncFlag()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Product2 testProduct = new Product2(Name='acme', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='NX/VX');
        insert testProduct;
        Asset asset= new Asset(Product2Id=testProduct.Id,AccountId=acc.Id,Status='Customer Subscription',Name='test',SerialNumber='tesr878',Sync_With_Cloud_Portal__c=true);
        insert asset;
        Test.startTest();
        CheckVirtualAssetsSyncFlag obj = new CheckVirtualAssetsSyncFlag();
        Database.executeBatch(obj,1);
        Test.stopTest();
    }

}