/*
 * Controller of the component ExpiringContractList
 */
public class ExpiringContractListController 
{
    public ExpiringContractListController()
    {
    }
    
    public Id AccountId { get; set; }
    
    public List<Contract> Contracts
    {
        get
        {
            if(AccountId != null)
            {
                return [select Id, ContractNumber, Account.Name, CustomerSigned.Name, CustomerSigned.Email, Status, EndDate, (select Name, Model__c from Assets1__r) from Contract where (Status in ('Activated', 'Expired') or Trigger_Notice__c!=null) and AccountId=:AccountId and Include_For_Notice__c=1 order by EndDate];
            }
            else
            {
                return new List<Contract>();
            }
        }
    }
    
    @isTest
    static void testExpiringContractListController()
    {
        ExpiringContractListController controller = new ExpiringContractListController();
        List<Contract> contracts = controller.Contracts;
    }
}