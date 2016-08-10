/**
 * The test class of LeadConvertToOpportunityController.
 *
 * @author  SnapBI
 * @version 1.0
 *
 * @changelog
 * 5/15/2015 Matt Yuan - Created.
 */
 
@isTest
private class LeadConvertToOpportunityCtrlTest
{
    @isTest static void test()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        
        LeadConvertToOpportunityController ctrl = new LeadConvertToOpportunityController(new ApexPages.StandardController(ld));
        ctrl.Contact.AccountId = acc.Id;
        System.assertEquals(3, ctrl.ContactOptions.size());
        System.assertEquals(1, ctrl.OpportunityOptions.size());
        ctrl.convert();
    }
}