@isTest
public class SpireAnalyticsBatchTest
{
    @isTest
    static void testBatch1() 
    {
        new SpireAnalyticsSubscriptionBatch().run();   
    }
    
    @isTest
    static void testBatch2()
    {
        new SpireAnalyticsMaintenanceBatch1().run();
    }
    
    @isTest
    static void testBatch3()
    {
        new SpireAnalyticsMaintenanceBatch2().run();
    }
    
    @isTest
    static void testBatch4()
    {
        new SpireAnalyticsLeadTransitionBatch().run(); 
    }
}