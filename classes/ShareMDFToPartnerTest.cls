@isTest
public class ShareMDFToPartnerTest
{
    /*
    @isTest
    static void testMDFShare()
    {
        User portalUser = [select COntactId, COntact.AccountId from User where IsActive = true and UserType = 'PowerPartner' limit 1];
        MDF_Request__c mdf = new MDF_Request__c(Account__c = portalUser.Contact.AccountId);
        MDF_Request__c mdf2 = new MDF_Request__c(Account__c = portalUser.Contact.AccountId);
        insert new List<MDF_Request__c> {mdf, mdf2};
        mdf.Account__c = null;
        update mdf;
        ShareMDFToPartnerHelper.shareMDFs(new List<MDF_Request__c> {mdf, mdf2});
    }
    
    @isTest
    static void testMDFShareSchedule()
    {
        Test.startTest();
        ShareMDFToPartnerSchedule schedulable = new ShareMDFToPartnerSchedule();
        SchedulableContext ctx;
        schedulable.execute(ctx);
        Test.stopTest();
    }
    
    @isTest
    static void testMDFShareBatch()
    {
        Test.startTest();
        String soql = 'select Id, Account__c, OwnerId from MDF_Request__c where Account__c != null limit 1';
        ShareMDFToPartnerBatch currentBatchJob = new ShareMDFToPartnerBatch(soql);
        Database.executeBatch(currentBatchJob, 1);
        Test.stopTest();
    }
*/
}