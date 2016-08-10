@isTest
public class ForecastingOppListServiceTest
{
    @isTest
    static void testCloseWon()
    {
        ForecastingController fc = new ForecastingController();
        ForecastingOppListService controller = new ForecastingOppListService(fc);
        
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'Closed Won';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testAllOpen()
    {
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery');
        insert opp;
        
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'All Open';
        request.isOver100K = false;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testMR()
    {
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'Maintenance Renewal';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testNewFollowOn()
    {
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'New & Follow On';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testNewFollowOnPhysical()
    {
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'New & FO Physical';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testNewFollowOnVirtual()
    {
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'New & FO Virtual';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
    
    @isTest
    static void testDell()
    {
        Account acc = new Account(Name='Dell');
        insert acc;
        
        ForecastingOppListService.ForecastingOppListRequest request = new ForecastingOppListService.ForecastingOppListRequest();
        request.userId = UserInfo.getUserId();
        request.fiscalQtr = '2014Q4';
        request.typeOption = 'Dell';
        request.isOver100K = true;
        request.sortField = 'Name';
        request.pageIndex = 1;
        ForecastingOppListService.getOpportunities(request);
    }
}