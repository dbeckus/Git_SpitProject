@isTest
private class PartnerPortalSSOStubTest 
{  
    @isTest 
    static void testGetToken() 
    {
        Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
        String token = PartnerPortalSSOStub.getToken();
        System.assertEquals(token, 'x1x2x3x4x5');
    }
    
    
    @isTest 
    static void testGetSSOLink() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'TestAccount', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id, LmsDepartmentId__c = '12345');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'test@test.com');
        insert portalContact;
        Test.startTest();
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345uniquetest@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
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
            
            //Test.setMock(WebServiceMock.class, new PartnerPortalWebServiceMock());
            Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                String ssoLink = PartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
            }
            catch(Exception ex) {}
            Test.stopTest();
        }  
    }
    
    @isTest 
    static void testGetSSOLink2() 
    {
        Id accountType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Resellers').getRecordTypeId();
        Account portalAccount = new Account(Name = 'TestAccount', RecordTypeId = accountType);
        insert portalAccount;
        insert new Partner_Account_Profile__c(Account__c = portalAccount.Id, LmsDepartmentName__c = 'Acme');
        
        Contact portalContact = new Contact( FirstName = 'Test', Lastname = 'Amit', AccountId = portalAccount.Id, Email = 'test@test.com');
        insert portalContact;
       
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = '13g-SP Partner Community' Limit 1];
        User portalUser = new User(
            Username = 'test12345unique233test@test.com',
            ContactId = portalContact.Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'xxxx@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Harry',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert portalUser;
        portalContact.OwnerId = portalUser.Id;
        update portalContact;
        
        System.runAs(portalUser){
           Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PartnerPortalApiMock(200, 'OK', 'String body', new Map<String, String> ()));
            try
            {
                String ssoLink = PartnerPortalSSOStub.getSSOLink(UserInfo.getUserId());
            }
            catch(Exception ex) {}
            
            Test.stopTest();
        }  
    }
}