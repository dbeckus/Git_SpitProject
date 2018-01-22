@isTest
public class SubscriptionExpirationReminderJobTest
{
    @isTest
    static void test()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='product', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='T-30', ContactId=contact.Id, Product2Id=product.Id);
        Asset asset2 = new Asset(Name='T0', ContactId=contact.Id, Product2Id=product.Id);
        Asset asset3 = new Asset(Name='T30', ContactId=contact.Id, Product2Id=product.Id);
        Asset asset4 = new Asset(Name='T60', ContactId=contact.Id, Product2Id=product.Id);
        Asset asset5 = new Asset(Name='T90', ContactId=contact.Id, Product2Id=product.Id);
        insert new List<Asset> { asset1, asset2, asset3, asset4, asset5};
        License__c license1 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(-30), Quantity__c=1, AssetId__c=asset1.Id);
        License__c license2 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(-1), Quantity__c=1, AssetId__c=asset2.Id);
        License__c license3 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(30), Quantity__c=1, AssetId__c=asset3.Id);
        License__c license4 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(60), Quantity__c=1, AssetId__c=asset4.Id);
        License__c license5 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(90), Quantity__c=1, AssetId__c=asset5.Id);
        insert new List<License__c> { license1, license2, license3, license4, license5 };
        
        Test.startTest();
        Database.executeBatch(new SubscriptionExpirationReminderJob(), 1);
        Test.stopTest();
    }
    
     @isTest
    static void test_CustomerEvaluationAssets()
    {
          Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='product', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='T-0', ContactId=contact.Id, Product2Id=product.Id,Status='Customer Evaluation');
       
        insert new List<Asset> { asset1};
        License__c license1 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(-1), Quantity__c=1, AssetId__c=asset1.Id);
        
        insert new List<License__c> { license1};
        
        Test.startTest();
        Database.executeBatch(new SubscriptionExpirationReminderJob(), 1);
        Test.stopTest();
    }
    
     @isTest
    static void test_CustomerSubscriptionAssets()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact contact = new Contact(LastName='acme', AccountId=acc.Id);
        insert contact;
        Product2 product = new Product2(Name='product', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='T-0', ContactId=contact.Id, Product2Id=product.Id,Status='Customer Subscription');
       
        insert new List<Asset> { asset1};
        License__c license1 = new License__c(Start_Date__c=Date.today(), License_Expiration__c=Date.today().addDays(-1), Quantity__c=1, AssetId__c=asset1.Id);
        
        insert new List<License__c> { license1};
        
        Test.startTest();
        Database.executeBatch(new SubscriptionExpirationReminderJob(), 1);
        Test.stopTest();
    }
}