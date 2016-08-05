/**
 * one time scheudle job
 */
global class ShareLeadAndOpportunityToPartnerSchedule implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        String soql = 'select Id, IsConverted, ConvertedOpportunityId, Registered_Distributor_Contact__c, Registered_Partner_Sales_Rep__c, Registered_Distributor__c, Registered_Partner__c, OwnerId from Lead where RecordType.Name = \'Deal Registration\' and IsConverted=false';
        ShareLeadAndOpportunityToPartnerBatch job = new ShareLeadAndOpportunityToPartnerBatch(soql);
        Database.executeBatch(job, 10);
        
        String soql2 = 'select Id, Name, StageName, CloseDate, Registered_Distributor__c, Registered_Distributor_Contact__c, Registering_Partner__c, Registering_Partner_Sales_Rep__c, OwnerId from Opportunity where IsClosed=false and (Registering_Partner__c != null or Registered_Distributor__c != null)';
        ShareLeadAndOpportunityToPartnerBatch job2 = new ShareLeadAndOpportunityToPartnerBatch(soql2);
        Database.executeBatch(job2, 10);
    }
}