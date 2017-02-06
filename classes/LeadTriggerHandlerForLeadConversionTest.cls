/**
 * The test class for LeadTriggerHandlerForLeadConversion trigger hanlder class.
 *
 * @author  SnapBI
 * @version 1.0
 *
 * @changelog
 * 10/6/2015 Matt - Created.
 */

@isTest
private class LeadTriggerHandlerForLeadConversionTest
{
    @testSetup static void setup()
    {
        TriggerHandlerSetting__c ths = new TriggerHandlerSetting__c(Name = '1', SObjectType__c = 'Lead', Handler__c = 'LeadTriggerHandlerForLeadConversion');
        insert ths;
    }

    @isTest static void test()
    {
        Lead lead = new Lead(LastName = 'acme', Company = 'acme', Trial_Request_from_Marketplace__c = false);
        insert lead;
        LeadStatus ls = [select MasterLabel from LeadStatus where IsConverted = true limit 1];
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(ls.MasterLabel);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        if(lcr.isSuccess())
        {
            Contact contact = [select Id, Lead_Status__c from Contact where Id = :lcr.getContactId()];
            System.assertEquals(ls.MasterLabel, contact.Lead_Status__c);
        }
        else
        {
            System.assert(false, 'Failed to convert lead.');
        }
    }
}