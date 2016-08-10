/*
* Controller for page Forecasting
*/
public without sharing class ForecastingOppListService
{
    private ForecastingController controller;
    
    public ForecastingOppListService(ForecastingController controller)
    {
        this.controller = controller;
    }
    
    @RemoteAction
    public static ForecastingOppListResponse getOpportunities(ForecastingOppListRequest request)
    {
        Integer pageSize = 25;
        ApexPages.StandardSetcontroller oppController = buildResultSet(request.userId, request.fiscalQtr, request.typeOption, request.isOver100K, request.sortField, request.isAscendingOrder);
        oppController.setPageSize(pageSize);
        if(request.pageIndex != null && request.pageIndex > 0)
        {
            oppController.setPageNumber(request.pageIndex);
        }
        ForecastingOppListResponse response = new ForecastingOppListResponse();
        response.hasNext = oppController.getHasNext();
        response.hasPrevious = oppController.getHasPrevious();
        response.pageIndex = oppController.getPageNumber();
        response.recordCount = oppController.getResultSize();
        response.pageCount = Math.ceil(response.recordCount * 1.0 / pageSize).intValue();
        List<Opportunity> allOpportunities = (List<Opportunity>)oppController.getRecords();
        allOpportunities = excludeWANStart(allOpportunities);
        for(sObject opp : allOpportunities)
        {
            response.opportunities.add(new OpportunityEntry((Opportunity)opp));
        }
        return response;
    }
    
    private static ApexPages.StandardSetcontroller buildResultSet(String userId, String fiscalQtr, String typeOption, Boolean isOver100K, String sortField, Boolean isAscendingOrder)
    {
        String limitAmount = '';
        if(isOver100K)
        {
            limitAmount =' and Amount >= 100000';
        }
        if(String.isBlank(typeOption))
        {
            typeOption = 'Rolling 180 Days';
        }
        String order = isAscendingOrder == true ? 'asc nulls first' : 'desc nulls last';
        if(String.isBlank(sortField))
        {       
            sortField = ' CloseDate ';
        }
        String types = null;
        if(typeOption.startsWith('Closed Won'))
        {
            types = ' CloseDate <= :endDate and CloseDate >=:startDate and IsClosed=true and IsWon=true ';
        }
        else if(typeOption.startsWith('Maintenance Renewal'))
        {
            types = ' CloseDate <= :endDate and CloseDate >=:startDate and BookingType__c=\'Maintenance Renewal\' and IsClosed=false ';
        }
        else if(typeOption == 'New & Follow On')
        {
            types = ' CloseDate <= :endDate and CloseDate >=:startDate and BookingType__c in (\'New\', \'Follow On\') and IsClosed=false and ForecastCategoryName!=\'Omitted\' ';
        }
        else if(typeOption == 'New')
        {
            types = ' CloseDate <= :endDate and CloseDate >=:startDate and BookingType__c=\'New\' and IsClosed=false and ForecastCategoryName!=\'Omitted\' ';
        }
        else if(typeOption == 'Follow On')
        {
            types = ' CloseDate <= :endDate and CloseDate >=:startDate and BookingType__c=\'Follow On\' and IsClosed=false and ForecastCategoryName!=\'Omitted\' ';
        }
        else if(typeOption == 'Dell')
        {   //Dell
            List<Account> acs = [select Id, Name from Account where name like '%Dell%'];
            Set<Id> dellAccounts = new Set<Id>();
            for(Account ac : acs)
            {
                if(Pattern.matches('(.*[\\W])?[Dd][Ee][Ll][Ll]([\\W].*)?', ac.Name))
                {
                    dellAccounts.add(ac.Id);
                }
            }
            types = 'CloseDate <= :endDate and CloseDate >=:startDate and ForecastCategoryName!=\'Omitted\' and Id in (select OpportunityId from Partner where AccountToId in :dellAccounts)';
        }
        else if(typeOption == 'Rolling 90 Days')
        {
            types = ' IsClosed=false and CloseDate>=TODAY and CloseDate<=NEXT_N_DAYS:90 and ForecastCategoryName!=\'Omitted\' ';
        }
        else if(typeOption == 'Rolling 180 Days')
        {
            types = ' IsClosed=false and CloseDate>=TODAY and CloseDate<=NEXT_N_DAYS:180 and ForecastCategoryName!=\'Omitted\' ';
        }
        else if(typeOption == 'Current Quarter')
        {
            types = ' IsClosed=false and CloseDate <= :endDate and CloseDate >=:startDate and ForecastCategoryName!=\'Omitted\' ';
        }
        else 
        {
            // default to 'All Open'
            types = ' IsClosed=false and ForecastCategoryName!=\'Omitted\' ';
        }
        
        List<Id> allUsers = ForecastingController.getAllSubordinateUsers(userId);
        allUsers.add(userId);
        Date startDate = ForecastingController.parseStartDate(fiscalQtr);
        Date endDate = ForecastingController.parseEndDate(fiscalQtr);
        String sql = 'select Id, BookingType__c, Type, Name, StageName, NextStep,Next_Step_Updated__c,Next_Step_Updated_By__c, Owner.Name, Primary_Partner__r.Name, Registered_Partner__r.Name, Technical_Responsible__c, Technical_Responsible__r.Name, PlanCheck__c, PowerCheck__c,  Vision_Match__c, Vision_Match_differentiated__c, ValueCheck__c, Registered_Partner__c, Probability, Primary_Partner__c, OwnerId, ForecastCategory,ForecastCategoryName, FiscalYear, ExpectedRevenue, CloseDate, Amount, Tier1_Partner__c, Tier1_Partner__r.Name, Tier2_Partner__c, Tier2_Partner__r.Name '
            + 'from Opportunity where Type != \'Marketplace\' and OwnerId in :allUsers'
            +' and '+ types +' '+limitAmount+' order by ' + sortField + ' '+ order;
        return new ApexPages.StandardSetcontroller(Database.getQueryLocator(sql));
    }
    
    //excludes the opportunities with only WANStart as physical product
    private static List<Opportunity> excludeWANStart(List<Opportunity> opps)
    {
        Set<Id> excludingOppIds = new Set<Id>();
        for(Opportunity opp : [select Id, (select Id, PricebookEntry.Product2.Name, TotalPrice from OpportunityLineItems limit 2) from Opportunity where Id in :opps])
        {
            if(opp.OpportunityLineItems.size() == 1)
            {
                for(OpportunityLineItem item : opp.OpportunityLineItems)
                {
                    if(item.PricebookEntry.Product2.Name.toLowerCase().contains('wanstart') && item.TotalPrice <= 0)
                    {
                        excludingOppIds.add(opp.Id);
                        break;
                    }
                }
            }
        }
        List<Opportunity> newResult = new List<Opportunity>();
        if(excludingOppIds.size() > 0)
        {
            for(Opportunity opp : opps)
            {
                if(!excludingOppIds.contains(opp.Id))
                {
                    newResult.add(opp);
                }
            }
            return newResult;
        }
        return opps;
    }
    
    public class ForecastingOppListRequest
    {
        public String userId { get; set; }
        public String fiscalQtr { get; set; }
        public String typeOption { get; set; }
        public Boolean isOver100K { get; set; }
        public String sortField { get; set; }
        public Boolean isAscendingOrder { get; set; }
        public Integer pageIndex { get; set; }
    }
    
    public class ForecastingOppListResponse
    {
        public ForecastingOppListResponse()
        {
            opportunities = new List<OpportunityEntry>();
        }
        
        public List<OpportunityEntry> opportunities { get; set; }
        public Boolean hasNext { get; set; }
        public Boolean hasPrevious { get; set; }
        public Integer pageIndex { get; set; }
        public Integer pageCount { get; set; }
        public Integer recordCount { get; set; }
    }
    
    public class OpportunityEntry
    {
        public OpportunityEntry(Opportunity opp)
        {
            this.oppId = opp.Id;
            this.oppName = opp.Name;
            this.amount = opp.Amount;
            this.stage = opp.StageName;
            this.probability = opp.Probability;
            this.closeDate = (opp.CloseDate == null) ? '' : formatDate(opp.CloseDate);
            this.forecastCategory = opp.ForecastCategoryName;
            this.type = opp.Type;
            this.visionMatch = opp.Vision_Match__c;
            this.visionMatchDifferentiated = opp.Vision_Match_differentiated__c;
            this.valueCheck = opp.ValueCheck__c;
            this.powerCheck = opp.PowerCheck__c;
            this.planCheck = opp.PlanCheck__c;
            this.primaryPartnerId = opp.Primary_Partner__c;
            this.primaryPartnerName = opp.Primary_Partner__r.Name;
            this.nextStep = opp.NextStep;
            this.ownerId = opp.OwnerId;
            this.ownerName = opp.Owner.Name;
            this.technicalResponsibleId = opp.Technical_Responsible__c;
            this.technicalResponsibleName = opp.Technical_Responsible__r.Name;
            this.tier1Id = opp.Tier1_Partner__c;
            this.tier1Name = opp.Tier1_Partner__r.Name;
            this.tier2Id = opp.Tier2_Partner__c;
            this.tier2Name = opp.Tier2_Partner__r.Name;
            this.nextStepReportingField =(opp.NextStep== null)?'':formatnextStepReportingField(opp.NextStep, opp.Next_Step_Updated_By__c,opp.Next_Step_Updated__c);
           
        }
        
        public String oppId { get; set; }
        public String oppName { get; set; }
        public Decimal amount { get; set; }
        public String stage { get; set; }
        public Decimal probability { get; set; }
        public String closeDate { get; set; }
        public String forecastCategory { get; set; }
        public String type { get; set; }
        public Boolean visionMatch { get; set; }
        public Boolean visionMatchDifferentiated { get; set; }
        public Boolean valueCheck { get; set; }
        public Boolean powerCheck { get; set; }
        public Boolean planCheck { get; set; }
        public String primaryPartnerId { get; set; }
        public String primaryPartnerName { get; set; }
        public String nextStep { get; set; }
        public String ownerId { get; set; }
        public String ownerName { get; set; }
        public String technicalResponsibleId { get; set; }
        public String technicalResponsibleName { get; set; }
        public String tier1Id { get; set; }
        public String tier1Name { get; set; }
        public String tier2Id { get; set; }
        public String tier2Name { get; set; }
        public String nextStepReportingField{get;set;}
        
        private String formatDate(Date d)
        {
            String month = (d.month() < 10) ? '0' + d.month() : '' + d.month();
            String day = (d.day() < 10) ? '0' + d.day() : '' + d.day();
            return month + '/' + day + '/' + d.year();
        }
        
        private String formatnextStepReportingField(string nextStep, string nextStepUpdatedBy,date nextUpdatedDate )
        {
           if(nextStepUpdatedBy==null && nextUpdatedDate==null )
               return nextStep;
            else
           return nextUpdatedDate.month()+'/'+nextUpdatedDate.day()+'/'+nextUpdatedDate.year() + '-'+ nextStepUpdatedBy + '-' + nextStep;
          
           
        }
    }
}