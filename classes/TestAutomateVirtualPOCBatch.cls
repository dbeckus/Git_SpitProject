@IsTest
public class TestAutomateVirtualPOCBatch {
    
    @IsTest(SeeAllData=true) 
    public static void ValidateCustomerPortalEnabled()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        User customerPortalUser = new User(
            profileId = p.id, 
            username = 'acme@acme.com.cp', 
            email = 'acme@acme.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='AcmeLastname', 
            contactId = contact.id
        );
        customerPortalUser.IsActive=true;
        insert customerPortalUser;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.Solution_Type__c='Hybrid WAN';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Shipped', outputPOC.Status__c);
        
        
    }
    
    @IsTest(SeeAllData=true) 
    public static void AllowCustomerSelfRegistration()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            Account acc = new Account(Name='testECPOC',Type='Customer');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Shipped', outputPOC.Status__c);
        Contact updateContact=[Select Id,CanAllowPortalSelfReg from Contact where Id=:contact.Id];
        System.assertEquals(true, updateContact.CanAllowPortalSelfReg);
        
    }
    
    @IsTest(SeeAllData=true) 
    public static void CustomerPortalNotEnabled_NotFulfilled()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            Account acc = new Account(Name='testECPOC',Type='Other');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Approved to Ship', outputPOC.Status__c);
        Contact updateContact=[Select Id,CanAllowPortalSelfReg from Contact where Id=:contact.Id];
        System.assertEquals(false, updateContact.CanAllowPortalSelfReg);
        
    }
    @IsTest(SeeAllData=true) 
    public static void ValidatePartnerPortalLogic()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Profile p = [select Id,name from Profile where Name='13g-SP Partner Community' limit 1];
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        User customerPortalUser = new User(
            profileId = p.id, 
            username = 'acme@acme.com.cp', 
            email = 'acme@acme.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='AcmeLastname', 
            contactId = contact.id
        );
        customerPortalUser.IsActive=true;
        insert customerPortalUser;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Shipped', outputPOC.Status__c);
    }
    @IsTest(SeeAllData=true) 
    public static void CreatePartnerPortalUser()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Account acc = new Account(Name='testECPOC',Type='Partner');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
       	Profile p = [select Id,name from Profile where Name='13g-SP Partner Community' limit 1];
        User partnerUser = new User(
            profileId = p.id, 
            username = 'acme@acme.com.pp', 
            email = 'acme@acme.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='AcmeLastname', 
            contactId = contact.id
        );
        partnerUser.IsActive=true;
        insert partnerUser;
        
        Contact pocontact = new Contact(FirstName = 'AcmeFirstname1', LastName = 'Lastname', Phone='123456789', Email = 'acme1@acme.com' , accountId=acc.Id);
        insert pocontact;
        
        
        
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = pocontact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Shipped', outputPOC.Status__c);
        User updateContact=[Select Id from User where ContactId=:contact.Id];
        System.assert(updateContact!=null);
    }
    @IsTest(SeeAllData=true) 
    public static void PartnerPortalUser_NotEnabled_NotFulfilled()
    {
        //Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Account acc = new Account(Name='testECPOC',Type='Other');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='VX-8000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();
        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Approved to Ship', outputPOC.Status__c);
        
    }
    
    @IsTest(SeeAllData=true)
    public static void GMS_Fulfillment()
    {
        Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Account acc = new Account(Name='testECPOC',Type='Partner');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
       	Profile p = [select Id,name from Profile where Name='13g-SP Partner Community' limit 1];
        User partnerUser = new User(
            profileId = p.id, 
            username = 'acme@acme.com.pp', 
            email = 'acme@acme.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='AcmeLastname', 
            contactId = contact.id
        );
        partnerUser.IsActive=true;
        insert partnerUser;
        
        Contact pocontact = new Contact(FirstName = 'AcmeFirstname1', LastName = 'Lastname', Phone='123456789', Email = 'acme1@acme.com' , accountId=acc.Id);
        insert pocontact;
        
        
        
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = pocontact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='GMS-10';
        request.VirtualProduct2__c='UNITY CLOUD INTELLIGENCE';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        request.VirtualQuantity2__c=1;
        insert request;
        
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();        
        Request__c outputPOC=[Select Id,Status__c from Request__c where Id=:request.Id ];
        System.assertEquals('Shipped', outputPOC.Status__c);
        User updateContact=[Select Id from User where ContactId=:contact.Id];
        System.assert(updateContact!=null);
        List<Asset> asset= [Select Id,Key_Generated__c from Asset where POCRequest__c=: request.Id];
        System.assert(true,asset[0].Key_Generated__c);
        
    }
    
  
    
    @IsTest(SeeAllData=true)
    public static void Multiple_Fulfillment()
    {
        Set<String> customerUserTypes = new Set<String> {'PowerPartner'};
            Account acc = new Account(Name='testECPOC',Type='Partner');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
       Profile p = [select Id,name from Profile where Name='13g-SP Partner Community' limit 1];
        User partnerUser = new User(
            profileId = p.id, 
            username = 'acme@acme.com.pp', 
            email = 'acme@acme.com', 
            emailencodingkey = 'UTF-8', 
            localesidkey = 'en_US', 
            languagelocalekey = 'en_US', 
            timezonesidkey = 'America/Los_Angeles', 
            alias='nuser', 
            lastname='AcmeLastname', 
            contactId = contact.id
        );
        partnerUser.IsActive=true;
        insert partnerUser;
        
        Contact pocontact = new Contact(FirstName = 'AcmeFirstname1', LastName = 'Lastname', Phone='123456789', Email = 'acme1@acme.com' , accountId=acc.Id);
        insert pocontact;
        
        
        
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.OwnerId=usr.Id;
        opportunity.Technical_Responsibility__c=usr.Id;
        opportunity.Solution_Type__c='Hybrid WAN';
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = pocontact.Id);
        request.POC_Type__c='WAN Op';
        request.Requested_Delivery_Date__c=Date.today();
        request.Opportunity__c= opportunity.id;
        request.Status__c='Approved to Ship';
        request.VirtualProduct1__c='GMS-10';
        request.VirtualProduct2__c='VX-9000';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.VirtualQuantity1__c=1;
        request.VirtualQuantity2__c=1;
        insert request;
        
        request.VirtualProduct2__c='';
        update request;
        Test.startTest();
        AutomateVirtualPOCBatch obj = new AutomateVirtualPOCBatch();
        Database.executeBatch(obj);
        Test.stopTest();        
        
        
    }
}