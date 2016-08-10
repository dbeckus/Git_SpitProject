/*
 * Controller for page Forecasting
 */
public class ForecastingController  
{
    private static Map<Id, Id> allRoles;
    
    public List<User> UserNavigate { get; set;}
    public Date StartDate { get; set; }
    public Date EndDate { get; set; }
    public String popupNFPValue { get; set; }   //new and followong physical
    public String popupNFVValue { get; set; }   //new and followong virtual
    public String popupMrValue { get; set; }    //maintenance renewal
    public String popupComment { get;set;}
    public String popupType { get; set; } 
    
    public ForecastingController()
    {
        userNavigate = new List<User>();
        
        String quarterString = ApexPages.currentPage().getParameters().get('quarter');
        if(IsValidFiscalQuarter(quarterString))
        {
            CurrentFiscalQuarter = quarterString;
            StartDate = parseStartDate(CurrentFiscalQuarter);
            EndDate = parseEndDate(CurrentFiscalQuarter);
        }
        else
        {
            InitFiscalQuarter();
        }
 
        //path of the user navigations, separated with '/'
        String path = ApexPages.currentPage().getParameters().get('path');
        if(path != null)
        {
            for(String pathEntry : path.split('/'))
            {
                if(pathEntry != '' && pathEntry != null)
                {
                    userNavigate.add(getSingleUserWithRole(pathEntry));
                }
            }
        }
        
        if(userNavigate.size() == 0)
        {
            if(!CurrentUser.SPForecastEnabled__c && CurrentUser.ViewForecastAs__c != null)
            {
               userNavigate.add(getSingleUserWithRole(CurrentUser.ViewForecastAs__c)); 
            }
            else
            {
                userNavigate.add(getSingleUserWithRole(UserInfo.getUserId()));
            }
        }
        else
        {
            ValidateUserNavigationPath();
        }
    }
    
    public String CurrentFiscalQuarter { get; set;}

    public User CurrentUser
    {
        get
        {
            return [select Id, SPForecastEnabled__c, ViewForecastAs__c from User where Id=:UserInfo.getUserId() limit 1];
        }
    }
    
    public String PreviousFiscalQuarter
    {
        get
        {
            if(CurrentFiscalQuarter == null || CurrentFiscalQuarter == '')
            {
                InitFiscalQuarter();
            }
            Integer fiscal = Integer.valueOf(CurrentFiscalQuarter.substring(0, 4));
            Integer quarter = Integer.valueOf(CurrentFiscalQuarter.substring(5, 6));
            if(quarter == 1)
            {
                return (fiscal - 1) + 'Q4';
            }
            else
            {
                return fiscal + 'Q' + (quarter - 1);
            }
        }
    }
    
    public String NextFiscalQuarter
    {
        get
        {
            if(CurrentFiscalQuarter == null || CurrentFiscalQuarter == '')
            {
                InitFiscalQuarter();
            }
            Integer fiscal = Integer.valueOf(CurrentFiscalQuarter.substring(0, 4));
            Integer quarter = Integer.valueOf(CurrentFiscalQuarter.substring(5, 6));
            if(quarter == 4)
            {
                return (fiscal + 1) + 'Q1';
            }
            else
            {
                return fiscal + 'Q' + (quarter + 1);
            }
        }
    }
    
    //gets the path of the user navigation, a string composed of user ids separated by '/'
    public String Path
    {
        get
        {
            String result = '';
            for(User usr : userNavigate)
            {
                result += usr.Id + '/';
            }
            return result;
        }
    }
    
    public User CurrentViewingUser
    {
        get
        {
            if(userNavigate.size() > 0)
            {
                return userNavigate[userNavigate.size() - 1];
            }
            else
            {
                return null;
            }
        }
    }

    public User ParentUser
    {
        get
        {
            return userNavigate[0];
        }
    }
    
    //gets all roles in the organization
    /*public List<UserRole> allUserRoles
    {
        get
        {
            return [select Id, ParentRoleId from UserRole where ((PortalType='None') OR ((Portaltype='Partner') AND (PortalRole='Executive')))];
        }
    }*/
    
    //the history list to be displayed on page
    public List<Forecasting_History__c> ForecastingHistory
    {
        get
        {
             return [select Value__c, User__c, Type__c,  Period__c, OwnerId, User__r.Name, OppExpAmount__c, OppCount__c, OppAmount__c, Old_Value__c, Name, LastModifiedDate, LastModifiedById, Id, ForecastSubmit__c, CreatedDate, CreatedById, Date__c, Comments__c from Forecasting_History__c where Date__c >= :startDate and  Date__c <= :endDate and ForecastSubmit__c = false  and User__c =:currentViewingUser.Id and Period__c = :currentFiscalQuarter order by Date__c desc];    
        }
    }

