@isTest 
public class CopyEndDateToContractTriggerTest {
    @isTest
    public static void createTestSubscriptions() {
        //create account
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Partner';
        acc.Partner_Type__c = 'Reseller';
        acc.Reseller_Agreement__c = true;
        insert acc;
        
        //create contact
        Contact con = new Contact();
        con.LastName = 'Contact';
        con.Accountid = acc.Id;
        con.Email = 'test@example.com';
        con.Phone = '1234567891';
        insert con;
        
        //create opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Closed Won';
        opp.CloseDate = System.Today();
        opp.Finance_Reviewed__c = true;
        opp.Pricebook2id = '01s300000000cQG';
        opp.Accountid = acc.Id;
        
        insert opp;
        
        //create master contract
        Contract masterCon = new Contract();
        masterCon.SBQQ__MasterContract__c = true;
        masterCon.Accountid = acc.Id;
        insert masterCon;
        
        //create quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Opportunity2__c = opp.Id;
        testQuote.SBQQ__PrimaryContact__c = con.Id;
        testQuote.Prepared_For__c = con.Id;
        testQuote.Reseller_Partner__c = acc.Id;
        insert testQuote;
        
        //create subsciption
        SBQQ__Subscription__c subs = new SBQQ__Subscription__c();
        subs.SBQQ__Contract__c = masterCon.Id;
        subs.SBQQ__Quantity__c = 1;
        insert subs;
    
    }
}