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