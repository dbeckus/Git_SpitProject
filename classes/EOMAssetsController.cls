/*
 * This controller is referenced by EOMAssets Component.
 */
public class EOMAssetsController
{
    public String ContractId { get; set; } 
    public String AccountId { get; set; }     
      
    public List<Asset> getEOMAssets()
    {
        List<Date> expiredDates = new List<Date>{ Date.today().addMonths(1), Date.today().addMonths(3), Date.today().addMonths(6), Date.today().addYears(1), Date.today().addMonths(18) };
        return [SELECT Id, Ship_Date__c, SerialNumber, Model__c, Contract_End__c, End_of_Maintenance__c FROM Asset WHERE Contract_Number__r.Account.Id = :AccountId AND Contract_Number__r.Status = 'Activated' AND End_of_Maintenance__c IN :expiredDates ORDER BY End_of_Maintenance__c];
    }
    
    @isTest
    static void test()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName = 'acme', AccountId = testAccount.Id);
        insert testContact;
        Contract newContract = new Contract(AccountId = testAccount.Id, SP_Contract_Number__c = 'acme');
        insert newContract;
        EOMAssetsController controller = new EOMAssetsController();
        controller.ContractId = newContract.Id;
        List<Asset> assets = controller.getEOMAssets();
    }
}