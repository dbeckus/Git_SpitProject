@IsTest
public class TestOpportunityQueryAction {
    
    @isTest(SeeAllData=true)
    public static void CalculateECSPAmounts()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline',Finance_Reviewed__c=true);
        insert testOpp;
        Product2 testsfProduct = new Product2(Name='EC-SP-BASE', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true,Product_Type__c='EC-SP',isQuotable__c=true);
        insert testsfProduct;
        Product2 testhdProduct = new Product2(Name='EC-L-SP', Forecast_Category__c = 'Product', Family='Product', IsActive=true,Product_Type__c='EC-SP',isQuotable__c=true);
        insert testhdProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
       	Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry entry1= new PricebookEntry(pricebook2id = stdPb.id, product2id = testsfProduct.id, unitprice=1.0, isActive=true);
        insert entry1;
        PricebookEntry entry2= new PricebookEntry(pricebook2id = stdPb.id, product2id = testhdProduct.id, unitprice=2.0, isActive=true);
        insert entry2;
      
        OpportunityLineItem lineItem1= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry1.id,Quantity=1,UnitPrice=2000);
        insert lineItem1;
        OpportunityLineItem lineItem2= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry2.id,Quantity=1,UnitPrice=2000);
        insert lineItem2;
        testOpp.StageName='Closed Won';
        update testOpp;
        Test.stopTest();
    }

}