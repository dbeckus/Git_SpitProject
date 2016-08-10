/*
 * gets a list of opportunities in the account hierarchy
 */
public with sharing class EnterpriseOpportunityListController 
{
    private Account account;
    
    public EnterpriseOpportunityListController(ApexPages.StandardController controller) 
    {
        account = (Account)controller.getRecord();
        List<Account> allAccounts = new List<Account>();
        allAccounts.add(account);
        allAccounts.addAll(getSubordinates(new List<Account> { account }));
        AllOpportunities = [select Id, Name, AccountId, Account.Name, StageName, Amount, CloseDate, OwnerId, Owner.Name, Type, IsClosed, IsWon from Opportunity where AccountId in :allAccounts];
    }

    public List<Opportunity> AllOpportunities { get; set; }
    
    public Decimal EnterpriseCumulativeBookings
    {
        get
        {
            Decimal result = 0;
            for(Opportunity opp : AllOpportunities)
            {
                if(opp.IsClosed == true && opp.IsWon == true)
                {
                    result += opp.Amount;
                }
            }
            return result;
        }
    }
    
    private List<Account> getSubordinates(List<Account> accounts)
    {
        List<Account> result = new List<Account>();
        List<Account> directSubordinates = [select Id from Account where ParentId in :accounts];
        if(directSubordinates.size() > 0)
        {
            result.addAll(directSubordinates);
            result.addAll(getSubordinates(directSubordinates));
        }
        return result;
    }
    
    @isTest
    static void testEnterpriseOpportunityListController()
    {
        Account account = new Account(Name='acme');
        insert account;
        Account subAccount = new Account(Name='acme', ParentId=account.Id);
        insert subAccount;
        Opportunity opp = new Opportunity(Name='acme', StageName='Open', CloseDate=Date.today(), AccountId=account.Id, ForecastCategoryName='Best Case');
        insert opp;
        Opportunity opp2 = new Opportunity(Name='acme', StageName='Open', CloseDate=Date.today(), AccountId=subAccount.Id, ForecastCategoryName='Best Case');
        insert opp2;
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(account);
        EnterpriseOpportunityListController controller = new EnterpriseOpportunityListController(ctrl);
        System.assertEquals(2, controller.AllOpportunities.size());
        System.assertEquals(0, controller.EnterpriseCumulativeBookings);
    }
}