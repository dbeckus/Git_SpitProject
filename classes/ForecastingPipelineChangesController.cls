/*
 * controller of page ForecastingPipelineChangesController
 */
public class ForecastingPipelineChangesController 
{
    private String currentUserId;
    
    public ForecastingPipelineChangesController()
    {
        fiscalQuarter = ApexPages.currentPage().getParameters().get('quarter');
        currentUserId = ApexPages.currentPage().getParameters().get('uid');
        List<User> users = [select Id, Name from User where Id=:currentUserId limit 1];
        if(users.size() > 0)
        {
            Username = users[0].Name;
        }
    }
    
    public ForecastingPipelineChangesController(ForecastingController controller)
    {
        this();
    }
    
    public String Username { get; set; }
    public String fiscalQuarter { get; set; }

    public String SubTitle
    {
        get
        {
            String stype = ApexPages.currentPage().getParameters().get('type');
            if(stype == 'probabilityUp')
            {
                return 'Probability Up';
            }
            else if(stype == 'probabilityDown')
            {
                return 'Probability Down';
            }
            else if(stype == 'closeDateUp')
            {
                return 'Close Date Up';
            }
            else if(stype == 'closeDateDown')
            {
                return 'Close Date Down';
            }
            else if(stype == 'closedDead')
            {
                return 'Closed Dead Opportunities';
            }
            else if(stype == 'overdue')
            {
                return 'Overdue Opportunities';
            }
            return '';
        }
    }
    
