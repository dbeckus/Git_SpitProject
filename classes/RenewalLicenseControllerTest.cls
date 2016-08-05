/*
 * Test RenewalLicenseController
 */
@isTest
public class RenewalLicenseControllerTest
{    
    @isTest
    static void testRenewalLicenseController()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact(LastName = 'acme', AccountId = account.Id);
        insert contact;
        Asset asset = new Asset(Name = 'acme', AccountId = account.Id, ContactId = contact.Id);
        insert asset;
        
        ApexPages.StandardController stController = new ApexPages.StandardController(asset);
        RenewalLicenseController controller = new RenewalLicenseController(stController);
        system.assert(controller.License.Start_Date__c == Date.today());
        controller.License.License_Expiration__c = Date.today().addDays(30);
        controller.renewLicense();
        RenewalLicenseController.hasLicenseGenerated(new List<String>());
    }
}