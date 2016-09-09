@isTest
public class UpdateMasterContractTest {
    
    @isTest
    static void testInsertQuote()
    {
        Account acc = new Account(Name = 'Test', Type='Partner', Partner_Type__c='Reseller');
        insert acc;
        
        Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Test', AccountId=acc.Id, CloseDate = Date.today().addDays(10), ForecastCategoryName = 'Best Case');
        insert opp;
        
        Contact con = new Contact(LastName = 'Test', AccountId=acc.Id);
        insert con;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=acc.Id, SBQQ__Type__c = 'co-term', Product_Type__c = 'EdgeConnect', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id, Reseller_Partner__c=acc.Id, Distributor_Partner__c=acc.Id);
        insert quote;
        
        Contract contract = new Contract(AccountId = acc.Id, SBQQ__Opportunity__c = opp.Id, Contract_Type__c = 'EdgeConnect', EndDate = Date.today().addDays(10), SBQQ__MasterContract__c = true, SBQQ__Quote__c = quote.Id);
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        SBQQ__Quote__c insertQuote = new SBQQ__Quote__c(SBQQ__Account__c=acc.Id, SBQQ__Opportunity2__c = opp.Id, SBQQ__Type__c = 'co-term', Product_Type__c = 'EdgeConnect', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id, Reseller_Partner__c=acc.Id, Distributor_Partner__c=acc.Id );
        insert insertQuote;
        
        quote = [select Id, SBQQ__MasterContract__c from SBQQ__Quote__c where Id = :insertQuote.Id];
        System.assert(String.isNotEmpty(quote.SBQQ__MasterContract__c));
        System.assertEquals(contract.Id, quote.SBQQ__MasterContract__c);
    }
    
    @isTest
    static void testUpdateQuote()
    {
        Test.startTest();
        Account acc = new Account(Name = 'Test', Type='Partner', Partner_Type__c='Reseller');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId=acc.Id);
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'Test', AccountId=acc.Id, StageName = 'Test', CloseDate = Date.today().addDays(10), ForecastCategoryName = 'Best Case');
        insert opp;
        
        Contract contract = new Contract( AccountId = acc.Id, SBQQ__Opportunity__c = opp.Id, Contract_Type__c = 'EdgeConnect', EndDate = Date.today().addDays(10), SBQQ__MasterContract__c = true);
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=acc.Id, SBQQ__Type__c = 'co-term', Product_Type__c = 'EdgeConnect', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id, Reseller_Partner__c=acc.Id, Distributor_Partner__c=acc.Id );
        insert quote;
        
        quote = [select Id, SBQQ__MasterContract__c, SBQQ__Account__c from SBQQ__Quote__c where Id = :quote.Id];
        System.assert(String.isEmpty(quote.SBQQ__MasterContract__c));
        
        Test.stopTest();
        
        contract.SBQQ__Quote__c = quote.Id;
        update contract;
        
        quote.SBQQ__Opportunity2__c = opp.Id;
        update quote;
        
        
        quote = [select Id, SBQQ__MasterContract__c, SBQQ__Account__c from SBQQ__Quote__c where Id = :quote.Id];
        System.assert(String.isNotEmpty(quote.SBQQ__MasterContract__c));
        System.assertEquals(contract.Id, quote.SBQQ__MasterContract__c);
    }
    
    @isTest
    static void testUpdateQuote2()
    {
        Test.startTest();
        
        Account acc = new Account(Name = 'Test', Type='Partner', Partner_Type__c='Reseller');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId=acc.Id);
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'Test', AccountId=acc.Id, StageName = 'Test', CloseDate = Date.today().addDays(10), ForecastCategoryName = 'Best Case');
        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c=acc.Id, SBQQ__Type__c = 'co-term', Product_Type__c = 'EdgeConnect', SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id, Reseller_Partner__c=acc.Id, Distributor_Partner__c=acc.Id );
        insert quote;
        
        quote = [select Id, SBQQ__MasterContract__c, SBQQ__Account__c from SBQQ__Quote__c where Id = :quote.Id];
        System.assert(String.isEmpty(quote.SBQQ__MasterContract__c));
        
        Contract contract1 = new Contract(SBQQ__Quote__c = quote.Id, AccountId = acc.Id, SBQQ__Opportunity__c = opp.Id, Contract_Type__c = 'EdgeConnect', EndDate = Date.today().addDays(10), SBQQ__MasterContract__c = true);
        insert contract1;
        
        contract1.Status = 'Activated';
        update contract1;
        
        Test.stopTest();
        
        Contract contract2 = new Contract(SBQQ__Quote__c = quote.Id, AccountId = acc.Id, SBQQ__Opportunity__c = opp.Id, Contract_Type__c = 'EdgeConnect', EndDate = Date.today().addDays(10), SBQQ__MasterContract__c = false);
        insert contract2;
        
        contract2.Status = 'Activated';
        update contract2;
        
        quote.SBQQ__Opportunity2__c = opp.Id;
        update quote;
        
        
        quote = [select Id, SBQQ__MasterContract__c, SBQQ__Account__c from SBQQ__Quote__c where Id = :quote.Id];
        //System.assert(String.isEmpty(quote.SBQQ__MasterContract__c));
    }
}