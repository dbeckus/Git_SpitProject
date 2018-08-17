/*
 * Controller of PatchAssignments
 */
public class PatchAssignmentsController 
{
    private List<CatchallInfo> catchalls;
    private transient List<LeadInfo> leads;
    private Integer pageSize;
    private List<String> pageNumbers;
    private List<Id> subordinateUsers;
    public static Set<String> marketingStatuses = new Set<String> { 'Marketing Nurturing', 'Sales Rejected', 'Rejected', 'Marketing Qualifiying', 'Rejected - Not Interested', 'Rejected - Wrong Role', 'Rejected - Unresponsive/Check Back', 'Rejected - Do Not Contact', 'Rejected -Reseller Partner' };
    public static Set<String> salesStatuses;
    public static Set<String> qualifiedStatuses = new Set<String> { 'Marketing Qualified' };
    public static Set<String> untouchedStatuses = new Set<String> { 'ISR Qualified','Marketing Qualified' };
    public static Set<String> inProgressStatuses = new Set<String> { 'Sales Accepted - Contacting','Sales Accepted - Qualifying','Sales Accepted - Passed to Partner','Partner Accepted','Sales Accepted - Deferred','RSM Accepted' };
    public static Set<String> overdueStatuses = new Set<String> { 'Sales Accepted - Contacting','Sales Accepted - Qualifying','Sales Accepted - Passed to Partner','Partner Accepted','Sales Accepted - Deferred' };
    public static Set<String> deferredStatuses = new Set<String> { 'Sales Accepted - Deferred' };
    
    public PatchAssignmentsController()
    {
        UserId = initDefaultValue('uid', UserInfo.getUserId());
        Catchall = initDefaultValue('catchall', null);
        Bucket = initDefaultValue('bucket', 'Sales');
        Keyword = initDefaultValue('keyword', '');
        salesStatuses = getLeadStatuses();
        salesStatuses.removeAll(marketingStatuses);
        OrderBy = initDefaultValue('orderby', 'Last_Campaign_Response_Date__c DESC');
        pageSize = 250;
        try 
        {
            PageIndex = Integer.valueOf(initDefaultValue('p', '0'));
        } catch(Exception ex) {}
        List<User> users = [select Id, Name from user where Id=:UserId limit 1];
        if(users.size() > 0)
        {
            Username = users[0].Name;
        }
        subordinateUsers = ForecastingController.getAllSubordinateUsers(UserId);
        subordinateUsers.add(UserId);
    }
    
    public String UserId { get; set; }
    public String Username { get; set; }
    public String Catchall { get; set; }
    public String Bucket { get; set; }
    public String Keyword { get; set; }
    public String OrderBy { get; set; }
    public Integer PageIndex { get; set; }

    public List<String> PageNumberList
    {
        get
        {
            if(pageNumbers == null)
            {
                List<LeadInfo> temp = this.LeadList; //populates the pageNumbers variable
            }
            return pageNumbers;
        }
    }
    
    public List<CatchallInfo> CatchallList
    {
        get
        {
            if(catchalls == null)
            {
                catchalls = new List<CatchallInfo>();
                for(Patch__c patch : [select Id, Patch_Name__c from Patch__c where Catchall__c = true and Active__c=true order by ProcessingSequence__c])
                {
                    catchalls.add(new CatchallInfo(patch.Id, patch.Patch_Name__c));
                }
            }
            return catchalls;
        }
    }
    
    public List<LeadInfo> LeadList
    {
        get
        {
            if(leads == null)
            {
                leads = new List<LeadInfo>();
                pageNumbers = new List<String>();
                List<Lead> searchResult = new List<Lead>();
                if(String.isNotBlank(Keyword) && Keyword.length() >= 2)
                {
                    String sosl = constructSOSL();
                    searchResult = Search.query(sosl)[0];
                    
                }
                else
                {
                    String soql = constructSOQL();
                    searchResult = Database.query(soql);
                }
                Integer pageCount = Math.ceil(searchResult.size() * 1.0 / pageSize).intValue();
                for(Integer p = 1; p < pageCount + 1; p++)
                {
                    pageNumbers.add(String.valueOf(p));
                }
                if(pageNumbers.size() == 1)
                {
                    pageNumbers.remove(0);
                }
                for(Integer i = PageIndex * pageSize; i < (PageIndex + 1) * pageSize && i < searchResult.size(); i++)
                {
                    leads.add(new LeadInfo(searchResult[i]));
                }
            }
            return leads;
        }
    }
    
    @testvisible
    private Set<String> getLeadStatuses()
    {
        Schema.DescribeFieldResult leadStatusDescription = Lead.Status.getDescribe();
        List<Schema.PicklistEntry> items = leadStatusDescription.getPicklistValues();
        Set<String> result = new Set<String>();
        for(Schema.PicklistEntry item : items)
        {
            if(item.isActive())
            {
                result.add(item.getLabel());
            }
        }
        return result;
    }
    
