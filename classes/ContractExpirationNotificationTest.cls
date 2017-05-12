@isTest
public class ContractExpirationNotificationTest
{
	@isTest
    static void testContractExpirationNotification()
    {
        Account acc = new Account(Name='acme');
        insert acc;
         Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact c = new Contact(LastName='acme', Email='test@test.com', AccountId=acc.Id);
        insert c;
        Contract ct0 = new Contract(Name='acme', SP_Contract_Number__c='acme', AccountId=acc.Id, CustomerSignedId=c.Id, Status='Draft', StartDate=Date.today(), EndDate=Date.today(), Contract_Type__c='Gold');
        insert ct0;
        Contract ct60 = new Contract(Name='acme', SP_Contract_Number__c='acme2', AccountId=acc.Id, CustomerSignedId=c.Id, Status='Draft', StartDate=Date.today(), EndDate=Date.today().addDays(60), Contract_Type__c='Gold');
        insert ct60;
        Contract ct90 = new Contract(Name='acme', SP_Contract_Number__c='acme3', AccountId=acc.Id, CustomerSignedId=c.Id, Status='Draft', StartDate=Date.today(), EndDate=Date.today().addDays(90), Contract_Type__c='Gold');
        insert ct90;
        Contract ct1 = new Contract(Name='acme', SP_Contract_Number__c='acme4', AccountId=acc.Id, CustomerSignedId=c.Id, Status='Draft', StartDate=Date.today(), EndDate=Date.today().addDays(-1), Contract_Type__c='Gold');
        insert ct1;
        Asset asset = new Asset(Name='acme', AccountId=acc.Id, Contract_Number__c=ct0.Id, Status='Customer Owned');
        insert asset;
        ct0.Status = ct60.Status = ct90.Status = ct1.Status = 'Activated';
        update new List<Contract> { ct0, ct60, ct90, ct1 };
        
        List<Contract> contracts = [select AccountId from Contract where Status='Activated' and EndDate in (:Date.today().addDays(-1), :Date.today(), :Date.today().addDays(60), :Date.today().addDays(90)) and Include_For_Notice__c=1];
        System.assertEquals(4, contracts.size());
        
        ContractExpirationNotification notification = new ContractExpirationNotification();
        SchedulableContext sc = null;
        notification.execute(sc);
        
        Test.StartTest();
        Database.executeBatch(notification, 10); 
        Test.StopTest();
    }
}