/**
 * one time scheudle job
 */
global class ShareMDFToPartnerSchedule implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        String soql = 'select Id, Account__c, OwnerId from MDF_Request__c where Account__c != null';
        ShareMDFToPartnerBatch currentBatchJob = new ShareMDFToPartnerBatch(soql);
        Database.executeBatch(currentBatchJob, 10);
    }
}