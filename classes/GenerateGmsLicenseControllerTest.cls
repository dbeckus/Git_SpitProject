@isTest
public class GenerateGmsLicenseControllerTest
{
    @isTest
    static void test()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact(LastName = 'acme', AccountId = account.Id);
        insert contact;
        Asset asset = new Asset(Name = 'acme', AccountId = account.Id, ContactId = contact.Id);
        insert asset;
        
        GenerateGmsLicenseController controller = new GenerateGmsLicenseController(new ApexPages.StandardController(asset));
        controller.save();
        GenerateGmsLicenseController.hasLicenseGenerated(controller.License.Id);
    }
}