/*
 * This class is used to check whether contains deferral leads those aren't be deal with.
 */
global class DeferralLeadSchedule implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        DeferralLeadBatchJob batch = new DeferralLeadBatchJob();
        Database.executeBatch(batch, 1); 
    }
    
    @isTest
    static void testDeferralLeadSchedule()
    {
        Test.StartTest();
        DeferralLeadSchedule schedule = new DeferralLeadSchedule();
        schedule.execute(null);
        Test.StopTest();
    }
}