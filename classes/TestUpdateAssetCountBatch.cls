@IsTest
public class TestUpdateAssetCountBatch {
    
    @IsTest
    public static void TestUpdateAssetCount_Batch()
    {
        Account acc = new Account(name='acme',Type='Prospect');
        insert acc;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Product_Category__c='Virtual Image', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Asset assetData= new Asset();
        assetData.Name='test Account';
        assetData.Status='Customer Subscription Active';
        assetData.Product2Id=testProduct.Id;
        assetData.AccountId=acc.id;
        assetData.Quantity=1;
        assetData.SerialNumber = '001BBC039649_t';
        insert assetData;
        Test.startTest();
        UpdateAssetCountBatch obj= new UpdateAssetCountBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        Account actAccount=[Select Id,Type,Active_Asset_Count__c from Account where Id=:acc.Id];
        System.assertEquals(1, actAccount.Active_Asset_Count__c);
    }
}