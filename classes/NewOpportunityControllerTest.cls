@isTest
public class NewOpportunityControllerTest
{
    @isTest(SeeAllData = true)
    static void testNewOpportunityController()
    {
        /*PageReference page = new PageReference('/apex/NewOpportunity');
        Test.setCurrentPage(page);
        ApexPages.StandardController standardController = new ApexPages.StandardController(new Opportunity());
        NewOpportunityController controller = new NewOpportunityController(standardController);
        
        controller.Email = 'test';
        controller.search();
        
        List<LeadStatus> convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true order by SortOrder];
        controller.LeadConvertStatus = convertStatus[0].MasterLabel;
        Lead lead = new Lead(LastName = 'TestLead', Company = 'Luffy');
        insert lead;
        controller.LeadSource = lead.Id;
        controller.ContactSource = 'new';
        controller.AccountSource = 'new';
        controller.next();
        controller.save();
        
        Account account = new Account(Name = 'TestAccount');
        insert account;
        Contact contact = new Contact(LastName = 'TestContact', AccountId = account.Id);
        insert contact;
        controller.LeadSource = 'new';
        controller.ContactSource = contact.Id;
        controller.AccountSource = account.Id;
        controller.next();
        controller.saveAndNew();
        
        controller.prev();
        NewOpportunityController.pushContacts(controller.AccountSource);*/
    }
}