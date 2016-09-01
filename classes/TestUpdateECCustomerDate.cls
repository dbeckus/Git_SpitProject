@IsTest
public class TestUpdateECCustomerDate {
    @IsTest(SeeAllData=true)
    public static void TestUpdateECCustomerDate_EC()
    {
        Test.startTest();
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
      
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:acc.Id];
        System.assert(actualAcc.EC_Customer_Date__c!=null);
        Test.stopTest();
    }
    
     @IsTest(SeeAllData=true)
    public static void TestUpdateECCustomerDate_EC_ChangeAcctId()
    {
        Test.startTest();
        Account acc= new Account(Name='acme');
        insert acc;
         Account newacc= new Account(Name='new acme');
        insert newacc;
        
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
      	
        asset.AccountId=newacc.Id;
        update asset;
        
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:newacc.Id];
        System.assert(actualAcc.EC_Customer_Date__c!=null);
        Test.stopTest();
    }
    
 	 @IsTest(SeeAllData=true)
    public static void TestUpdateECCustomerDate_VX()
    {
        Test.startTest();
        Account acc= new Account(Name='acme');
        insert acc;
        
        Product2 product = new Product2();
        product.Name = 'VX-2000';
        product.ProductCode = 'VX-2000';
        product.Model__c = 'VX-2000';
        
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
     
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:acc.Id];
        System.assert(actualAcc.EC_Customer_Date__c==null);
        Test.stopTest();
    }
}