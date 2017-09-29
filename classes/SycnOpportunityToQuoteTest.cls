@isTest
public class SycnOpportunityToQuoteTest {    
   //@isTest
    static void testUpdateOpportunity()
    {
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Test', CloseDate = Date.today().addDays(10), ForecastCategoryName = 'Best Case');
        insert opp;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c( SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = true, SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id);
        insert quote1;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c( SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = false, SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id);
        insert quote2;
        
        opp.Contract_Activation_Date__c = Date.today();
        update opp;
        
        /*
        System.assertEquals(Date.today(), [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote1.Id].SBQQ__StartDate__c);
        System.assertEquals(null, [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote2.Id].SBQQ__StartDate__c);
        
        opp.Contract_Activation_Date__c = null;
        update opp;
        System.assertEquals(Date.today().addDays(10), [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote1.Id].SBQQ__StartDate__c);
        System.assertEquals(null, [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote2.Id].SBQQ__StartDate__c);
        */
    }
}