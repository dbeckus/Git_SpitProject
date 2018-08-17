@isTest
private class PartnerPortalSSOControllerTest 
{	
	@isTest 
	static void testPartnerPortalSSOController() 
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
                PartnerPortalSSOController controller = new PartnerPortalSSOController();
               	controller.redirect();
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
           
	}
    
    @isTest 
	static void testPartnerPortalSSOControllerProfile_Invalid() 
	{
      Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
      
        Profile systemProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ProfileId = systemProfile.Id,
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
                PartnerPortalSSOController controller = new PartnerPortalSSOController();
               	controller.redirect();
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
           
	}
    @isTest 
	static void testPartnerPortalSSOController_CustomerUser() 
	{
      Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'Test', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id,LmsDepartmentName__c='Test');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'srussell@silver-peak.com');
        insert portalContact;
      
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '12-SP Portal' Limit 1];
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
  
        
        System.runAs(portalUser){
              Test.startTest();
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                PartnerPortalSSOController controller = new PartnerPortalSSOController();
               	controller.redirect();
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
           
	}
}