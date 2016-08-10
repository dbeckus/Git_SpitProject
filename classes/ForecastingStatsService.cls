/*
 *  webservice for page Forecasting 
 */
global without sharing class ForecastingStatsService
{
    public String currentUserID;
    public String currentUserQuarter; 
    public ForecastingStatsService(ForecastingController controller) {} 
    public ForecastingStatsService(ForecastingDealFlowController controller) {} 
    
    @RemoteAction @ReadOnly
    public static ForecastReport getReport(String fiscalQuarter, String currentUserId)
    {
        User user ;
        List<User> users= [select Id, Name, UserRoleId, AnnualTarget__c from User where Id =:currentUserId];
        if(users.size() > 0)
        {
            user = users[0];
        }
        else
        {
            return null;
        }
        List<String> allUsers = new List<String>();
        List<String> subUserIds = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.addAll(subUserIds);
        allUsers.add(currentUserId);
        ForecastReport fiscalQtr = new ForecastReport();    
        fiscalQtr.userId = currentUserId ;
        fiscalQtr.userName = user.Name;   
        fiscalQtr.fiscalName = fiscalQuarter; 
        fiscalQtr.annualTarget = (user.AnnualTarget__c == null) ? 0 : user.AnnualTarget__c;
        fillForecastNumbers(fiscalQuarter, currentUserId, subUserIds, fiscalQtr);
        Date startDate = parseStartDate(fiscalQuarter);
        Date endDate = parseEndDate(fiscalQuarter);
        List<Opportunity> oppList = [select Id, CloseDate, IsWon, IsClosed, BookingType__c, StageName, ForecastCategoryName, Product_Forecast_Categories__c, ExpectedRevenue, Amount, Virtual_Amount__c, Physical_Amount__c, Undefined_Amount__c, Split_Adjustment__c from Opportunity where OwnerId in :allUsers and CloseDate <=: endDate AND CloseDate >=:startDate and (StageName in ('Closed Won', 'Closed Lost', 'Closed Dead') or ForecastCategoryName in ('Commit', 'Best Case', 'Pipeline'))]; 
        fillSummaryNumbers(oppList, fiscalQtr);
        return fiscalQtr;
    }
    
    @RemoteAction @Readonly
    public static ForecastReport getDellReport(String fiscalQuarter, String currentUserId)
    {
        if(String.isBlank(currentUserId))
        {
            return null;
        }
        List<Id> allUsers = new List<Id>();
        allUsers.addAll(ForecastingController.getAllSubordinateUsers(currentUserId));
        allUsers.add(currentUserId);
        ForecastReport fiscalQtr = new ForecastReport();
        Date startDate = parseStartDate(fiscalQuarter);
        Date endDate = parseEndDate(fiscalQuarter);
        List<Opportunity> oppNewList = [Select Id, CloseDate, IsWon, IsClosed, BookingType__c, StageName, ForecastCategoryName, Product_Forecast_Categories__c, ExpectedRevenue, Amount, Virtual_Amount__c, Physical_Amount__c, Undefined_Amount__c, Split_Adjustment__c From Opportunity Where Id in (select OpportunityId from Partner where AccountTo.Name like '%Dell%') and Account.Is_Dell_Client__c=false and OwnerId in :allUsers and CloseDate <=: endDate AND CloseDate >=:startDate and ((IsClosed = true and IsWon = true) OR (IsClosed = false AND ForecastCategoryName <> 'Omitted'))]; 
        fillSummaryNumbers(oppNewList, fiscalQtr);
        return fiscalQtr;
    }
    
    webservice static String[] getDealFlowReport(String userId)
    {
        User user ;
        List<User> users= [select Id, Name, UserRoleId, GEO_Region__c from User where Id =: userId];
        if(users.size()>0)
        {
            user = users[0];
        }
        else
        {
            return null;
        }
        
        String[] reportInfo;
        List<String> reportInfoList = new List<String>();
        reportInfoList.add(user.Id);
        reportInfoList.add(user.GEO_Region__c);
        reportInfoList.add(user.Name);
        reportInfoList.addAll(getNewAndFollowAllOpps(user.Id));
        reportInfoList.addAll(getNewAndFollowClosedOpps(user.Id));
        reportInfoList.addAll(getAllOpenOpps(user.Id));
        reportInfoList.add(String.valueOf(ForecastingController.getDirectSubordinateUsers(UserId).size())); 
        reportInfo = reportInfoList;
        return reportInfo;
    }
    
    /*submites forecast snapshot, creates history items for the two tables on the forecasting page, the parameters are the return value of method getReport*/
    webservice static Boolean insertSubmitForecast(ForecastReport report)
    {
         List<Forecasting_History__c> forecastHistoryList = new List<Forecasting_History__c>();
         String userId = report.userId;
         String period = report.fiscalName;
         /* Add a line to show in the history log that shows the user submitted their forecast */
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = 0, Type__c = 'New-Forecast', User__c = userId, Period__c = period, ForecastSubmit__c = false, Comments__c = 'Forecast Submitted'));
         
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.quotaNewAmount, Type__c = 'New-Quota', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.quotaFollowOnAmount, Type__c = 'FollowOn-Quota', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.quotaMRAmount, Type__c = 'MR-Quota', User__c = userId, Period__c = period, ForecastSubmit__c = true));     
         
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.commitmentNewAmount, Type__c = 'New-Commitment', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.commitmentFollowOnAmount, Type__c = 'FollowOn-Commitment', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.commitmentMRAmount, Type__c = 'MR-Commitment', User__c = userId, Period__c = period, ForecastSubmit__c = true));     
         
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.forecastNewAmount, Type__c = 'New-Forecast', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.forecastFollowOnAmount, Type__c = 'FollowOn-Forecast', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         //forecastHistoryList.add(new Forecasting_History__c( Value__c = report.forecastMRAmount, Type__c = 'MR-Forecast', User__c = userId, Period__c = period, ForecastSubmit__c = true));     
         forecastHistoryList.add(new Forecasting_History__c( Value__c = report.forecastNewFollowOnAmount, Type__c = 'NewFollowOn-Forecast', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonNewAmount, OppCount__c = report.totalWonNewCount, OppExpAmount__c = report.totalWonNewExpAmount, Type__c = 'New-Won', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonMRAmount, OppCount__c = report.totalWonMRCount, OppExpAmount__c = report.totalWonMRExpAmount, Type__c = 'MR-Won', User__c = userId, Period__c = period, ForecastSubmit__c = true));     
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonAmount, OppCount__c = report.totalWonNewCount + report.totalWonMRCount, OppExpAmount__c = report.totalWonExpAmount, Type__c = 'Total-Won', User__c = userId, Period__c = period, ForecastSubmit__c = true));
            
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastNewAmount, OppCount__c = report.totalWonForecastNewCount, OppExpAmount__c = report.totalWonForecastNewExpAmount, Type__c = 'New-Commit', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastMRAmount, OppCount__c = report.totalWonForecastMRCount, OppExpAmount__c = report.totalWonForecastMRExpAmount, Type__c = 'MR-Commit', User__c = userId, Period__c =period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastAmount, OppCount__c= report.totalWonForecastNewCount + report.totalWonForecastMRCount, OppExpAmount__c = report.totalWonForecastExpAmount, Type__c = 'Total-Commit', User__c = userId, Period__c = period, ForecastSubmit__c = true));
            
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastBestNewAmount, OppCount__c = report.totalWonForecastBestNewCount, OppExpAmount__c = report.totalWonForecastBestNewExpAmount, Type__c = 'New-Best Case', User__c =userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastBestMRAmount, OppCount__c = report.totalWonForecastBestMRCount, OppExpAmount__c = report.totalWonForecastBestNewExpAmount, Type__c = 'MR-Best Case', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalWonForecastBestAmount, OppCount__c = report.totalWonForecastBestNewCount + report.totalWonForecastBestMRCount, OppExpAmount__c = report.totalWonForecastBestExpAmount, Type__c = 'Total-Best Case', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalPipelineNewAmount, OppCount__c = report.totalPipelineNewCount, OppExpAmount__c = report.totalPipelineNewExpAmount, Type__c = 'MR-Pipeline', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalPipelineMRAmount, OppCount__c = report.totalPipelineMRCount, OppExpAmount__c = report.totalPipelineMRExpAmount, Type__c = 'New-Pipeline', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppAmount__c = report.totalPipelineAmount, OppCount__c = report.totalPipelineNewCount + report.totalPipelineMRCount, OppExpAmount__c = report.totalPipelineExpAmount, Type__c = 'Total-Pipeline', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         
         forecastHistoryList.add(new Forecasting_History__c( OppCount__c = report.NewOppCount, Type__c = 'NewOppCount', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         forecastHistoryList.add(new Forecasting_History__c( OppCount__c = report.ClosedDeadOppCOunt, Type__c = 'ClosedDeadOppCount', User__c = userId, Period__c = period, ForecastSubmit__c = true));
         
         DateTime currentDate = DateTime.now();
         DateTime firstDate = DateTime.newInstance(currentDate.year(), currentDate.month(),currentDate.day(), 0, 0, 0);
         DateTime lastDate = DateTime.newInstance(currentDate.year(), currentDate.month(),currentDate.day(), 23, 59, 59);
         
        try
        {
            //delete [select Id, Name, Value__c, User__c, Type__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, ForecastSubmit__c, CreatedDate, Comments__c from Forecasting_History__c where Date__c >= :firstDate and Date__c <= :lastDate and User__c =:userId order by Date__c];
            insert forecastHistoryList;
            return true;
        }
        catch (Exception e)  
        {
            ApexPages.addMessages(e);
            return false;
        } 
    }
    
    @RemoteAction @Readonly
    public static AttainmentDashboard getAttainmentDashboard(String userId)
    {
        AttainmentDashboard result = new AttainmentDashboard();
        List<User> users = [select Id, AnnualTarget__c from User where Id=:userId limit 1];
        if(users.size() > 0)
        {
            result.annualTarget = users[0].AnnualTarget__c;
            Date startDate = ForecastingController.getStartOfCurrentFiscalYear();
            result.daysPassed = startDate.daysBetween(Date.today()) + 1;
            List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
            allUsers.add(userId);
            List<AggregateResult> aggregate = [select sum(Amount) a from Opportunity where IsWon=true and IsClosed=true and OwnerId in :allUsers and CloseDate>=:startDate and Split_Adjustment__c=false and BookingType__c in ('New', 'Follow On')];
            result.amountClosedYtd  = (Decimal)aggregate[0].get('a');
            result.amountClosedYtd = (result.amountClosedYtd == null) ? 0 : result.amountClosedYtd;
            if(result.annualTarget != null && result.annualTarget != 0)
            {
                result.currentAttainment = result.amountClosedYtd / (result.daysPassed) / (result.annualTarget / 365);
                result.ytdAttainment = result.amountClosedYtd / result.annualTarget;
            }
        }
        
        return result;
    }
    
    @RemoteAction @Readonly
    public static Integer getActiveLeadsCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where Status not in :PatchAssignmentsController.marketingStatuses and (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers)];
    }
    
    @RemoteAction @Readonly
    public static Integer getQualifiedLeadsCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where Status in :PatchAssignmentsController.qualifiedStatuses and (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers)];
    }
    
    @RemoteAction @Readonly
    public static Integer getUntouchedQualifiedLeadCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers) and Screening_Results__c in :PatchAssignmentsController.untouchedStatuses and Status in :PatchAssignmentsController.untouchedStatuses];
    }
    
    @RemoteAction @Readonly
    public static Integer getInProgressQualifiedLeadCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers) and Screening_Results__c in :PatchAssignmentsController.untouchedStatuses and Status in :PatchAssignmentsController.inProgressStatuses];
    }
    
    @RemoteAction @Readonly
    public static Integer getOverdueLeadCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers) and Screening_Results__c='ISR Qualified' and Status in :PatchAssignmentsController.overdueStatuses and DaysSinceLastStatusUpdate__c>=14];
    }
    
    @RemoteAction @Readonly
    public static Integer getDeferredLeadsCount(String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        return [select count() from Lead where Status in :PatchAssignmentsController.deferredStatuses and (CSM__c in :allUsers or ISR__c in :allUsers or RSM__c in :allUsers or SE__c in :allUsers)];
    }
    
    @RemoteAction @Readonly
    public static Integer getNewOppCount(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        return [Select count() From Opportunity Where OwnerId IN :allUsers and CreatedDate>=:startDate and CreatedDate<=:endDate and ((IsClosed = true and IsWon = true) OR (IsClosed = false AND ForecastCategoryName <> 'Omitted')) and BookingType__c in ('New', 'Follow On') and Split_Adjustment__c=false];
    }
    
    @RemoteAction @Readonly
    public static Double getAveDealSize(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        LIST<AggregateResult> result = [select avg(Amount) avg from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate AND ((IsClosed = true and IsWon = true) OR (IsClosed = false AND ForecastCategoryName <> 'Omitted')) and BookingType__c in ('New', 'Follow On')];
        return (Double)result[0].get('avg');
    }
    
    @RemoteAction @Readonly
    public static Double getMedianDealSize(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<Opportunity> opps = [select Id, Amount from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate AND ((IsClosed = true and IsWon = true) OR (IsClosed = false AND ForecastCategoryName <> 'Omitted')) and BookingType__c in ('New', 'Follow On') order by Amount];
        Double median = 0;
        if(opps.size() == 1)
        {
            median = opps[0].Amount;
        }
        else if(opps.size() > 1)
        {
            if(Math.mod(opps.size(), 2) == 0)
            {
                Opportunity opp1 = opps[opps.size() / 2 - 1];
                Opportunity opp2 = opps[opps.size() / 2];
                median = (opp1.Amount + opp2.Amount) / 2;
            }
            else
            {
                median = opps[(opps.size() - 1) / 2].Amount;
            }
        }
        return median;
    }
    
    @RemoteAction @Readonly
    public static Integer getDealsOver100K(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        return [select count() from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate AND ((IsClosed = true and IsWon = true) OR (IsClosed = false AND ForecastCategoryName <> 'Omitted')) and Amount>=100000 and Type != 'Marketplace' and Split_Adjustment__c=false];
    }
    
    @RemoteAction @Readonly
    public static Integer getDeadOppCount(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        return [select count() from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate and StageName='Closed Dead' and Type != 'Marketplace' and Split_Adjustment__c=false];
    }
    
    @RemoteAction @Readonly
    public static Decimal getTotalPipeline(String fiscalQuarter, String currentUserId)
    {
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(currentUserId);
        allUsers.add(currentUserId);
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<AggregateResult> results = [select sum(Amount) s from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate and BookingType__c in ('New', 'Follow On', 'Maintenance Renewal') and ((IsClosed = true and IsWon = true) OR ForecastCategoryName in ('Forecast', 'Commit', 'Best Case', 'Pipeline'))];
        return (Decimal)results[0].get('s');
    }
    
    private static void fillForecastNumbers(String fiscalQuarter, String currentUserId, List<String> subUserIds, ForecastReport fiscalQtr)
    {
        List<SPForecasting__c> spForecastingList = [select User__c, Type__c, OwnerId, Name, MRAmount__c, Id, Fiscal_Period__c, CreatedDate, Amount__c, NewVirtualAmount__c, NewAmount__c, FollowOnAmount__c From SPForecasting__c where User__c =:currentUserId and Fiscal_Period__c = :fiscalQuarter order by CreatedDate];
        for(SPForecasting__c spf : spForecastingList)
        {
            if(spf.Type__c == 'Quota')
            {
              fiscalQtr.quotaNewPhysicalAmount = spf.Amount__c;
              fiscalQtr.quotaNewAmount = (spf.NewAmount__c == null) ? 0 : spf.NewAmount__c;
              fiscalQtr.quotaNewVirtualAmount = spf.NewVirtualAmount__c;
              fiscalQtr.quotaFollowOnAmount = (spf.FollowOnAmount__c == null) ? 0 : spf.FollowOnAmount__c;
              fiscalQtr.quotaNewVirtualAmount = (fiscalQtr.quotaNewVirtualAmount == null) ? 0 : fiscalQtr.quotaNewVirtualAmount;
              fiscalQtr.quotaMRAmount = spf.MRAmount__c;
            }
            if(spf.Type__c == 'Commitment')
            {
              fiscalQtr.commitmentNewPhysicalAmount = spf.Amount__c;
              fiscalQtr.commitmentNewAmount = (spf.NewAmount__c == null) ? 0 : spf.NewAmount__c;
              fiscalQtr.commitmentNewVirtualAmount = spf.NewVirtualAmount__c;
              fiscalQtr.commitmentFollowOnAmount = (spf.FollowOnAmount__c == null) ? 0 : spf.FollowOnAmount__c;
              fiscalQtr.commitmentNewVirtualAmount = (fiscalQtr.commitmentNewVirtualAmount == null) ? 0 : fiscalQtr.commitmentNewVirtualAmount;
              fiscalQtr.commitmentMRAmount = spf.MRAmount__c;
            }
            if(spf.Type__c == 'Forecast')
            {
              fiscalQtr.forecastNewPhysicalAmount = (spf.Amount__c == null) ? 0 : spf.Amount__c;
              fiscalQtr.forecastNewVirtualAmount = (spf.NewVirtualAmount__c == null) ? 0 : spf.NewVirtualAmount__c;
              fiscalQtr.forecastNewAmount = (spf.NewAmount__c == null) ? 0 : spf.NewAmount__c;
              fiscalQtr.forecastFollowOnAmount = (spf.FollowOnAmount__c == null) ? 0 : spf.FollowOnAmount__c;
              fiscalQtr.forecastMRAmount = spf.MRAmount__c;
              //use different fields in different quarter
              if(fiscalQuarter < '2014Q4')
              {
                  fiscalQtr.forecastNewFollowOnAmount = fiscalQtr.forecastNewPhysicalAmount + fiscalQtr.forecastNewVirtualAmount;
              }
              else if(fiscalQuarter < '2015Q1')
              {
                  fiscalQtr.forecastNewFollowOnAmount = fiscalQtr.forecastNewAmount + fiscalQtr.forecastFollowOnAmount;
              }
              else
              {
                  fiscalQtr.forecastNewFollowOnAmount = (spf.Amount__c == null) ? 0 : spf.Amount__c;
              }
            }
        }
        List<Forecasting_History__c> forecastNewUpdates = [select Id, CreatedDate from Forecasting_History__c where User__c=:currentUserId and Type__c='New-Forecast' and ForecastSubmit__c=false and Period__c=:fiscalQuarter order by CreatedDate desc limit 1];
        fiscalQtr.forecastNewLastUpdateDate = forecastNewUpdates.size() == 0 ? '' : formatDate(forecastNewUpdates[0].CreatedDate);
        List<Forecasting_History__c> forecastFollowOnUpdates = [select Id, CreatedDate from Forecasting_History__c where User__c=:currentUserId and Type__c='FollowOn-Forecast' and ForecastSubmit__c=false and Period__c=:fiscalQuarter order by CreatedDate desc limit 1];
        fiscalQtr.forecastFollowOnLastUpdateDate = forecastFollowOnUpdates.size() == 0 ? '' : formatDate(forecastFollowOnUpdates[0].CreatedDate);
        List<Forecasting_History__c> forecastNewFollowOnUpdates = [select Id, CreatedDate from Forecasting_History__c where User__c=:currentUserId and Type__c in ('NewFollowOn-Forecast', 'New-Forecast', 'FollowOn-Forecast', 'New-Physical-Forecast', 'New-Virtual-Forecast') and ForecastSubmit__c=false and Period__c=:fiscalQuarter and Comments__c!='Forecast Submitted' order by CreatedDate desc limit 1];
        fiscalQtr.forecastNewFollowOnLastUpdateDate = forecastNewFollowOnUpdates.size() == 0 ? '' : formatDate(forecastNewFollowOnUpdates[0].CreatedDate);
        List<Forecasting_History__c> forecastMRUpdates = [select Id, CreatedDate from Forecasting_History__c where User__c=:currentUserId and Type__c='MR-Forecast' and ForecastSubmit__c=false and Period__c=:fiscalQuarter order by CreatedDate desc limit 1];
        fiscalQtr.forecastMRLastUpdateDate = forecastMRUpdates.size() == 0 ? '' : formatDate(forecastMRUpdates[0].CreatedDate);
    }
    private static void fillSummaryNumbers(Opportunity[] opportunities, ForecastReport fiscalQtr)
    {
        for(Opportunity opp : opportunities)
        {
            if(opp.Amount == null)
            {
                opp.Amount = 0;
            }
            Decimal expRevenue = (opp.ExpectedRevenue != null) ? opp.ExpectedRevenue : 0;
            Decimal physicalExpRevenue = (opp.Amount == 0) ? 0 : opp.Physical_Amount__c * expRevenue / opp.Amount;
            Decimal virtualExpRevenue = (opp.Amount == 0) ? 0 : opp.Virtual_Amount__c * expRevenue / opp.Amount;
            Decimal undefinedAmount = (opp.Product_Forecast_Categories__c == null) ? opp.Amount : opp.Undefined_Amount__c;
            Decimal undefinedExpRevenue = (opp.Amount == 0) ? 0 : undefinedAmount * expRevenue / opp.Amount;
            Integer oppCount = (opp.Split_Adjustment__c != true) ? 1 : 0;
            if(opp.BookingType__c == 'New')
            {
                if(opp.ForecastCategoryName == 'Pipeline' || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast' || opp.ForecastCategoryName == 'Best Case')
                {
                    fiscalQtr.undefinedNewAmount += undefinedAmount;
                    fiscalQtr.undefinedNewExpAmount += undefinedExpRevenue;
                    fiscalQtr.undefinedTotalAmount += undefinedAmount;
                    fiscalQtr.undefinedTotalExpAmount += undefinedExpRevenue;
                    if(opp.Product_Forecast_Categories__c == null || opp.Undefined_Amount__c > 0)
                    {
                        fiscalQtr.undefinedNewCount += oppCount;
                        fiscalQtr.undefinedTotalCount += oppCount;
                    }
                }
                if(opp.IsWon)
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonNewAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonNewExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonNewCount += oppCount;
                        fiscalQtr.physicalWonTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonNewAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonNewExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonNewCount += oppCount;
                        fiscalQtr.virtualWonTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonNewAmount += opp.Amount;
                    fiscalQtr.totalWonNewExpAmount += expRevenue;
                    fiscalQtr.totalWonNewCount += oppCount;
                    fiscalQtr.totalWonAmount += opp.Amount;
                    fiscalQtr.totalWonExpAmount += expRevenue;
                    fiscalQtr.totalWonCount += oppCount;
                }  
                if(opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastNewAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastNewExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastNewCount += oppCount;
                        fiscalQtr.physicalWonForecastTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastNewAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastNewExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastNewCount += oppCount;
                        fiscalQtr.virtualWonForecastTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastNewAmount += opp.Amount;
                    fiscalQtr.totalWonForecastNewExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastNewCount += oppCount;
                    fiscalQtr.totalWonForecastAmount += opp.Amount;
                    fiscalQtr.totalWonForecastExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastCount += oppCount;
                }
                if(opp.ForecastCategoryName == 'Best Case' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastBestNewAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestNewExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestNewCount += oppCount;
                        fiscalQtr.physicalWonForecastBestTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastBestNewAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestNewExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestNewCount += oppCount;
                        fiscalQtr.virtualWonForecastBestTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastBestNewAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestNewExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestNewCount += oppCount;
                    fiscalQtr.totalWonForecastBestAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestCount += oppCount;
                }
                
                if(opp.ForecastCategoryName == 'Pipeline' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast' || opp.ForecastCategoryName == 'Best Case')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalPipelineNewAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineNewExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineNewCount += oppCount;
                        fiscalQtr.physicalPipelineTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualPipelineNewAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineNewExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineNewCount += oppCount;
                        fiscalQtr.virtualPipelineTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineTotalCount += oppCount;
                    }
                    fiscalQtr.totalPipelineNewAmount += opp.Amount;
                    fiscalQtr.totalPipelineNewExpAmount += expRevenue;
                    fiscalQtr.totalPipelineNewCount += oppCount;
                    fiscalQtr.totalPipelineAmount += opp.Amount;
                    fiscalQtr.totalPipelineExpAmount += expRevenue;
                    fiscalQtr.totalPipelineCount += oppCount;
                }
            }
            else if(opp.BookingType__c == 'Follow On')
            {
                if(opp.ForecastCategoryName == 'Pipeline' || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast' || opp.ForecastCategoryName == 'Best Case')
                {
                    fiscalQtr.undefinedFollowOnAmount += undefinedAmount;
                    fiscalQtr.undefinedFollowOnExpAmount += undefinedExpRevenue;
                    fiscalQtr.undefinedTotalAmount += undefinedAmount;
                    fiscalQtr.undefinedTotalExpAmount += undefinedExpRevenue;
                    if(opp.Product_Forecast_Categories__c == null || opp.Undefined_Amount__c > 0)
                    {
                        fiscalQtr.undefinedFollowOnCount += oppCount;
                        fiscalQtr.undefinedTotalCount += oppCount;
                    }
                }
                if(opp.IsWon)
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonFollowOnAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonFollowOnExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonFollowOnCount += oppCount;
                        fiscalQtr.physicalWonTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonFollowOnAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonFollowOnExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonFollowOnCount += oppCount;
                        fiscalQtr.virtualWonTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonFollowOnAmount += opp.Amount;
                    fiscalQtr.totalWonFollowOnExpAmount += expRevenue;
                    fiscalQtr.totalWonFollowOnCount += oppCount;
                    fiscalQtr.totalWonAmount += opp.Amount;
                    fiscalQtr.totalWonExpAmount += expRevenue;
                    fiscalQtr.totalWonCount += oppCount;
                }  
                if(opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastFollowOnAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastFollowOnExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastFollowOnCount += oppCount;
                        fiscalQtr.physicalWonForecastTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastFollowOnAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastFollowOnExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastFollowOnCount += oppCount;
                        fiscalQtr.virtualWonForecastTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastFollowOnAmount += opp.Amount;
                    fiscalQtr.totalWonForecastFollowOnExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastFollowOnCount += oppCount;
                    fiscalQtr.totalWonForecastAmount += opp.Amount;
                    fiscalQtr.totalWonForecastExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastCount += oppCount;
                }
                if(opp.ForecastCategoryName == 'Best Case' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastBestFollowOnAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestFollowOnExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestFollowOnCount += oppCount;
                        fiscalQtr.physicalWonForecastBestTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastBestFollowOnAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestFollowOnExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestFollowOnCount += oppCount;
                        fiscalQtr.virtualWonForecastBestTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastBestFollowOnAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestFollowOnExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestFollowOnCount += oppCount;
                    fiscalQtr.totalWonForecastBestAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestCount += oppCount;
                }
                
                if(opp.ForecastCategoryName == 'Pipeline' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast' || opp.ForecastCategoryName == 'Best Case')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalPipelineFollowOnAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineFollowOnExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineFollowOnCount += oppCount;
                        fiscalQtr.physicalPipelineTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualPipelineFollowOnAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineFollowOnExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineFollowOnCount += oppCount;
                        fiscalQtr.virtualPipelineTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineTotalCount += oppCount;
                    }
                    fiscalQtr.totalPipelineFollowOnAmount += opp.Amount;
                    fiscalQtr.totalPipelineFollowOnExpAmount += expRevenue;
                    fiscalQtr.totalPipelineFollowOnCount += oppCount;
                    fiscalQtr.totalPipelineAmount += opp.Amount;
                    fiscalQtr.totalPipelineExpAmount += expRevenue;
                    fiscalQtr.totalPipelineCount += oppCount;
                }
            }
            else if(opp.BookingType__c =='Maintenance Renewal')
            {
                if(opp.ForecastCategoryName == 'Pipeline' || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast' || opp.ForecastCategoryName == 'Best Case')
                {
                    fiscalQtr.undefinedMRAmount += undefinedAmount;
                    fiscalQtr.undefinedMRExpAmount += undefinedExpRevenue;
                    fiscalQtr.undefinedTotalAmount += undefinedAmount;
                    fiscalQtr.undefinedTotalExpAmount += undefinedExpRevenue;
                    if(opp.Product_Forecast_Categories__c == null || opp.Undefined_Amount__c > 0)
                    {
                        fiscalQtr.undefinedMRCount += oppCount;
                        fiscalQtr.undefinedTotalCount += oppCount;
                    }
                }
                if(opp.IsWon)
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonMRAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonMRExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonMRCount += oppCount;
                        fiscalQtr.physicalWonTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonMRAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonMRExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonMRCount += oppCount;
                        fiscalQtr.virtualWonTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonMRAmount += opp.Amount;
                    fiscalQtr.totalWonMRExpAmount += expRevenue;
                    fiscalQtr.totalWonMRCount += oppCount;
                    fiscalQtr.totalWonAmount += opp.Amount;
                    fiscalQtr.totalWonExpAmount += expRevenue;
                    fiscalQtr.totalWonCount += oppCount;
                }
                if(opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {       
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastMRAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastMRExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastMRCount += oppCount;
                        fiscalQtr.physicalWonForecastTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastMRAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastMRExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastMRCount += oppCount;
                        fiscalQtr.virtualWonForecastTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastMRAmount += opp.Amount;
                    fiscalQtr.totalWonForecastMRExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastMRCount += oppCount;
                    fiscalQtr.totalWonForecastAmount += opp.Amount;
                    fiscalQtr.totalWonForecastExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastCount += oppCount;
                }
                if(opp.ForecastCategoryName == 'Best Case' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalWonForecastBestMRAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestMRExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestMRCount += oppCount;
                        fiscalQtr.physicalWonForecastBestTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalWonForecastBestTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalWonForecastBestTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualWonForecastBestMRAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestMRExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestMRCount += oppCount;
                        fiscalQtr.virtualWonForecastBestTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualWonForecastBestTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualWonForecastBestTotalCount += oppCount;
                    }
                    fiscalQtr.totalWonForecastBestMRAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestMRExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestMRCount += oppCount;
                    fiscalQtr.totalWonForecastBestAmount += opp.Amount;
                    fiscalQtr.totalWonForecastBestExpAmount += expRevenue;
                    fiscalQtr.totalWonForecastBestCount += oppCount;
                }
                                   
                if(opp.ForecastCategoryName == 'Pipeline' || opp.ForecastCategoryName == 'Best Case' || opp.IsWon || opp.ForecastCategoryName == 'Commit' || opp.ForecastCategoryName == 'Forecast')
                {
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Physical'))
                    {
                        fiscalQtr.physicalPipelineMRAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineMRExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineMRCount += oppCount;
                        fiscalQtr.physicalPipelineTotalAmount += opp.Physical_Amount__c;
                        fiscalQtr.physicalPipelineTotalExpAmount += physicalExpRevenue;
                        fiscalQtr.physicalPipelineTotalCount += oppCount;
                    }
                    if(opp.Product_Forecast_Categories__c != null && opp.Product_Forecast_Categories__c.contains('Virtual'))
                    {
                        fiscalQtr.virtualPipelineMRAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineMRExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineMRCount += oppCount;
                        fiscalQtr.virtualPipelineTotalAmount += opp.Virtual_Amount__c;
                        fiscalQtr.virtualPipelineTotalExpAmount += virtualExpRevenue;
                        fiscalQtr.virtualPipelineTotalCount += oppCount;
                    }
                    fiscalQtr.totalPipelineMRAmount += opp.Amount;
                    fiscalQtr.totalPipelineMRExpAmount += expRevenue;
                    fiscalQtr.totalPipelineMRCount += oppCount;
                    fiscalQtr.totalPipelineAmount += opp.Amount;
                    fiscalQtr.totalPipelineExpAmount += expRevenue;
                    fiscalQtr.totalPipelineCount += oppCount;
                }
                if(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Dead')
                {
                    fiscalQtr.totalLostDeadMRAmount += opp.Amount;
                }
            }  
        }
    }
    
    /*
    * gets one month's forecast History.
    */
    public Integer ForecastAccuracyShowNumber{get; set;} 
    public List<Forecasting_History__c> getForecastAccuracy
    {
        get
        {
            InitFiscalQuarter();    
            List<Forecasting_History__c> fh = [Select Value__c, Type__c, OppExpAmount__c, Date__c, OppCount__c, OppAmount__c, Old_Value__c, Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where (Type__c IN ('New-Physical-Quota', 'New-Virtual-Quota', 'New-Quota', 'FollowOn-Quota', 'New-Physical-Commitment', 'New-Virtual-Commitment', 'New-Commitment', 'FollowOn-Commitment', 'New-Physical-Forecast', 'New-Virtual-Forecast', 'New-Forecast', 'FollowOn-Forecast', 'NewFollowOn-Forecast', 'New-Won','New-Commit')) and ForecastSubmit__c = true and Date__c >= :startTime and  Date__c <= :endTime and User__c = :currentUserID order by Date__c limit 1000]; 
            if(fh.size() > 0)
            {
                ForecastAccuracyShowNumber = Math.ceil(fh.size() * 1.0 / 5).intValue();
            }
            else
            {
                ForecastAccuracyShowNumber = 12;
                fh = new List<Forecasting_History__c>();
            }
            return fh;
        }
    }
    
    public Integer PipelineTrendShowNumber{get; set;}
    public List<Forecasting_History__c> getPipelineTrend
    {
        get
        {
            InitFiscalQuarter();    
            List<Forecasting_History__c> fh = [Select Value__c, User__c, Type__c, Date__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where (Type__c IN ('Total-Pipeline' ,'New-Best Case','New-Commit','New-Won')) and ForecastSubmit__c = true and Date__c >= :startTime and  Date__c <= :endTime and User__c = :currentUserID order by Date__c limit 1000];
            if(fh.size() > 0)
            {
                PipelineTrendShowNumber = (Integer)(fh.size()/4);
            }
            else
            {
                PipelineTrendShowNumber = 12;
                fh = new List<Forecasting_History__c>();
            }
            return fh;
        }
    }
    
    public Integer PerformanceShowNumber{get; set;}
    public List<Forecasting_History__c> getPerformanceAgainst
    {
        get
        {
            InitFiscalQuarter();    
            List<Forecasting_History__c> fh = [Select Value__c, User__c, Date__c, Type__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where (Type__c IN ('New-Commit','New-Won','New-Physical-Commitment', 'New-Virtual-Commitment', 'New-Commitment')) and ForecastSubmit__c = true and Date__c >= :startTime and  Date__c <= :endTime and User__c = :currentUserID order by Date__c limit 1000];
            if(fh.size() > 0)
            {
                PerformanceShowNumber = (Integer)(fh.size()/3);
            }
            else
            {
                PerformanceShowNumber = 12;
                fh = new List<Forecasting_History__c>();
            }
            return fh;
        }
    }
    
    public Integer OfOpportunitiesShowNumber {get; set;} 
    public List<OpportunityChartData> getOfOpportunities
    {
        get
        {       
             InitFiscalQuarter();   
             List<OpportunityChartData> fhsList = new List<OpportunityChartData>();          
             Decimal wonOpps = 0;
             Decimal totalOpps = 0;
             Decimal newOpps = 0;
             Decimal closedDeadOppCount = 0;
             Decimal count = 0; 
             DateTime myTime = null;            
             List<Forecasting_History__c> fhList = [Select Value__c, User__c, Type__c, Date__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where  (Type__c IN ('New-Won','New-Commit','New-Best Case','New-Pipeline','MR-Won','MR-Commit','MR-Best Case','MR-Pipeline')) and ForecastSubmit__c = true and User__c = :currentUserID and Date__c >= :startTime and  Date__c <= :endTime order by Date__c limit 1000];
             List<Forecasting_History__c> newOppList = [Select Value__c, User__c, Type__c, Date__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where  Type__c = 'NewOppCount' and ForecastSubmit__c = true and User__c = :currentUserID and Date__c >= :startTime and  Date__c <= :endTime order by Date__c limit 1000];
             List<Forecasting_History__c> closedDeadList = [Select Value__c, User__c, Type__c, Date__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c where  Type__c = 'ClosedDeadOppCount' and ForecastSubmit__c = true and User__c = :currentUserID and Date__c >= :startTime and  Date__c <= :endTime order by Date__c limit 1000];
             
             Map<DateTime, Decimal> newOppMap = new  Map<DateTime, Decimal>();
             if(newOppList.size() > 0)
             {
                for(Forecasting_History__c fh: newOppList)
                {
                        newOppMap.put(fh.Date__c, fh.OppCount__c);
                }
             }
             
             Map<DateTime, Decimal> closedDeadMap = new  Map<DateTime, Decimal>();
             if(closedDeadList.size() > 0)
             {
                for(Forecasting_History__c fh: closedDeadList)
                {
                        closedDeadMap.put(fh.Date__c, fh.OppCount__c);
                }
             }
             
             if(fhList.size() > 0)
             {
                OfOpportunitiesShowNumber = (Integer)(fhList.size()/8);
                for(Forecasting_History__c fh: fhList)
                { 
                    //this time is GMT time,but the page display is local time 
                    myTime = fh.Date__c;                 
                    totalOpps += fh.OppCount__c;
                    if(fh.Type__c == 'New-Won')
                    {
                        wonOpps = fh.OppCount__c;  
                    }
                    count ++;
                    if(count == 8)
                    {
                        for(DateTime dt : newOppMap.keySet())
                        {
                                if(dt.isSameDay(myTime))
                                {
                                        newOpps = newOppMap.get(dt);
                                }   
                                                        
                        }                     
                        for(DateTime dt : closedDeadMap.keySet())
                        {
                                if(dt.isSameDay(myTime))
                                {
                                        closedDeadOppCount = closedDeadMap.get(dt);
                                }   
                        }
                        OpportunityChartData fh1 = new OpportunityChartData( wonOpps,  totalOpps,  newOpps,  myTime, closedDeadOppCount);                    
                        fhsList.add(fh1);
                        wonOpps = 0;
                        newOpps = 0;
                        totalOpps = 0;                       
                        count = 0;
                    }   
                 }
             }
             else
             {
                OfOpportunitiesShowNumber = 12;
             }           
             return fhsList;
        }
    }
    
    public class OpportunityChartData
    {
        public Decimal wonOpps{get; set;}
        public Decimal totalOpps{get;set;}
        public Decimal newOpps{get;set;}
        public DateTime createDate{get;set;}
        public Decimal ClosedDeadOppCount{get; set;}
        public OpportunityChartData(Decimal wonOpps,Decimal totalOpps,Decimal newOpps,Datetime createDate,Decimal closedDeadOppCount)
        {
            this.wonOpps = wonOpps;
            this.totalOpps = totalOpps;
            this.newOpps = newOpps;
            this.createDate = createDate;
            this.ClosedDeadOppCount = closedDeadOppCount;
        }       
    }

    private static Date startTime;
    private static Date endTime;
    public void InitFiscalQuarter()
    {
        currentUserID = ApexPages.currentPage().getParameters().get('id');
        currentUserQuarter = ApexPages.currentPage().getParameters().get('quater');  
        if(currentUserID == null)
        {
                currentUserID = UserInfo.getUserId();
        }
        if(currentUserQuarter == null)
        {
            currentUserQuarter = '2015Q1';
            throw new ForecastingException('Current FiscalQuarter cannot be found.');
        }
        startTime = parseStartDate(currentUserQuarter);
        endTime = parseEndDate(currentUserQuarter);
    }
    
    private static Date parseStartDate(String fiscalQuarter)
    {
        String fiscal = fiscalQuarter.substring(0, 4);
        Integer quarter = Integer.valueOf(fiscalQuarter.substring(5, 6));

        List<Period> periods = [select Type, StartDate, Number, EndDate From Period where Type = 'Quarter' and Number =:quarter and FiscalYearSettings.Name=:fiscal limit 1];
        if(periods.size() > 0)
        {
            return periods[0].StartDate;
        }
        return Date.today();
    }
    //parses fiscal quarter string which is like '2010Q4', returns the end date of the specified fiscal quarter
    private static Date parseEndDate(String fiscalQuarter)
    {
        String fiscal = fiscalQuarter.substring(0, 4);
        Integer quarter = Integer.valueOf(fiscalQuarter.substring(5, 6));
        List<Period> periods = [select Type, StartDate, Number, EndDate From Period where Type = 'Quarter' and Number =:quarter and FiscalYearSettings.Name=:fiscal limit 1];
        if(periods.size() > 0)
        {
            return periods[0].EndDate;
        }
        return Date.today();
    }
    
    //gets all opps created in 90days and formula filed BookingType="New & Follow"
    private static List<String> getNewAndFollowAllOpps(Id userId)
    {
        AggregateResult[] results = [select sum(OppCounter__c) oppCounts, sum(Amount) amountSum from Opportunity where OwnerId = :userId and StageName != 'Closed Deleted' and BookingType__c in ('New', 'Follow On') and CreatedDate >= LAST_90_DAYS];
        if(results.size() > 0)
        {
            String oppCounts = String.valueOf(Integer.valueOf((results[0].get('oppCounts') == null) ? 0 : results[0].get('oppCounts')));
            return new String[] { oppCounts, String.valueOf((results[0].get('amountSum') == null) ? 0 : results[0].get('amountSum')) };
        }
        return new String[] { '0', '0' };
    }
    
    //gets closed opps created in 90days and formula filed BookingType="New & Follow"
    private static List<String> getNewAndFollowClosedOpps(Id userId)
    {
        List<Opportunity> opps = [select Id, Amount, StageName, Split_Adjustment__c, CloseDate, CreatedDate from Opportunity where IsClosed=true and OwnerId=:userId and StageName != 'Closed Deleted' and BookingType__c in ('New', 'Follow On') and CloseDate >= LAST_90_DAYS limit 50000];
        
        Integer totalCount = 0;
        Decimal totalAmount = 0;
        Integer wonCount = 0;
        Decimal wonAmount = 0;
        Decimal wonAvgAge = 0;
        Integer wonTotalAge = 0;
        Integer deadCount = 0;
        Decimal deadAmount = 0;
        Integer lostCount = 0;
        Decimal lostAmount = 0;
        
        for(Opportunity opp : opps)
        {
            if(opp.Split_Adjustment__c != true)
            {
                totalCount++;
            }
            totalAmount += (opp.Amount == null) ? 0 : opp.Amount;
            if(opp.StageName == 'Closed Won')
            {
                if(opp.Split_Adjustment__c != true)
                {
                    wonCount++;
                }
                wonAmount += (opp.Amount == null) ? 0 : opp.Amount;
                wonTotalAge += opp.CreatedDate.date().daysBetween(opp.CloseDate);
                if(wonCount != 0)
                {
                    wonAvgAge = wonTotalAge * 1.0 / wonCount;
                }
            }
            else if(opp.StageName == 'Closed Lost')
            {
                if(opp.Split_Adjustment__c != true)
                {
                    lostCount++;
                }
                lostAmount += (opp.Amount == null) ? 0 : opp.Amount;
            }
            else if(opp.StageName == 'Closed Dead')
            {
                if(opp.Split_Adjustment__c != true)
                {
                    deadCount++;
                }
                deadAmount += (opp.Amount == null) ? 0 : opp.Amount;
            }
        }
        return new  String[] { String.valueOf(totalCount), String.valueOf(totalAmount), String.valueOf(wonCount), String.valueOf(wonAmount), String.valueOf(wonAvgAge.setScale(1)),
                                            String.valueOf(deadCount), String.valueOf(deadAmount), String.valueOf(lostCount), String.valueOf(lostAmount)};
    }
    
    //gets currently all open Opps
    private static List<String> getAllOpenOpps(Id userId)
    {
        List<Opportunity> opps = [select Id, Amount, CreatedDate from Opportunity where OwnerId =:userId and IsClosed=false limit 50000];
        Integer totalCount = opps.size();
        Decimal amount = 0;
        Integer totalAge = 0;
        Decimal avgAge = 0;
        if(opps.size() > 0)
        {
            for(Opportunity opp : opps)
            {
                amount += (opp.Amount == null) ? 0 : opp.Amount;
                totalAge += opp.CreatedDate.date().daysBetween(Date.today());
            }
        }
        if(totalCount != 0)
        {
            avgAge = totalAge * 1.0 / totalCount;
        }
        return new String[] { String.valueOf(totalCount), String.valueOf(amount), String.valueOf(avgAge.setScale(1))};
    }
    
    private static String formatDate(DateTime d)
    {
        String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
        String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
        return month + '/' + day + '/' + d.year();
    }
    
    global class ForecastReport
    {   
        webservice String fiscalId { get; set; }
        webservice String fiscalName { get; set; }
        webservice String userId { get; set; }
        webservice String userName { get; set; }
        
        webservice Decimal quotaNewPhysicalAmount { get; set; }
        webservice Decimal quotaNewVirtualAmount { get; set; }
        webservice Decimal quotaNewAmount { get; set; }
        webservice Decimal quotaFollowOnAmount { get; set; }
        webservice Decimal quotaMRAmount { get; set; }
        webservice Decimal commitmentNewPhysicalAmount {get; set;}
        webservice Decimal commitmentNewVirtualAmount {get; set;}
        webservice Decimal commitmentNewAmount {get; set;}
        webservice Decimal commitmentFollowOnAmount { get; set;}
        webservice Decimal commitmentMRAmount { get; set;}
        webservice Decimal forecastNewPhysicalAmount { get; set;}
        webservice Decimal forecastNewVirtualAmount { get; set;}
        webservice Decimal forecastNewAmount { get; set;}
        webservice String  forecastNewLastUpdateDate { get; set; }
        webservice Decimal forecastFollowOnAmount { get; set;}
        webservice String  forecastFollowOnLastUpdateDate { get; set; }
        webservice Decimal forecastNewFollowOnAmount { get; set;}
        webservice String  forecastNewFollowOnLastUpdateDate { get; set; }
        webservice Decimal forecastMRAmount{get; set;}
        webservice String  forecastMRLastUpdateDate { get; set; }
        
        webservice Decimal physicalWonNewAmount { get; set; }
        webservice Decimal physicalWonNewExpAmount{get; set;}
        webservice Integer physicalWonNewCount{get; set;}
        webservice Decimal physicalWonFollowOnAmount { get; set; }
        webservice Decimal physicalWonFollowOnExpAmount{get; set;}
        webservice Integer physicalWonFollowOnCount{get; set;}
        webservice Decimal physicalWonMRAmount{get; set;}
        webservice Decimal physicalWonMRExpAmount{get; set;}
        webservice Integer physicalWonMRCount{get; set;}
        webservice Decimal physicalWonTotalAmount{get; set;}
        webservice Decimal physicalWonTotalExpAmount{get; set;}
        webservice Integer physicalWonTotalCount{get; set;}
        
        webservice Decimal physicalWonForecastNewAmount { get; set; }
        webservice Decimal physicalWonForecastNewExpAmount{get; set;}
        webservice Integer physicalWonForecastNewCount{get; set;}
        webservice Decimal physicalWonForecastFollowOnAmount { get; set; }
        webservice Decimal physicalWonForecastFollowOnExpAmount{get; set;}
        webservice Integer physicalWonForecastFollowOnCount{get; set;}
        webservice Decimal physicalWonForecastMRAmount{get; set;}
        webservice Decimal physicalWonForecastMRExpAmount{get; set;}
        webservice Integer physicalWonForecastMRCount{get; set;}
        webservice Decimal physicalWonForecastTotalAmount{get; set;}
        webservice Decimal physicalWonForecastTotalExpAmount{get; set;}
        webservice Integer physicalWonForecastTotalCount{get; set;}
        
        webservice Decimal physicalWonForecastBestNewAmount { get; set; }
        webservice Decimal physicalWonForecastBestNewExpAmount{get; set;}
        webservice Integer physicalWonForecastBestNewCount{get; set;}
        webservice Decimal physicalWonForecastBestFollowOnAmount { get; set; }
        webservice Decimal physicalWonForecastBestFollowOnExpAmount{get; set;}
        webservice Integer physicalWonForecastBestFollowOnCount{get; set;}
        webservice Decimal physicalWonForecastBestMRAmount{get; set;}
        webservice Decimal physicalWonForecastBestMRExpAmount{get; set;}
        webservice Integer physicalWonForecastBestMRCount{get; set;}
        webservice Decimal physicalWonForecastBestTotalAmount{get; set;}
        webservice Decimal physicalWonForecastBestTotalExpAmount{get; set;}
        webservice Integer physicalWonForecastBestTotalCount{get; set;}
        
        webservice Decimal physicalPipelineNewAmount { get; set; }
        webservice Decimal physicalPipelineNewExpAmount{get; set;}
        webservice Integer physicalPipelineNewCount{get; set;}
        webservice Decimal physicalPipelineFollowOnAmount { get; set; }
        webservice Decimal physicalPipelineFollowOnExpAmount{get; set;}
        webservice Integer physicalPipelineFollowOnCount{get; set;}
        webservice Decimal physicalPipelineMRAmount{get; set;}
        webservice Decimal physicalPipelineMRExpAmount{get; set;}
        webservice Integer physicalPipelineMRCount{get; set;}
        webservice Decimal physicalPipelineTotalAmount{get; set;}
        webservice Decimal physicalPipelineTotalExpAmount{get; set;}
        webservice Integer physicalPipelineTotalCount{get; set;}
        
        webservice Decimal virtualWonNewAmount { get; set; }
        webservice Decimal virtualWonNewExpAmount{get; set;}
        webservice Integer virtualWonNewCount{get; set;}
        webservice Decimal virtualWonFollowOnAmount { get; set; }
        webservice Decimal virtualWonFollowOnExpAmount{get; set;}
        webservice Integer virtualWonFollowOnCount{get; set;}
        webservice Decimal virtualWonMRAmount{get; set;}
        webservice Decimal virtualWonMRExpAmount{get; set;}
        webservice Integer virtualWonMRCount{get; set;}
        webservice Decimal virtualWonTotalAmount{get; set;}
        webservice Decimal virtualWonTotalExpAmount{get; set;}
        webservice Integer virtualWonTotalCount{get; set;}
        
        webservice Decimal virtualWonForecastNewAmount { get; set; }
        webservice Decimal virtualWonForecastNewExpAmount{get; set;}
        webservice Integer virtualWonForecastNewCount{get; set;}
        webservice Decimal virtualWonForecastFollowOnAmount { get; set; }
        webservice Decimal virtualWonForecastFollowOnExpAmount{get; set;}
        webservice Integer virtualWonForecastFollowOnCount{get; set;}
        webservice Decimal virtualWonForecastMRAmount{get; set;}
        webservice Decimal virtualWonForecastMRExpAmount{get; set;}
        webservice Integer virtualWonForecastMRCount{get; set;}
        webservice Decimal virtualWonForecastTotalAmount{get; set;}
        webservice Decimal virtualWonForecastTotalExpAmount{get; set;}
        webservice Integer virtualWonForecastTotalCount{get; set;}
        
        webservice Decimal virtualWonForecastBestNewAmount { get; set; }
        webservice Decimal virtualWonForecastBestNewExpAmount{get; set;}
        webservice Integer virtualWonForecastBestNewCount{get; set;}
        webservice Decimal virtualWonForecastBestFollowOnAmount { get; set; }
        webservice Decimal virtualWonForecastBestFollowOnExpAmount{get; set;}
        webservice Integer virtualWonForecastBestFollowOnCount{get; set;}
        webservice Decimal virtualWonForecastBestMRAmount{get; set;}
        webservice Decimal virtualWonForecastBestMRExpAmount{get; set;}
        webservice Integer virtualWonForecastBestMRCount{get; set;}
        webservice Decimal virtualWonForecastBestTotalAmount{get; set;}
        webservice Decimal virtualWonForecastBestTotalExpAmount{get; set;}
        webservice Integer virtualWonForecastBestTotalCount{get; set;}
        
        webservice Decimal virtualPipelineNewAmount { get; set; }
        webservice Decimal virtualPipelineNewExpAmount{get; set;}
        webservice Integer virtualPipelineNewCount{get; set;}
        webservice Decimal virtualPipelineFollowOnAmount { get; set; }
        webservice Decimal virtualPipelineFollowOnExpAmount{get; set;}
        webservice Integer virtualPipelineFollowOnCount{get; set;}
        webservice Decimal virtualPipelineMRAmount{get; set;}
        webservice Decimal virtualPipelineMRExpAmount{get; set;}
        webservice Integer virtualPipelineMRCount{get; set;}
        webservice Decimal virtualPipelineTotalAmount{get; set;}
        webservice Decimal virtualPipelineTotalExpAmount{get; set;}
        webservice Integer virtualPipelineTotalCount{get; set;}
        
        webservice Decimal undefinedNewAmount { get; set; }
        webservice Decimal undefinedNewExpAmount{get; set;}
        webservice Integer undefinedNewCount{get; set;}
        webservice Decimal undefinedFollowOnAmount { get; set; }
        webservice Decimal undefinedFollowOnExpAmount{get; set;}
        webservice Integer undefinedFollowOnCount{get; set;}
        webservice Decimal undefinedMRAmount{get; set;}
        webservice Decimal undefinedMRExpAmount{get; set;}
        webservice Integer undefinedMRCount{get; set;}
        webservice Decimal undefinedTotalAmount{get; set;}
        webservice Decimal undefinedTotalExpAmount{get; set;}
        webservice Integer undefinedTotalCount{get; set;}
        
        webservice Decimal totalWonNewAmount { get; set; }
        webservice Decimal totalWonNewExpAmount{get; set;}
        webservice Integer totalWonNewCount{get; set;}
        webservice Decimal totalWonFollowOnAmount { get; set; }
        webservice Decimal totalWonFollowOnExpAmount{get; set;}
        webservice Integer totalWonFollowOnCount{get; set;}
        webservice Decimal totalWonMRAmount{get; set;}
        webservice Decimal totalWonMRExpAmount{get; set;}
        webservice Integer totalWonMRCount{get; set;}
        webservice Decimal totalWonAmount{get; set;}
        webservice Decimal totalWonExpAmount{get; set;}
        webservice Integer totalWonCount{get; set;}
        
        webservice Decimal totalWonForecastNewAmount{get; set;}
        webservice Decimal totalWonForecastNewExpAmount{get; set;}
        webservice Integer totalWonForecastNewCount{get; set;}
        webservice Decimal totalWonForecastFollowOnAmount{get; set;}
        webservice Decimal totalWonForecastFollowOnExpAmount{get; set;}
        webservice Integer totalWonForecastFollowOnCount{get; set;}
        webservice Decimal totalWonForecastMRAmount{get; set;}
        webservice Decimal totalWonForecastMRExpAmount{get; set;}
        webservice Integer totalWonForecastMRCount{get; set;}
        webservice Decimal totalWonForecastAmount{get; set;}
        webservice Decimal totalWonForecastExpAmount{get; set;}
        webservice Integer totalWonForecastCount{get; set;}
        
        webservice Decimal totalWonForecastBestNewAmount{get; set;}
        webservice Decimal totalWonForecastBestNewExpAmount{get; set;}
        webservice Integer totalWonForecastBestNewCount{get; set;}
        webservice Decimal totalWonForecastBestFollowOnAmount{get; set;}
        webservice Decimal totalWonForecastBestFollowOnExpAmount{get; set;}
        webservice Integer totalWonForecastBestFollowOnCount{get; set;}
        webservice Decimal totalWonForecastBestMRAmount{get; set;}
        webservice Decimal totalWonForecastBestMRExpAmount{get; set;}
        webservice Integer totalWonForecastBestMRCount{get; set;}
        webservice Decimal totalWonForecastBestAmount{get; set;}
        webservice Decimal totalWonForecastBestExpAmount{get; set;}
        webservice Integer totalWonForecastBestCount{get; set;}
        
        webservice Decimal totalPipelineNewAmount{get; set;}
        webservice Decimal totalPipelineNewExpAmount{get; set;}
        webservice Integer totalPipelineNewCount{get; set;}
        webservice Decimal totalPipelineFollowOnAmount{get; set;}
        webservice Decimal totalPipelineFollowOnExpAmount{get; set;}
        webservice Integer totalPipelineFollowOnCount{get; set;}
        webservice Decimal totalPipelineMRAmount{get; set;}
        webservice Decimal totalPipelineMRExpAmount{get; set;}
        webservice Integer totalPipelineMRCount{get; set;}
        webservice Decimal totalPipelineAmount{get; set;}
        webservice Decimal totalPipelineExpAmount{get; set;}
        webservice Integer totalPipelineCount{get; set;}
        
        webservice Decimal totalLostDeadMRAmount { get; set; }
        
        webservice Decimal annualTarget { get; set; }
        
        public Integer NewOppCount { get; set; }
        public Integer ClosedDeadOppCount { get; set; }
        
        public ForecastReport()
        {
            fiscalId = '';
            fiscalName = '';
            
            quotaNewPhysicalAmount = 0;
            quotaNewVirtualAmount = 0;
            quotaNewAmount = 0;
            quotaFollowOnAmount = 0;
            quotaMRAmount = 0;
            commitmentNewPhysicalAmount = 0;
            commitmentNewVirtualAmount = 0;
            commitmentNewAmount = 0;
            commitmentFollowOnAmount = 0;
            commitmentMRAmount = 0;
            forecastNewPhysicalAmount = 0;
            forecastNewVirtualAmount = 0;
            forecastNewAmount = 0;
            forecastNewLastUpdateDate = null;
            forecastFollowOnAmount = 0;
            forecastFollowOnLastUpdateDate = null;
            forecastNewFollowOnAmount = 0;
            forecastNewFollowOnLastUpdateDate = null;
            forecastMRAmount = 0;
            forecastMRLastUpdateDate = null;
        
            physicalWonNewAmount = 0;
            physicalWonNewExpAmount = 0;
            physicalWonNewCount = 0;
            physicalWonFollowOnAmount = 0;
            physicalWonFollowOnExpAmount = 0;
            physicalWonFollowOnCount = 0;
            physicalWonMRAmount = 0;
            physicalWonMRExpAmount = 0;
            physicalWonMRCount = 0;
            physicalWonTotalAmount = 0;
            physicalWonTotalExpAmount = 0;
            physicalWonTotalCount = 0;
        
            physicalWonForecastNewAmount = 0;
            physicalWonForecastNewExpAmount = 0;
            physicalWonForecastNewCount = 0;
            physicalWonForecastFollowOnAmount = 0;
            physicalWonForecastFollowOnExpAmount = 0;
            physicalWonForecastFollowOnCount = 0;
            physicalWonForecastMRAmount = 0;
            physicalWonForecastMRExpAmount = 0;
            physicalWonForecastMRCount = 0;
            physicalWonForecastTotalAmount = 0;
            physicalWonForecastTotalExpAmount = 0;
            physicalWonForecastTotalCount = 0;
        
            physicalWonForecastBestNewAmount = 0;
            physicalWonForecastBestNewExpAmount = 0;
            physicalWonForecastBestNewCount = 0;
            physicalWonForecastBestFollowOnAmount = 0;
            physicalWonForecastBestFollowOnExpAmount = 0;
            physicalWonForecastBestFollowOnCount = 0;
            physicalWonForecastBestMRAmount = 0;
            physicalWonForecastBestMRExpAmount = 0;
            physicalWonForecastBestMRCount = 0;
            physicalWonForecastBestTotalAmount = 0;
            physicalWonForecastBestTotalExpAmount = 0;
            physicalWonForecastBestTotalCount = 0;
        
            physicalPipelineNewAmount = 0;
            physicalPipelineNewExpAmount = 0;
            physicalPipelineNewCount = 0;
            physicalPipelineFollowOnAmount = 0;
            physicalPipelineFollowOnExpAmount = 0;
            physicalPipelineFollowOnCount = 0;
            physicalPipelineMRAmount = 0;
            physicalPipelineMRExpAmount = 0;
            physicalPipelineMRCount = 0;
            physicalPipelineTotalAmount = 0;
            physicalPipelineTotalExpAmount = 0;
            physicalPipelineTotalCount = 0;
        
            virtualWonNewAmount = 0;
            virtualWonNewExpAmount = 0;
            virtualWonNewCount = 0;
            virtualWonFollowOnAmount = 0;
            virtualWonFollowOnExpAmount = 0;
            virtualWonFollowOnCount = 0;
            virtualWonMRAmount = 0;
            virtualWonMRExpAmount = 0;
            virtualWonMRCount = 0;
            virtualWonTotalAmount = 0;
            virtualWonTotalExpAmount = 0;
            virtualWonTotalCount = 0;
        
            virtualWonForecastNewAmount = 0;
            virtualWonForecastNewExpAmount = 0;
            virtualWonForecastNewCount = 0;
            virtualWonForecastFollowOnAmount = 0;
            virtualWonForecastFollowOnExpAmount = 0;
            virtualWonForecastFollowOnCount = 0;
            virtualWonForecastMRAmount = 0;
            virtualWonForecastMRExpAmount = 0;
            virtualWonForecastMRCount = 0;
            virtualWonForecastTotalAmount = 0;
            virtualWonForecastTotalExpAmount = 0;
            virtualWonForecastTotalCount = 0;
        
            virtualWonForecastBestNewAmount = 0;
            virtualWonForecastBestNewExpAmount = 0;
            virtualWonForecastBestNewCount = 0;
            virtualWonForecastBestFollowOnAmount = 0;
            virtualWonForecastBestFollowOnExpAmount = 0;
            virtualWonForecastBestFollowOnCount = 0;
            virtualWonForecastBestMRAmount = 0;
            virtualWonForecastBestMRExpAmount = 0;
            virtualWonForecastBestMRCount = 0;
            virtualWonForecastBestTotalAmount = 0;
            virtualWonForecastBestTotalExpAmount = 0;
            virtualWonForecastBestTotalCount = 0;
        
            virtualPipelineNewAmount = 0;
            virtualPipelineNewExpAmount = 0;
            virtualPipelineNewCount = 0;
            virtualPipelineFollowOnAmount = 0;
            virtualPipelineFollowOnExpAmount = 0;
            virtualPipelineFollowOnCount = 0;
            virtualPipelineMRAmount = 0;
            virtualPipelineMRExpAmount = 0;
            virtualPipelineMRCount = 0;
            virtualPipelineTotalAmount = 0;
            virtualPipelineTotalExpAmount = 0;
            virtualPipelineTotalCount = 0;
        
            undefinedNewAmount = 0;
            undefinedNewExpAmount = 0;
            undefinedNewCount = 0;
            undefinedFollowOnAmount = 0;
            undefinedFollowOnExpAmount = 0;
            undefinedFollowOnCount = 0;
            undefinedMRAmount = 0;
            undefinedMRExpAmount = 0;
            undefinedMRCount = 0;
            undefinedTotalAmount = 0;
            undefinedTotalExpAmount = 0;
            undefinedTotalCount = 0;
            
            totalWonNewAmount = 0;
            totalWonNewExpAmount = 0;
            totalWonNewCount = 0;
            totalWonFollowOnAmount = 0;
            totalWonFollowOnExpAmount = 0;
            totalWonFollowOnCount = 0;
            totalWonMRAmount = 0;
            totalWonMRExpAmount = 0;
            totalWonMRCount = 0;
            totalWonAmount = 0;
            totalWonExpAmount = 0;
            totalWonCount = 0;
        
            totalWonForecastNewAmount = 0;
            totalWonForecastNewExpAmount = 0;
            totalWonForecastNewCount = 0;
            totalWonForecastFollowOnAmount = 0;
            totalWonForecastFollowOnExpAmount = 0;
            totalWonForecastFollowOnCount = 0;
            totalWonForecastMRAmount = 0;
            totalWonForecastMRExpAmount = 0;
            totalWonForecastMRCount = 0;
            totalWonForecastAmount = 0;
            totalWonForecastExpAmount = 0;
            totalWonForecastCount = 0;
        
            totalWonForecastBestNewAmount = 0;
            totalWonForecastBestNewExpAmount = 0;
            totalWonForecastBestNewCount = 0;
            totalWonForecastBestFollowOnAmount = 0;
            totalWonForecastBestFollowOnExpAmount = 0;
            totalWonForecastBestFollowOnCount = 0;
            totalWonForecastBestMRAmount = 0;
            totalWonForecastBestMRExpAmount = 0;
            totalWonForecastBestMRCount = 0;
            totalWonForecastBestAmount = 0;
            totalWonForecastBestExpAmount = 0;
            totalWonForecastBestCount = 0;
        
            totalPipelineNewAmount = 0;
            totalPipelineNewExpAmount = 0;
            totalPipelineNewCount = 0;
            totalPipelineFollowOnAmount = 0;
            totalPipelineFollowOnExpAmount = 0;
            totalPipelineFollowOnCount = 0;
            totalPipelineMRAmount = 0;
            totalPipelineMRExpAmount = 0;
            totalPipelineMRCount = 0;
            totalPipelineAmount = 0;
            totalPipelineExpAmount = 0;
            totalPipelineCount = 0;
            
            totalLostDeadMRAmount = 0;
            annualTarget = 0;
            
            NewOppCount = 0;
            ClosedDeadOppCount = 0;
        }
    }
    
    global class AttainmentDashboard
    {
        public Decimal annualTarget { get; set; }
        public Decimal amountClosedYtd { get; set; }
        public Decimal currentAttainment { get; set; }
        public Decimal ytdAttainment { get; set; }
        public Decimal daysPassed { get; set; }
    }
    
    global class ForecastingException extends Exception 
    {
    }
}