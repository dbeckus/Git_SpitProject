public without sharing class PartnerPortalDealSearchController
{
    public User CurrentUser     { get; private set; }
    public Boolean IsManager    { get; private set; }

    public Deals Leads  { get; private set; }
    public Deals PendingDeals           { get; private set; }
    public Deals ApprovedOpportunities  { get; private set; }

    public PartnerPortalDealSearchController()
    {
        CurrentUser = [select Id, ContactId, Contact.AccountId, UserRole.Name from User where Id = :UserInfo.getUserId() limit 1];
        IsManager = CurrentUser.UserRole.Name.endsWith('Manager') || CurrentUser.UserRole.Name.endsWith('Executive');
        
        Leads = new Deals();
        Leads.ObjectName = 'Lead';
        Leads.SOQLFields = 'Id, Name, Company, Status, Rating, Deal_Source__c, CreatedDate, LastModifiedDate, Date_Passed_to_Partner__c';
        Leads.FilterField = 'CreatedDate';
        Leads.FilterValue = 'THIS_QUARTER';
        Leads.SortField = 'CreatedDate desc';
        Leads.PageSize = 50;
        
        PendingDeals = new Deals();
        PendingDeals.ObjectName = 'Lead';
        PendingDeals.SOQLFields = 'Id, Name, Company, Status, Rating, Deal_Source__c, CreatedDate, LastModifiedDate, Date_Passed_to_Partner__c';
        PendingDeals.FilterField = 'CreatedDate';
        PendingDeals.FilterValue = 'THIS_QUARTER';
        PendingDeals.SortField = 'CreatedDate desc';
        PendingDeals.PageSize = 50;
        
        ApprovedOpportunities = new Deals();
        ApprovedOpportunities.ObjectName = 'Opportunity';
        ApprovedOpportunities.SOQLFields = 'Id, Name, Account.Name, StageName, CreatedDate, LastModifiedDate';
        ApprovedOpportunities.FilterField = 'CreatedDate';
        ApprovedOpportunities.FilterValue = 'THIS_QUARTER';
        ApprovedOpportunities.SortField = 'CreatedDate desc';
        ApprovedOpportunities.PageSize = 50;
        
        if(IsManager)
        {
            Leads.SOQLCriteria = 'IsConverted=false and (Registered_Distributor__c = \'' + CurrentUser.Contact.AccountId + '\' or Registered_Partner__c = \'' + CurrentUser.Contact.AccountId + '\')';
            PendingDeals.SOQLCriteria = 'IsConverted=false and RecordType.Name=\'Deal Registration\' and (Registered_Distributor__c = \'' + CurrentUser.Contact.AccountId + '\' or Registered_Partner__c = \'' + CurrentUser.Contact.AccountId + '\')';
            ApprovedOpportunities.SOQLCriteria = '(Registered_Distributor__c = \'' + CurrentUser.Contact.AccountId + '\' or Registering_Partner__c = \'' + CurrentUser.Contact.AccountId + '\')';
        }
        else
        {
            Leads.SOQLCriteria = 'IsConverted=false and (Registered_Distributor_Contact__c = \'' + CurrentUser.ContactId + '\' or Registered_Partner_Sales_Rep__c=\'' + CurrentUser.ContactId + '\')';
            PendingDeals.SOQLCriteria = 'IsConverted=false and RecordType.Name=\'Deal Registration\' and (Registered_Distributor_Contact__c = \'' + CurrentUser.ContactId + '\' or Registered_Partner_Sales_Rep__c=\'' + CurrentUser.ContactId + '\')';
            ApprovedOpportunities.SOQLCriteria = '(Registered_Distributor_Contact__c = \'' + CurrentUser.ContactId + '\' or Registering_Partner_Sales_Rep__c=\'' + CurrentUser.ContactId + '\')';
        }
    }

    public PageReference partnerPortalSearchLeadsInit()
    {
        try
        {
            Leads.search();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to query. Please try again.'));
        }
        return null;
    }

    public PageReference partnerPortalSearchDealsInit()
    {
        try
        {
            PendingDeals.search();
            ApprovedOpportunities.search();
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to query. Please try again.'));
        }
        return null;
    }

    public class Deals
    {
        public List<SObject> Records { get; private set; }

        public String ObjectName    { get; set; }
        public String SOQLFields    { get; set; }
        public String SOQLCriteria  { get; set; }

        public String Keyword       { get; set; }
        public String FilterField   { get; set; }
        public String FilterValue   { get; set; }
        public String SortField     { get; set; }

        public Integer PageNO       { get; private set; }
        public Integer PageSize     { get; private set; }
        public Integer PageIndex    { get { return PageNO * PageSize; } }
        public Boolean IsFirstPage  { get { return PageNO == 0; } }
        public Boolean IsLastPage   { get { return PageNO == ((Records == null) ? 0 : Records.size()) / PageSize; } }

        public Deals() {
            PageNO = 0;
        }

        public PageReference search()
        {
            PageNO = 0;
            try
            {
                if(FilterField == 'Registered_Partner_Sales_Rep__c' || FilterField == 'Registering_Partner_Sales_Rep__c')
                {
                    FilterValue = 'null';
                }
                if(String.isNotBlank(Keyword) && Keyword.length() >= 2)
                {
                    String sosl = String.format('find :keyword returning {0}({1} where {2} order by {3} limit 1000)', new String[] { ObjectName, SOQLFields, getCriteria(), SortField});
                    Records = Search.query(sosl)[0];
                }
                else
                {
                    String soql = String.format('select {1} from {0} where {2} order by {3} limit 1000', new String[] { ObjectName, SOQLFields, getCriteria(), SortField});
                    Records = Database.query(soql);
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error occured while searching. Please retry.'));
                ApexPages.addMessages(ex);
            }
            return null;
        }

        public PageReference prev()
        {
            if(!IsFirstPage)
            {
                PageNO--;
            }
            return null;
        }

        public PageReference next()
        {
            if(!IsLastPage)
            {
                PageNO++;
            }
            return null;
        }
        
        private String getCriteria()
        {
            String result = '';
            if(String.isNotBlank(SOQLCriteria))
            {
                result = SOQLCriteria + ' and ';
            }
            result += FilterField + '=' + FilterValue;
            System.debug('***' + FilterValue);
            return result;
        }
    }
}