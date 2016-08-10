@isTest
public class ShareLeadAndOpportunityToPartnerTest
{
    @isTest
    static void testLeadShare()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            Account acc = new Account(Name='acme', Type='Partner');
            insert acc;
            Lead lead = new Lead(LastName = 'test', Company = 'test', RecordTypeId = recordTypes[0].Id, Registered_Partner__c = acc.Id);
            insert lead;
            ShareLeadAndOpportunityToPartnerHelper.shareLeads(new List<Lead> {lead});
            lead.Registered_Partner__c = null;
            update lead;
        }
    }
    
    @isTest
    static void testOpportunityShare()
    {
        Account acc = new Account(Name='acme', Type='Partner');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'test', AccountId=acc.Id, CloseDate=Date.today(), StageName='Discovery', Registering_Partner__c = acc.Id);
        insert opp;
        ShareLeadAndOpportunityToPartnerHelper.shareOpportunities(new List<Opportunity> {opp});
    }
    
    @isTest
    static void testSchedule()
    {
        Test.startTest();
        ShareLeadAndOpportunityToPartnerSchedule schedulable = new ShareLeadAndOpportunityToPartnerSchedule();
        SchedulableContext ctx;
        schedulable.execute(ctx);
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    static void testBatch()
    {
        Test.startTest();
        String soql = 'select Id, IsConverted, ConvertedOpportunityId, Registered_Distributor_Contact__c, Registered_Partner_Sales_Rep__c, Registered_Distributor__c, Registered_Partner__c, OwnerId from Lead where RecordType.Name = \'Deal Registration\' limit 1';
        ShareLeadAndOpportunityToPartnerBatch currentBatchJob = new ShareLeadAndOpportunityToPartnerBatch(soql);
        Database.executeBatch(currentBatchJob, 1);
        Test.stopTest();
    }
}