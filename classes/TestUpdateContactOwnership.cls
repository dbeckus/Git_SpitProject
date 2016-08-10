@IsTest
public class TestUpdateContactOwnership {
    
    @Istest(SeeAllData=true)
    public static void TestUpdateConTypeChange()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
       
        User usr1 = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = prof.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr1.IsActive =true;
        insert usr1;
        User usr2 = new User(Alias = 'standt', Email='testUser@uniquetest1.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = prof.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest1.com');
        usr2.IsActive =true;
        insert usr2;
        Patch__c patch= new Patch__c();
        patch.RSM__c=usr1.Id;
        patch.CSM__c=usr2.Id;
        insert patch;
           Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        Account acc = new Account(Name='acme',patch__c=patch.id,Type='Prospect');
        insert acc;
        Contact con1 = new Contact(FirstName='Test',LastName='Con1',email='abc@acme.com',AccountId=acc.Id);
        insert con1;
        Contact con2 = new Contact(FirstName='Test',LastName='Con2',email='abc@acme1.com',AccountId=acc.Id);
        insert con2;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription Active';
        asset.Quantity = 1;
        insert asset;
        
        Contact actCon1=[Select OwnerId from Contact where Id=:con1.Id];
        Contact actCon2=[Select OwnerId from Contact where Id=:con2.Id];
        
        System.assertEquals( patch.RSM__c, actCon1.OwnerId);
        System.assertEquals( patch.RSM__c, actCon2.OwnerId);
        
    }
    @Istest(SeeAllData=true)
    public static void TestUpdateAccTypeChange()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
       
        User usr1 = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = prof.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr1.IsActive =true;
        insert usr1;
        User usr2 = new User(Alias = 'standt', Email='testUser@uniquetest1.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = prof.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest1.com');
        usr2.IsActive =true;
        insert usr2;
        Patch__c patch= new Patch__c();
        patch.RSM__c=usr1.Id;
        patch.CSM__c=usr2.Id;
        insert patch;
           Product2 product = new Product2();
        product.Name = 'EC-BASE-1Y';
        product.ProductCode = 'EC-BASE-1Y';
        product.Model__c = 'EC-BASE-1Y';
        
        insert product;
        Account acc = new Account(Name='acme',patch__c=patch.id,Type='Prospect');
        insert acc;
        Contact con1 = new Contact(FirstName='Test',LastName='Con1',email='abc@acme.com',AccountId=acc.Id);
        insert con1;
        Contact con2 = new Contact(FirstName='Test',LastName='Con2',email='abc@acme1.com',AccountId=acc.Id);
        insert con2;
      	
        acc.Type='Partner';
        update acc;
        
        Contact actCon1=[Select OwnerId from Contact where Id=:con1.Id];
        Contact actCon2=[Select OwnerId from Contact where Id=:con2.Id];
        
        System.assertEquals( patch.CSM__c, actCon1.OwnerId);
        System.assertEquals( patch.CSM__c, actCon2.OwnerId);
        
    }
}