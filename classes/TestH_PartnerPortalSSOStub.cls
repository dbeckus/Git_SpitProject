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
    static void testGetSSOLink_Name() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test');
        
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
                String ssoLink = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
                System.debug('ssoLink'+ssoLink);
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
                String ssoLink = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
                System.debug('ssoLink'+ssoLink);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest
    static void testGetSSOLink_Id() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentId__c='Test');
        
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
                String ssoLink = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
                System.debug('ssoLink'+ssoLink);
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
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                String ssoLink = HPartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
                System.debug('ssoLink'+ssoLink);
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
}