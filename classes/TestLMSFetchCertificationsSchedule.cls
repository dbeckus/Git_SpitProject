@IsTest
public class TestLMSFetchCertificationsSchedule {
@isTest
    static void testLMSFetchCertificationsSchedule()
    {
        Test.StartTest();
        String jobId = System.schedule('testBasicScheduledApex','0 0 1 * * ?', new LMSFetchCertificationsSchedule());
        Test.StopTest();
    }
}