    @RemoteAction
    public static TrendingListResult getPipelineChangeSummary(String fiscalQuarter, String userId)
    {
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
        allUsers.add(userId);
        TrendingListResult summary = initTrendList(fiscalQuarter, userId);
        TrendingListResult result = new TrendingListResult();
        result.ProbabilityUpCount = summary.ProbabilityUpCount;
        result.ProbabilityDownCount = summary.ProbabilityDownCount;
        result.CloseDateUpCount = summary.CloseDateUpCount;
        result.CloseDateDownCount = summary.CloseDateDownCount;
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getProbabilityUpList(String fiscalQuarter, String userId)
    {
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : initTrendList(fiscalQuarter, userId).ProbabilityUpList)
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getProbabilityDownList(String fiscalQuarter, String userId)
    {
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : initTrendList(fiscalQuarter, userId).ProbabilityDownList)
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getCloseDateUpList(String fiscalQuarter, String userId)
    {
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : initTrendList(fiscalQuarter, userId).CloseDateUpList)
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getCloseDateDownList(String fiscalQuarter, String userId)
    {
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : initTrendList(fiscalQuarter, userId).CloseDateDownList)
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getClosedDeadList(String fiscalQuarter, String userId)
    {
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
        allUsers.add(userId);
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : [select Id, Name, Type, Amount, ExpectedRevenue, CloseDate, ForecastCategoryName, Probability, Primary_Partner__c, Primary_Partner__r.Name, Registered_Partner__c, Registered_Partner__r.Name, OwnerId, Owner.Name, Technical_Responsible__c, Technical_Responsible__r.Name from Opportunity where OwnerId in :allUsers and CloseDate>=:startDate and CloseDate<=:endDate and StageName='Closed Dead' limit 5000])
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    @RemoteAction
    public static List<OpportunityEntry> getOverdueList(String fiscalQuarter, String userId)
    {
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
        allUsers.add(userId);
        List<OpportunityEntry> result = new List<OpportunityEntry>();
        for(Opportunity opp : [select Id, Name, Type, Amount, ExpectedRevenue, CloseDate, ForecastCategoryName, Probability, Primary_Partner__c, Primary_Partner__r.Name, Registered_Partner__c, Registered_Partner__r.Name, OwnerId, Owner.Name, Technical_Responsible__c, Technical_Responsible__r.Name from Opportunity where OwnerId in :allUsers and CloseDate < :startDate and isClosed=false and Type != 'Marketplace' and Split_Adjustment__c=false limit 5000])
        {
            result.add(new OpportunityEntry(opp));
        }
        return result;
    }
    
    private static TrendingListResult initTrendList(String fiscalQuarter, String userId)
    {
        TrendingListResult result = new TrendingListResult();
        Date startDate = ForecastingController.parseStartDate(fiscalQuarter);
        Date endDate = ForecastingController.parseEndDate(fiscalQuarter);
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
        allUsers.add(userId);
        for(Opportunity opp : [select Id, Name, Type, Amount, ExpectedRevenue, CloseDate, ForecastCategoryName, Probability, Primary_Partner__c, Primary_Partner__r.Name, Registered_Partner__c, Registered_Partner__r.Name, OwnerId, Owner.Name, Technical_Responsible__c, Technical_Responsible__r.Name, (select OldValue, NewValue, FIeld from Histories where (Field = 'Probability' or Field = 'CloseDate') and CreatedDate>=:startDate and CreatedDate<=:endDate order by CreatedDate desc) from Opportunity where OwnerId in :allUsers and IsClosed=false order by CreatedDate])
        {
            Boolean provabilityCalculated = false;
            Boolean closeDateCalculated = false;
            
            for(OpportunityFieldHistory history : opp.Histories)
            {
                if(history.Field == 'Probability' && !provabilityCalculated)
                {
                    Double newValue, oldValue;
                    try
                    {
                        newValue = (Double)(history.NewValue);
                        oldValue = (Double)(history.OldValue);
                    }
                    catch(Exception e)
                    {
                        newValue = 0;
                        oldValue = 0;
                    }
                    if(newValue > oldValue)
                    {
                        result.ProbabilityUpCount++;
                        result.ProbabilityUpList.add(opp);
                        provabilityCalculated = true;
                    }
                    else if(newValue < oldValue)
                    {
                        result.ProbabilityDownCount++;
                        result.ProbabilityDownList.add(opp);
                        provabilityCalculated = true;
                    }
                }
                else if(history.Field == 'CloseDate' && !closeDateCalculated)
                {
                    Time myTime = Time.newInstance(0, 0, 0, 0);
                    Date NewDate = Date.valueOf(history.NewValue == '' ? '1970-01-01' : history.NewValue);
                    Date OldDate = Date.valueOf(history.OldValue == '' ? '1970-01-01' : history.OldValue);
                    DateTime newValue = Datetime.newInstance(NewDate, myTime);
                    DateTime oldValue = Datetime.newInstance(OldDate, myTime);
                    if(newValue.getTime() < oldValue.getTime())
                    {
                        result.CloseDateUpCount++;
                        result.CloseDateUpList.add(opp);
                        closeDateCalculated = true;
                    }
                    else if(newValue.getTime() > oldValue.getTime())
                    {
                        result.CloseDateDownCount++;
                        result.CloseDateDownList.add(opp);
                        closeDateCalculated = true;
                    }
                }
            }
        }
        return result;
    }
    
    public class TrendingListResult
    {
        public TrendingListResult()
        {
            ProbabilityUpCount = 0;
            ProbabilityDownCount = 0;
            CloseDateUpCount = 0;
            CloseDateDownCount = 0;
            ProbabilityUpList = new List<Opportunity>();
            ProbabilityDownList = new List<Opportunity>();
            CloseDateUpList = new List<Opportunity>();
            CloseDateDownList = new List<Opportunity>();
        }
        
        public Integer ProbabilityUpCount { get; set; }
        public Integer ProbabilityDownCount { get; set; }
        public Integer CloseDateUpCount { get; set; }
        public Integer CloseDateDownCount { get; set; }
        
        public List<Opportunity> ProbabilityUpList { get; set; }
        public List<Opportunity> ProbabilityDownList { get; set; }
        public List<Opportunity> CloseDateUpList { get; set; }
        public List<Opportunity> CloseDateDownList { get; set; }
    }
    
    public class OpportunityEntry
    {
        public OpportunityEntry(Opportunity opp)
        {
            this.oppId = opp.Id;
            this.oppName = opp.Name;
            this.amount = opp.Amount;
            this.expectedRevenue = opp.expectedRevenue;
            this.probability = opp.Probability;
            this.closeDate = opp.CloseDate;
            this.forecastCategory = opp.ForecastCategoryName;
            this.type = opp.Type;
            this.primaryPartnerId = opp.Primary_Partner__c;
            this.primaryPartnerName = opp.Primary_Partner__r.Name;
            this.registeredPartnerId = opp.Registered_Partner__c;
            this.registeredPartnerName = opp.Registered_Partner__r.Name;
            this.ownerId = opp.OwnerId;
            this.ownerName = opp.Owner.Name;
            this.technicalResponsibleId = opp.Technical_Responsible__c;
            this.technicalResponsibleName = opp.Technical_Responsible__r.Name;
        }
        
        public String oppId { get; set; }
        public String oppName { get; set; }
        public Decimal amount { get; set; }
        public Decimal expectedRevenue { get; set; }
        public Decimal probability { get; set; }
        public Date closeDate { get; set; }
        public String forecastCategory { get; set; }
        public String type { get; set; }
        public String primaryPartnerId { get; set; }
        public String primaryPartnerName { get; set; }
        public String registeredPartnerId { get; set; }
        public String registeredPartnerName { get; set; }
        public String ownerId { get; set; }
        public String ownerName { get; set; }
        public String technicalResponsibleId { get; set; }
        public String technicalResponsibleName { get; set; }
    }

    @isTest
    static void testForecastingPipelineChangesController()
    {
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.newInstance(2014, 1, 1), StageName='Discovery');
        insert opp;
        
        PageReference page = new PageReference('/apex/ForecastingPipelineChanges?uid=' + UserInfo.getUserId() + '&quarter=2010Q4&type=probabilityUp');
        Test.setCurrentPage(page);
        ForecastingPipelineChangesController controller = new ForecastingPipelineChangesController();
        System.assertEquals('Probability Up', controller.subtitle);
        ForecastingPipelineChangesController.getPipelineChangeSummary('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getProbabilityUpList('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getProbabilityDownList('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getCloseDateUpList('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getCloseDateDownList('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getClosedDeadList('2014Q4', UserInfo.getUserId());
        ForecastingPipelineChangesController.getOverdueList('2014Q4', UserInfo.getUserId());
    }
}