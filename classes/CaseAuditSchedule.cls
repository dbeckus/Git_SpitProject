/*
 * This class is used to post a chatter message when the case hasn't been updated in over two weeks.
 */

global class CaseAuditSchedule implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        CaseAuditBatchJob batch = new CaseAuditBatchJob();
        Database.executeBatch(batch, 1); 
    }
    
    @isTest
    static void testCaseAuditSchedule()
    {
        Test.StartTest();
        String jobId = System.schedule('testBasicScheduledApex','0 0 1 * * ?', new CaseAuditSchedule());
        Test.StopTest();
    }
}