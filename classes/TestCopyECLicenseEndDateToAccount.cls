@IsTest
public class TestCopyECLicenseEndDateToAccount {
    @IsTest
    public static void TestCopyLicenseEndDate_Insert()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Asset asset= new Asset(Product2Id=testProduct.Id,AccountId=acc.Id,Status='Customer Subscription Active',Name='test',SerialNumber='tesr878');
        insert asset;
        License__c objLicense=new License__c();
        objLicense.AssetId__c=asset.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        objLicense.Model__c='ECBASE1Y';
        insert objLicense;
        Account resultAcc=[Select Id,EC_End_Date__c from Account where Id=:acc.Id];
        System.assertEquals(Date.today().addYears(2), resultAcc.EC_End_Date__c);
    }
    
     @IsTest
    public static void TestCopyLicenseEndDate_Update()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT');
        insert testProduct;
        Asset asset= new Asset(Product2Id=testProduct.Id,AccountId=acc.Id,Status='Customer Subscription Active',Name='test',SerialNumber='tesr878');
        insert asset;
        License__c objLicense=new License__c();
        objLicense.AssetId__c=asset.Id;
        objLicense.License_Expiration__c=Date.today().addYears(2);
        objLicense.Model__c='ECBASE1Y';
        insert objLicense;
        Account resultAcc=[Select Id,EC_End_Date__c from Account where Id=:acc.Id];
        System.assertEquals(Date.today().addYears(2), resultAcc.EC_End_Date__c);
        objLicense.License_Expiration__c=Date.today().addYears(3);
        update objLicense;
        resultAcc=[Select Id,EC_End_Date__c from Account where Id=:acc.Id];
        System.assertEquals(Date.today().addYears(3), resultAcc.EC_End_Date__c);
    }
    

}