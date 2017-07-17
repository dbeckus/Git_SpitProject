@IsTest
public class TestUpdateCustomerDateonAccount {
    @IsTest
    public static void TestUpdateECCustomerDate_EC()
    {
        
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Family = 'Virtual Image';
        product.Product_Type__c='EDGECONNECT';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Ship_Date__c = Date.today();
        Test.startTest();
        insert asset;
        
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:acc.Id];
        System.assert(actualAcc.EC_Customer_Date__c!=null);
        Test.stopTest();
    }
    @IsTest
    public static void TestUpdateECCustomerDate_EC_ChangeAcctId()
    {
       
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account newacc= new Account(Name='new acme');
        insert newacc;
        
        Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        product.Family = 'Virtual Image';
        product.Product_Type__c='EDGECONNECT';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        asset.Ship_Date__c = Date.today();
        Test.startTest();
        insert asset;
        
        asset.AccountId=newacc.Id;
        update asset;
        
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:newacc.Id];
        System.assert(actualAcc.EC_Customer_Date__c!=null);
        Test.stopTest();
    }
    
    @IsTest
    public static void TestUpdateECCustomerDate_VX()
    {
       
        Account acc= new Account(Name='acme');
        insert acc;
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 product = new Product2();
        product.Name = 'VX-2000';
        product.ProductCode = 'VX-2000';
        product.Model__c = 'VX-2000';
        product.Product_Type__c = 'NX/VX';
        product.Family='Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription';
        asset.Ship_Date__c = Date.today();
        asset.Quantity = 1;
         Test.startTest();
        insert asset;
        
        Account actualAcc=[Select Id,EC_Customer_Date__c from Account where Id=:acc.Id];
        System.assert(actualAcc.EC_Customer_Date__c==null);
        Account actualAcc1=[Select Id,WAN_OP_Customer_Date__c from Account where Id=:acc.Id];
        System.assert(actualAcc1.WAN_OP_Customer_Date__c!=null);
        Test.stopTest();
    }
}