/*
*    auto submit forecast information once a week on the background.
*/
global class ForecastAutoSubmit implements Database.Batchable<sObject>,Schedulable
{ 
    public String CurrentFiscalQuarter;
    //get all role and subrole.
    static Map<String, String> roles = new Map<String, String>();
    static
    {   
        List<UserRole> allRoles = [select Id, Name, ParentRoleId from UserRole where ((PortalType='None') OR ((Portaltype='Partner') AND (PortalRole='Executive')))];
        for(UserRole role : allRoles)
        {
            roles.put(role.Id, role.ParentRoleId);
        }
    } 
     
    public ForecastAutoSubmit()
    {
        InitFiscalQuarter();
    } 
    //gets current fiscal quarter.
    public void InitFiscalQuarter()
    {
        Period currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <= Today AND EndDate >= Today limit 1];
        if(currentPeriod == null)
        {
            throw new ForecastingException('currentPeriod cannot found.');
        }
        else
        {
            CurrentFiscalQuarter = currentPeriod.FiscalYearSettings.Name + 'Q' + currentPeriod.Number;
        }
        
    }
    
    global database.queryLocator start(Database.BatchableContext bc)
    {
       return Database.getQueryLocator([select Id, Name, UserRoleId from User where  SPForecastEnabled__c=true]);
    }
    
    global void execute (Database.BatchableContext bc, List<sObject> scope)
    {
        for(sObject obj: scope)
        {   
            User ur = (User)obj;
            autoSubmit(CurrentFiscalQuarter, ur.Id);
        }   
    }
    
    global void finish(Database.BatchableContext bc)
    {
        //after all batch execution finished goes here
    }
    
    public void autoSubmit(String fiscalQuarter, String userid)
    {
        ForecastingStatsService.ForecastReport report = ForecastingStatsService.getReport(fiscalQuarter, userid);
        report.NewOppCount = ForecastingStatsService.getNewOppCount(fiscalQuarter, userid);
        report.ClosedDeadOppCount = ForecastingStatsService.getDeadOppCount(fiscalQuarter, userid);
        ForecastingStatsService.insertSubmitForecast(report);
    }
    
    public class ForecastingException extends Exception {}
    
    //schedulable 
    global void execute(SchedulableContext ctx)
    { 
        ForecastAutoSubmit fa = new ForecastAutoSubmit();
        Database.executeBatch(fa,1);
    }
   
    @isTest
    static void testBatch()
    {
        ForecastAutoSubmit ffa = new ForecastAutoSubmit();
        SchedulableContext ctx;
        ffa.execute(ctx); 
          
        Test.startTest();
        ForecastAutoSubmit fa = new ForecastAutoSubmit();
        
        Database.executeBatch(fa,1);
        List<Forecasting_History__c> alerts = [Select Value__c, User__c, Type__c, Period__c, OwnerId, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name,Id, ForecastSubmit__c, CreatedDate,  Comments__c From Forecasting_History__c limit 1000];
        System.assert(alerts.size()> 1); 
        Test.stopTest();
        
        fa.autoSubmit('2010Q1', '00530000000giMZ');
    }
}