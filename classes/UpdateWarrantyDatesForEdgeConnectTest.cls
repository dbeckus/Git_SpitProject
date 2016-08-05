@isTest
public class UpdateWarrantyDatesForEdgeConnectTest {
    
    @isTest
    public static void testWarrantyDates_1year()
    {
        Test.startTest();
        Account acc = new Account(Name='Test-Praj EdgeConnect');
        insert acc;
        Contact contact = new Contact(LastName='testPrajEC', AccountId=acc.Id);
        insert contact;
        
        Product2 product1 = new Product2(Name='EC-M-1Y', Family='Product', Product_Category__c='Appliance', IsActive=true);
        insert product1;
        
        Asset asset1 = new Asset(Name='EC-M-1Y',AccountId=acc.Id, ContactId=contact.Id, Product2Id=product1.Id, Ship_Date__c=Date.today());
        insert asset1;
        Asset finalAsset = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id =:asset1.Id];
        System.assertEquals(Date.today().addYears(1), finalAsset.Warranty_End_Date__c);
        Test.stopTest();
    }
     @isTest
    public static void testWarrantyDates_10year()
    {
        Test.startTest();
        Account acc = new Account(Name='Test-Praj EdgeConnect');
        insert acc;
        Contact contact = new Contact(LastName='testPrajEC', AccountId=acc.Id);
        insert contact;
        
        Product2 product1 = new Product2(Name='EC-M-10Y', Family='Product', Product_Category__c='Appliance', IsActive=true);
        insert product1;
        
        Asset asset1 = new Asset(Name='EC-M-10Y',AccountId=acc.Id, ContactId=contact.Id, Product2Id=product1.Id, Ship_Date__c=Date.today());
        insert asset1;
        Asset finalAsset = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id =:asset1.Id];
        System.assertEquals(Date.today().addYears(10), finalAsset.Warranty_End_Date__c);
        Test.stopTest();
    }
    @isTest
    public static void testWarrantyDates_1yearOther()
    {
        Test.startTest();
        Account acc = new Account(Name='Test-Praj EdgeConnect');
        insert acc;
        Contact contact = new Contact(LastName='testPrajEC', AccountId=acc.Id);
        insert contact;
        
        Product2 product1 = new Product2(Name='EC-M', Family='Product', Product_Category__c='Appliance', IsActive=true);
        insert product1;
        
        Asset asset1 = new Asset(Name='EC-M',AccountId=acc.Id, ContactId=contact.Id, Product2Id=product1.Id, Ship_Date__c=Date.today());
        insert asset1;
        Asset finalAsset = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id =:asset1.Id];
        System.assertEquals(Date.today().addYears(1), finalAsset.Warranty_End_Date__c);
        Test.stopTest();
    }
    @isTest
    public static void testWarrantyDates_3year()
    {
        Test.startTest();
        Account acc = new Account(Name='Test-Praj EdgeConnect');
        insert acc;
        Contact contact = new Contact(LastName='testPrajEC', AccountId=acc.Id);
        insert contact;
        
        Product2 product1 = new Product2(Name='EC-M-3Y', Family='Product', Product_Category__c='Appliance', IsActive=true);
        insert product1;
        
        Asset asset1 = new Asset(Name='EC-M-3Y',AccountId=acc.Id, ContactId=contact.Id, Product2Id=product1.Id, Ship_Date__c=Date.today());
        insert asset1;
        Asset finalAsset = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id =:asset1.Id];
        System.assertEquals(Date.today().addYears(3), finalAsset.Warranty_End_Date__c);
        Test.stopTest();
    }
    
    @isTest
    public static void testWarrantyDates_5year()
    {
        Test.startTest();
        Account acc = new Account(Name='Test-Praj EdgeConnect');
        insert acc;
        Contact contact = new Contact(LastName='testPrajEC', AccountId=acc.Id);
        insert contact;
        
        Product2 product1 = new Product2(Name='EC-M-5Y', Family='Product', Product_Category__c='Appliance', IsActive=true);
        insert product1;
        
        Asset asset1 = new Asset(Name='EC-M-5Y',AccountId=acc.Id, ContactId=contact.Id, Product2Id=product1.Id, Ship_Date__c=Date.today());
        insert asset1;
        Asset finalAsset = [Select Id,Ship_Date__c,Warranty_Start_Date__c,Warranty_End_Date__c,Product2.Name from Asset where Id =:asset1.Id];
        System.assertEquals(Date.today().addYears(5), finalAsset.Warranty_End_Date__c);
        Test.stopTest();
    }
}