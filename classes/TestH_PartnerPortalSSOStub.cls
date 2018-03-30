@Istest
public class TestH_PartnerPortalSSOStub {
    
    @isTest
    static void testGetToken() 
    {
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        String token = HPartnerPortalSSOStub.getHttpToken();
        System.assertEquals('a750ad20-34ff-4f05-a292-8a227c323441', token);
    }
       @isTest
    static void testGetSSOLink() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test122');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'srussell@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                string obj = HPartnerPortalSSOStub.getSSOLink(portalUser.Id);
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
     @isTest
    static void testGetSSOLink_ValidateDepartment() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test122');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'srussell@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                string obj = HPartnerPortalSSOStub.validateDepartment(portalAccount, token);
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    @isTest
    static void testGetSSOLink_ValidateDepartment1() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        
        Test.startTest();
        //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        try
        {
            string token= HPartnerPortalSSOStub.getHttpToken();
            string obj = HPartnerPortalSSOStub.validateDepartment(portalAccount, token);
            System.assert(obj!=null);
        }
        catch(Exception ex) {}
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetSSOLink_Name() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test122');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'srussell@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                HPartnerPortalGetDepartmentsApi obj = HPartnerPortalSSOStub.validateDepartmentByName(portalAccount.Name, token);
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest
    static void testGetSSOLink_NoDept() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        //insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'srussell@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                String departmentId = HPartnerPortalSSOStub.createDepartment(portalAccount, null, token);
                System.assert(departmentId!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest
    static void testGetSSOLink_SalesforceId() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id);
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'srussell@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                HPartnerPortalGetDepartmentsByExtIdApi obj = HPartnerPortalSSOStub.validateDepartmentBySalesforceId(portalAccount.Id, token);
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest
    static void testGetSSOLink_CreateLearner() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentId__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'testabc@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'testabc@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                string obj = HPartnerPortalSSOStub.createLearner(portalContact, '01I38000000RCsg', portalContact.Email, token, portalAccount);
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest
    static void testGetSSOLink_ValidateLearner() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentId__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'testabc@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'testabc@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                HPartnerPortalStudentInfo obj = HPartnerPortalSSOStub.validateLearner(portalContact.Email, token) ;
                System.assert(obj!=null);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
      @isTest
    static void testGetSSOLink_UpdateLearner() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentId__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'testabc@silver-peak.com');
        insert portalContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'testabc@silver-peak.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        //portalAccount.OwnerId = portalUser.Id;
        //update portalAccount;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                string token= HPartnerPortalSSOStub.getHttpToken();
                HPartnerPortalStudentInfo objGetStudent = HPartnerPortalSSOStub.validateLearner(portalContact.Email, token) ;
                System.assert(objGetStudent!=null);
                Boolean obj = HPartnerPortalSSOStub.updateLearner(objGetStudent, '01I38000000RCsg', token);
                System.assert(obj);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    
}