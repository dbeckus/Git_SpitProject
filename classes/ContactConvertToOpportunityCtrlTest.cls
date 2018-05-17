/**
 * The test class of ContactConvertToOpportunityController class.
 *
 * @author  SnapBI
 * @version 1.0
 *
 * @changelog
 * 5/15/2015 Matt Yuan - Created.
 */

@isTest
private class ContactConvertToOpportunityCtrlTest
{
    @isTest static void testConvertToNew()
    {
        Account acc = new Account(name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        
        ContactConvertToOpportunityController ctrl = new ContactConvertToOpportunityController(new ApexPages.StandardController(ct));
        ctrl.ConvertToNewOpportunity();
        
        System.assert(ctrl.OpportunityId != null);
    }
    
     @isTest static void testConvertToNew_CheckDuplicate()
    {
        Account acc = new Account(name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        
        ContactConvertToOpportunityController ctrl = new ContactConvertToOpportunityController(new ApexPages.StandardController(ct));
        ctrl.ConvertToNewOpportunity();
        
        ctrl = new ContactConvertToOpportunityController(new ApexPages.StandardController(ct));
        System.assert(ctrl.ExistingOpps.size()>0);
        ctrl.ConvertToNewOpportunity();
        
        System.assert(ctrl.OpportunityId != null);
    }
    
    @isTest static void testConvertToExisting()
    {
        Account acc = new Account(name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Opportunity opp = new Opportunity(AccountId=acc.Id, StageName='Discovery', Name='acme', CloseDate=Date.today());
        insert opp;
        
        ContactConvertToOpportunityController ctrl = new ContactConvertToOpportunityController(new ApexPages.StandardController(ct));
        System.assertEquals(1, ctrl.OpportunityOptions.size());
        ctrl.ConvertToExistingOpportunity();
    }
}