@isTest
public class ForecastingStatsServiceTest
{
    @isTest
    static void testGetReport()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
      //  insert usr;
       System.runAs(usr)
        {
        ForecastingController fc = new ForecastingController();
        ForecastingStatsService controller = new ForecastingStatsService(fc);
        ForecastingDealFlowController fdfc = new ForecastingDealFlowController(fc);
        ForecastingStatsService controller2 = new ForecastingStatsService(fdfc);
        Opportunity opp1 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Discovery', Type='Follow on Business', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp2 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='Follow on Business', Product_Forecast_Categories__c='Virtual', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp3 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='Follow on Business', Product_Forecast_Categories__c='Physical', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp4 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Discovery', Type='New Business', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp5 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='New Business', Product_Forecast_Categories__c='Virtual', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp6 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='New Business', Product_Forecast_Categories__c='Physical', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp7 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Discovery', Type='Support Renewal', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp8 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='Support Renewal', Product_Forecast_Categories__c='Virtual', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        Opportunity opp9 = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 5, 1), StageName='Closed Won', Type='Support Renewal', Product_Forecast_Categories__c='Physical', POC_Type__c='POC', Win_Description__c='acme', Finance_Reviewed__c=true,Deal_Type__c='Replication',Solution_Type__c='Hybrid WAN');
        insert new List<Opportunity> { opp1, opp2, opp3, opp4, opp5, opp6, opp7, opp8, opp9 };
         }
        ForecastingStatsService.getReport('2014Q4', UserInfo.getUserId());
            
    }
    
    @isTest
    static void testDellReport()
    {
        ForecastingStatsService.getDellReport('2014Q4', UserInfo.getUserId());
    }
    
    @isTest
    static void testDashboard()
    {
        ForecastingStatsService.getAttainmentDashboard(UserInfo.getUserId());
        ForecastingStatsService.getUntouchedQualifiedLeadCount(UserInfo.getUserId());
        ForecastingStatsService.getInProgressQualifiedLeadCount(UserInfo.getUserId());
        ForecastingStatsService.getOverdueLeadCount(UserInfo.getUserId());
        ForecastingStatsService.getNewOppCount('2014Q4', UserInfo.getUserId());
        ForecastingStatsService.getAveDealSize('2014Q4', UserInfo.getUserId());
        ForecastingStatsService.getDealsOver100K('2014Q4', UserInfo.getUserId());
        ForecastingStatsService.getDeadOppCount('2014Q4', UserInfo.getUserId());
        ForecastingStatsService.getTotalPipeline('2014Q4', UserInfo.getUserId());
    }
    
    @isTest
    static void testChartData()
    {
        PageReference ref = new PageReference('/forecasting?quater=2014Q4');
        Test.setCurrentPage(ref);
        ForecastingController fc = new ForecastingController();
        ForecastingStatsService controller = new ForecastingStatsService(fc);
        
        List<Forecasting_History__c> fh1 = controller.getForecastAccuracy;
        List<Forecasting_History__c> fh2 = controller.getPipelineTrend;
        List<Forecasting_History__c> fh3 = controller.getPerformanceAgainst;
        List<ForecastingStatsService.OpportunityChartData> fh4 = controller.getOfOpportunities;
    }
    
    /*@isTest
    static void testForecastingController()
    {
        PageReference page = new PageReference('/apex/Forecasting?id=' + UserInfo.getUserId() + '&quater=2011Q1');
        Test.setCurrentPage(page);
        ForecastingStatsService controller = new ForecastingStatsService();
        
        controller.InitFiscalQuarter();
        ForecastingStatsService.ForecastReport p = new ForecastingStatsService.ForecastReport();
        Forecasting_History__c ff = new Forecasting_History__c( OppAmount__c = Decimal.valueOf(123123), OppCount__c = Integer.valueOf(12), OppExpAmount__c = Decimal.valueOf(12312), Type__c = 'New-Commit', User__c = UserInfo.getUserId(), Period__c = '2011Q1', ForecastSubmit__c = true);
        insert ff;
        ForecastingStatsService.MyObject mo = new ForecastingStatsService.MyObject(2.0,3.0,4.0,datetime.now(),2.0);
        System.assert(controller.getForecastAccuracy != null);
        System.assert(controller.getOfOpportunities != null);
        System.assert(controller.getPerformanceAgainst != null);
        System.assert(controller.getPipelineTrend != null);
        
        ForecastingStatsService.getUntouchedQualifiedLeadCount('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getInProgressQualifiedLeadCount('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getQualifiedLeadInProgressFor14DaysCount('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getNewOppCount('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getAveDealSize('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getDealsOver100K('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getDeadOppCount('2011Q1', UserInfo.getUserId());
        ForecastingStatsService.getTotalPipeline('2011Q1', UserInfo.getUserId());
        
        System.assert(p!= null);
        ForecastingStatsService.ForecastReport result = ForecastingStatsService.getReport('2011Q1', UserInfo.getUserId(), new List<String> {UserInfo.getUserId()});
        List<String> resultForDeal = ForecastingStatsService.getDealFlowReport(UserInfo.getUserId());
        System.assert(result != null); 
        System.assert(resultForDeal != null);
        ForecastingStatsService.insertSubmitForecast(result);
        ForecastingStatsService.ForecastReport fd= ForecastingStatsService.getReport('2011Q1', UserInfo.getUserId(), new List<String> {UserInfo.getUserId()});
        System.assert(fd != null);
    }*/
}