    private String constructSOSL()
    {
        String sosl = 'find :Keyword returning Lead(Id, Name, Email, Company, Country, State, Phone, OwnerId, Status, Owner.Name, Last_Campaign_Response_Date__c, Last_Mkt_Campaign_Id__c, Last_Mkt_Campaign_Id__r.Name, Matched_Account__c, Matched_Account__r.Name, Last_Status_Change__c, mkto2__Lead_Score__c where ';
        if(String.isBlank(Catchall))
        {
            sosl += '(CSM__c in :subordinateUsers or ISR__c in :subordinateUsers or RSM__c in :subordinateUsers or SE__c in :subordinateUsers) ';
        }
        else
        {
            sosl += 'Patch__c=:Catchall ';
        }
        if(Bucket == 'Marketing')
        {
            sosl += 'and Status in :marketingStatuses ';
        }
        else if(Bucket == 'Sales')
        {
            sosl += 'and Status in :salesStatuses ';
        }
        else if(Bucket == 'Being Qualified')
        {
            sosl += 'and Status in :qualifiedStatuses ';
        }
        else if(Bucket == 'Qualified - Untouched')
        {
            sosl += 'and Status in :untouchedStatuses and Screening_Results__c in :untouchedStatuses ';
        }
        else if(Bucket == 'Qualified - In Progress')
        {
            sosl += 'and Screening_Results__c in :untouchedStatuses and Status in :inProgressStatuses ';
        }
        else if(Bucket == 'Qualified - Overdue')
        {
            sosl += 'and Screening_Results__c=\'ISR Qualified\' and Status in :overdueStatuses and DaysSinceLastStatusUpdate__c>=14 ';
        }
        else if(Bucket == 'Deferred')
        {
            sosl += 'and Status in :deferredStatuses ';
        }
        sosl += 'order by ' + OrderBy + ' nulls last limit 2000)';
        return sosl;
    }
    
    private String constructSOQL()
    {
        String soql = 'select Id, Name, Email, Company, Country, State, Phone, OwnerId, Status, Owner.Name, Last_Campaign_Response_Date__c, Last_Mkt_Campaign_Id__c, Last_Mkt_Campaign_Id__r.Name, Matched_Account__c, Matched_Account__r.Name, Last_Status_Change__c, mkto2__Lead_Score__c from Lead where ';
        if(String.isBlank(Catchall))
        {
            soql += '(CSM__c in :subordinateUsers or ISR__c in :subordinateUsers or RSM__c in :subordinateUsers or SE__c in :subordinateUsers) ';
        }
        else
        {
            soql += 'Patch__c=:Catchall ';
        }
        if(Bucket == 'Marketing')
        {
            soql += 'and Status in :marketingStatuses ';
        }
        else if(Bucket == 'Sales')
        {
            soql += 'and Status in :salesStatuses ';
        }
        else if(Bucket == 'Being Qualified')
        {
            soql += 'and Status in :qualifiedStatuses ';
        }
        else if(Bucket == 'Qualified - Untouched')
        {
            soql += 'and Status in :untouchedStatuses and Screening_Results__c in :untouchedStatuses ';
        }
        else if(Bucket == 'Qualified - In Progress')
        {
            soql += 'and Screening_Results__c in :untouchedStatuses and Status in :inProgressStatuses ';
        }
        else if(Bucket == 'Qualified - Overdue')
        {
            soql += 'and Screening_Results__c=\'ISR Qualified\' and Status in :overdueStatuses and DaysSinceLastStatusUpdate__c>=14 ';
        }
        else if(Bucket == 'Deferred')
        {
            soql += 'and Status in :deferredStatuses ';
        }
        soql += 'order by ' + OrderBy + ' nulls last limit 2000';
        return soql;
    }
    
    private String initDefaultValue(String param, String defaultValue)
    {
        String paramValue = ApexPages.currentPage().getParameters().get(param);
        if(String.isBlank(paramValue))
        {
            return defaultValue;
        }
        else
        {
            return paramValue;
        }
    }
    
    public class CatchallInfo
    {
        public CatchallInfo(Id catchallId, String catchallName)
        {
            this.cid = catchallId;
            this.name = catchallName;
        }
        
        public Id cid { get; set; }
        public String name { get; set; }
    }
    
    public class LeadInfo
    {
        public LeadInfo(Lead l)
        {
            this.LeadId = l.Id;
            this.Name = l.Name;
            this.Email = l.Email;
            this.Company = l.Company;
            this.Country = l.Country;
            this.State = l.State;
            this.Status = l.Status;
            this.OwnerId = l.OwnerId;
            this.OwnerName = l.Owner.Name;
            this.Phone = l.Phone;
            this.LastCampaignResponse = l.Last_Campaign_Response_Date__c;
            this.LastMktCampaignId = l.Last_Mkt_Campaign_Id__c;
            this.LastMktCampaignName = l.Last_Mkt_Campaign_Id__r.Name;
            this.MatchedAccountId = l.Matched_Account__c;
            this.MatchedAccountName = l.Matched_Account__r.Name;
            this.LastStatusChange = l.Last_Status_Change__c;
            this.LeadScore = (l.mkto2__Lead_Score__c == null) ? null : l.mkto2__Lead_Score__c.intValue();
        }
        public Id LeadId { get; set; }
        public String Name { get; set; }
        public String Email { get; set; }
        public String Company { get; set; }
        public String Country { get; set; }
        public String State { get; set; }
        public String Status { get; set; }
        public String OwnerId { get; set; }
        public String OwnerName { get; set; }
        public String Phone { get; set; }
        public Date LastCampaignResponse { get; set; }
        public String LastMktCampaignId { get; set; }
        public String LastMktCampaignName { get; set; }
        public String MatchedAccountId { get; set; }
        public String MatchedAccountName { get; set; }
        public Date LastStatusChange { get; set; }
        public Integer LeadScore { get; set; }
    }
}