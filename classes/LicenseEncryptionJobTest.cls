@isTest
public class LicenseEncryptionJobTest
{
    @isTest
    static void test1()
    {
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id, Email='acme@test.com');
        insert ct;
        Product2 prd1 = new Product2(Name='acme', ProductCode='acme', Family='Virtual', Model__c='GX-V', Product_Category__c='GMS');
        insert prd1;
        Asset asset1 = new Asset(Product2Id=prd1.Id, Name='acme', AccountId=acc.id, ContactId=ct.Id, SerialNumber='123456789012');
        insert asset1;
        License__c license1 = new License__c(Assetid__c=asset1.Id, Start_Date__c=Date.today(), Quantity__c=1, License_Expiration__c=Date.today().addYears(1) );
        insert license1;
        
        Test.setMock(HttpCalloutMock.class, new LicenseServerMockImpl());
        Test.startTest();
        
        LicenseEncryptionJob job = new LicenseEncryptionJob();
        job.LicenseIds = new List<Id> { license1.Id };
        System.enqueueJob(job);
        
        Test.stopTest();
    }
    
    @isTest
    static void test2()
    {
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id, Email='acme@test.com');
        insert ct;
        Product2 prd2 = new Product2(Name='acme', ProductCode='acme', Family='Virtual');
        insert prd2;
        Asset asset2 = new Asset(Product2Id=prd2.Id, Name='acme', AccountId=acc.id, ContactId=ct.Id, SerialNumber='123456789012');
        insert asset2;
        License__c license2 = new License__c(Assetid__c=asset2.Id, Start_Date__c=Date.today(), Quantity__c=1, License_Expiration__c=Date.today().addYears(1) );
        insert license2;
        
        Test.setMock(HttpCalloutMock.class, new LicenseServerMockImpl());
        Test.startTest();
        
        LicenseEncryptionJob job = new LicenseEncryptionJob();
        job.LicenseIds = new List<Id> { license2.Id };
        System.enqueueJob(job);
        
        Test.stopTest();
    }
    
    public class LicenseServerMockImpl implements HttpCalloutMock 
    { 
        public HttpResponse respond(HttpRequest req) 
        {
            HttpResponse response = new HttpResponse();
            return response;
        } 
    }
}