    @RemoteAction
    public static void saveForecast(Id userId, String fiscalQtr, ForecastEntry entryValue)
    {
        //starting from 8/1/2014, only forecast new & follow on value is being used
        SavePoint sp = Database.setSavePoint();
        List<SPForecasting__c> spForcast = [select User__c, Type__c, Name, MRAmount__c, Id, Fiscal_Period__c, CreatedDate, Amount__c, NewVirtualAmount__c, NewAmount__c, FollowOnAmount__c From SPForecasting__c where User__c =:userId and Fiscal_Period__c =:fiscalQtr and Type__c =:entryValue.type order by CreatedDate limit 1];

        Decimal oldValue = 0;
        Decimal newValue = 0;

        newValue = entryValue.nbValue;
        
        if(newValue == null)
        {
            throw new ForecastingException('Invalid number value');
        }
        
        if(spForcast.size() > 0)
        {   
              oldValue = spForcast[0].Amount__c;
              spForcast[0].Amount__c = newValue;
        }
        else
        {   spForcast = new List<SPForecasting__c>();
            spForcast.add(new SPForecasting__c(User__c = userId, Fiscal_Period__c=fiscalQtr, Amount__c=newValue, Type__c = entryValue.type));
        }
        try
        {
            upsert spForcast[0];
            List<Forecasting_History__c> updForcastHistoryList = new List<Forecasting_History__c>();
            Forecasting_History__c amountQta1 = new Forecasting_History__c(User__c = userId, Type__c = 'NewFollowOn-' + entryValue.type, Value__c = newValue, Old_Value__c = oldValue, Period__c = fiscalQtr, ForecastSubmit__c = false, Comments__c = entryValue.comment);
            updForcastHistoryList.add(amountQta1);
            if(updForcastHistoryList.size() > 0 )
            {
                insert updForcastHistoryList;
            }
        }
        catch (Exception e) 
        {
            Database.rollback(sp);
            throw new ForecastingException('Failed to save forecast. Error message is: ' + e.getMessage());
        }
    }
    
    //gets all direct subordinate users of specified user
    @Readonly @RemoteAction
    public static List<Id> getDirectSubordinateUsers(String userId)
    {
        List<Id> result = new List<Id>();
        List<User> users = [select Id, Name, UserRoleId, GEO_Region__c from User where Id=:userId limit 1];
        if(users.size() > 0)
        {
            for(User usr : [select Id, Name, UserRoleId, GEO_Region__c from User where UserRole.ParentRoleId=:users[0].UserRoleId and SPForecastEnabled__c=true])
            {
                result.add(usr.Id);
            }
        }
        return result;
    }
    
    //gets all users role down the specified user
    @Readonly @RemoteAction
    public static List<Id> getAllSubordinateUsers(String userId)
    {
        List<Id> result = new List<Id>();
        List<User> users = [select Id, Name, UserRoleId, GEO_Region__c from User where Id=:userId limit 1];
        if(users.size() > 0)
        {
            List<String> subRoles = getAllSubRoles(users[0].UserRoleId);
            for(User usr : [select Id, Name, UserRoleId, GEO_Region__c from User where UserRoleId in :subRoles and SPForecastEnabled__c=true])
            {
                result.add(usr.Id);
            }
        }
        return result;
    }
   
    //gets all roles down the specified role    
    private static List<String> getAllSubRoles(String roleId)
    {  
        List<String> result = new List<String>();
        if(allRoles == null)
        {
            allRoles = new Map<Id, Id>();
            for(UserRole role : [select Id, Name, ParentRoleId from UserRole where ((PortalType='None') OR ((Portaltype='Partner') AND (PortalRole='Executive')))])
            {
                allRoles.put(role.Id, role.ParentRoleId);
            }
        }
        for(String Id : allRoles.keySet())
        {
            if(allRoles.get(Id) == roleId)
            {
                result.add(Id);
                result.addAll(getAllSubRoles(Id));
            }
        } 
        return result;
    }
    
    public static Date parseStartDate(String fiscalQuarter)
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
    public static Date parseEndDate(String fiscalQuarter)
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
    
    public static Date getStartOfCurrentFiscalYear()
    {
        List<Period> periods = [select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Year' and StartDate <= Today AND EndDate >= Today limit 1];
        if(periods.size() > 0)
        {
            return periods[0].StartDate;
        }
        return null;
    }
    
    private Boolean ValidateUserNavigationPath()
    {
        if(userNavigate[0].Id != UserInfo.getUserId() && userNavigate[0].Id != CurrentUser.ViewForecastAs__c)
        {
            throw new ForecastingException('Invalid user navigation path.');
        }
        return true;
    }
    
    private void InitFiscalQuarter()
    {
        Period currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <= Today AND EndDate >= Today limit 1];
        if(currentPeriod == null)
        {
            throw new ForecastingException('Current FiscalQuarter cannot be found.');
        }
        else
        {
            CurrentFiscalQuarter = currentPeriod.FiscalYearSettings.Name + 'Q' + currentPeriod.Number;
        }
        StartDate = currentPeriod.StartDate;
        EndDate = currentPeriod.EndDate;    
    }
    
    private User getSingleUserWithRole(String userId)
    {
        List<User> users = [select Id, Name, UserRoleId from User where Id =: userId limit 1];
        if(users.size() > 0)
        {
            return users[0];
        }
        else
        {
            throw new ForecastingException('Specified user cannot be found: ' + userId);
        }
    }
    private Boolean IsValidFiscalQuarter(String fiscalQuarter)
    {
        if(fiscalQuarter == null)
        {
            return false;
        }
        if(fiscalQuarter.length() != 6)
        {
            return false;
        }
        if(Pattern.matches('\\d\\d\\d\\dQ\\d', fiscalQuarter))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public class ForecastEntry
    {
        public String type { get; set; }
        public Decimal nbValue { get; set; }
        public Decimal foValue { get; set; }
        public Decimal mrValue { get; set; }
        public String comment { get; set; }
    }
    
    public class ForecastingException extends Exception {}

}