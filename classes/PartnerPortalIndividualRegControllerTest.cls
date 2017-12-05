@isTest
public class PartnerPortalIndividualRegControllerTest
{
    @isTest
    static void testExisting()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert acc;
        Contact ct = new Contact(AccountId=acc.Id, LastName='acme', Email='acme@test.com');
        insert ct;
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    @isTest
    static void testExistingAccounts()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        Account acc2 = new Account(Name='acme2', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert new Account[]{acc, acc2};
        Contact ct = new Contact(AccountId=acc.Id, LastName='acme', Email='acme@test.com');
        insert ct;
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    @isTest
    static void testMultipleAccountsMatched()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        Account acc2 = new Account(Name='acme2', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert new Account[]{acc, acc2};
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    @isTest
    static void testMultipleContactsMacthed()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        Account acc2 = new Account(Name='acme2', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert new Account[]{acc, acc2};
        Contact ct = new Contact(AccountId=acc.Id, LastName='acme', Email='acme@test.com');
        Contact ct2 = new Contact(AccountId=acc2.Id, LastName='acmes', Email='acme@test.com');
        insert new Contact[] {ct, ct2};
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    @isTest
    static void testExistingUser()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert acc;
        Contact ct = new Contact(AccountId=acc.Id, LastName='acme', Email='acme@test.com');
        insert ct;
        List<Profile> profiles = [select Id from Profile where Name='12a-SP Portal Hi Vol' limit 1];
        Id customerProfileId = (profiles.size()>0)?profiles[0].Id:null;
                User newUser = new User(FirstName='test', 
                                LastName='acme', 
                                Email='acme@test.com', 
                                Username='acme@test.com', 
                                ProfileId=customerProfileId, 
                                ContactId=ct.Id,
                                Alias='camess',
                                TimeZoneSidKey='America/Tijuana',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='ISO-8859-1',
                                LanguageLocaleKey='en_US',
                                Country = 'US',
                                State = 'Goriga',
                                City = 'Atlanta',
                                PostalCode = '30909',
                                Phone = '12345'
                                );
        insert newUser;
        
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    @isTest
    static void testNew()
    {
        Account acc = new Account(Name='acme', Email_Domain_Used__c='@test.com', Partner_Application_Status__c='Approved');
        insert acc;
        PartnerPortalIndividualRegController controller = new PartnerPortalIndividualRegController();
        controller.FirstName = 'acme';
        controller.LastName = 'acme';
        controller.Title = 'acme';
        controller.Email = 'acme@test.com';
        controller.CompanyName = 'acme';
        controller.Phone = '123456';
        controller.PortalTC = true;
        controller.save();
    }
    
    
}