/**
*  The test class for QuoteExtension.
*/

@isTest
public class QuoteExtensionTest
{
    @isTest(seeAllData=true)
    static void testQuoteExtension()
    {
        Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription', isActive = true, IsQuotable__c = true);
        insert product;
        Pricebook2 standardPricebook = [select Id from Pricebook2 where IsStandard = true limit 1];
        insert new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
        Pricebook2 newPricebook = new Pricebook2(name = 'Test Pricebook');
        insert newPricebook;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = newPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
        insert pricebookEntry;
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', Pricebook2Id = newPricebook.Id, StageName = 'Discovery', CloseDate = Date.today().addDays(1));
        insert opportunity;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId = opportunity.id, PricebookEntryId = pricebookEntry.id, UnitPrice = 1.5, Quantity = 2);
        insert opportunityLineItem;
        Quote__c quote1 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert quote1; 
        Quote__c quote2 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(), Primary__c = true);
        insert quote2;
        
        QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
        
        System.assertEquals(true, QuoteExtension.CheckQuote(quote1.Id, opportunity.Id));
        
        QuoteExtension.SetPrimaryQuoteAndSubmit(quote1.Id, opportunity.Id);
        quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
        quote2 = [select Primary__c from Quote__c where Id = :quote2.Id];
        System.assertEquals(true, quote1.Primary__c);
        System.assertEquals(false, quote2.Primary__c);
    }
    
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_DiscountJustification()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',Region__c='West',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        System.runAs(usr)
        {
            Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription', isActive = true, IsQuotable__c = true);
            insert product;
            Pricebook2 standardPricebook = [select Id from Pricebook2 where IsStandard = true limit 1];
            insert new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
            Pricebook2 newPricebook = new Pricebook2(name = 'Test Pricebook');
            insert newPricebook;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = newPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
            insert pricebookEntry;
            
            Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', Sales_Region__c='APAC',Pricebook2Id = newPricebook.Id, StageName = 'Discovery', CloseDate = Date.today().addDays(1));
            insert opportunity;
        
            OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId = opportunity.id, PricebookEntryId = pricebookEntry.id, UnitPrice = 1.5, Quantity = 2);
            insert opportunityLineItem;
            Quote__c quote1 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
            insert quote1; 
            Quote__c quote2 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(), Primary__c = true);
            insert quote2;
            QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
            
            System.assertEquals(true, QuoteExtension.CheckQuote(quote1.Id, opportunity.Id));
            
            QuoteExtension.SetPrimaryQuoteAndSubmit(quote1.Id, opportunity.Id);
            quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
            
            System.assertEquals('Discount Justification is empty. Please provide comments.',QuoteExtension.SubmitForApproval(quote1.Id));
       }
        
        
        
    }
    
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_ApprovalSubmit()
    {
        Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription', isActive = true, IsQuotable__c = true);
        insert product;
        Pricebook2 standardPricebook = [select Id from Pricebook2 where IsStandard = true limit 1];
        insert new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
        Pricebook2 newPricebook = new Pricebook2(name = 'Test Pricebook');
        insert newPricebook;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = newPricebook.Id, Product2Id = product.Id, UnitPrice = 1.0, IsActive = true);
        insert pricebookEntry;
        
        
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity', Pricebook2Id = newPricebook.Id, StageName = 'Discovery', CloseDate = Date.today().addDays(1));
        insert opportunity;
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem(OpportunityId = opportunity.id, PricebookEntryId = pricebookEntry.id, UnitPrice = 1.5, Quantity = 2);
        insert opportunityLineItem;
        Quote__c quote1 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(),Discount_Justification__c='test Data');
        insert quote1; 
        Quote__c quote2 = new Quote__c(Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(), Primary__c = true);
        insert quote2;
        Quote_Line__c quoteLine= new Quote_Line__c(Quote__c=quote1.Id,Discount_Percent__c=46,Quantity__c=10,Product__c=product.Id);
        insert quoteLine;
        
        QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
        
        
        System.assertEquals(true, QuoteExtension.CheckQuote(quote1.Id, opportunity.Id));
        
        QuoteExtension.SetPrimaryQuoteAndSubmit(quote1.Id, opportunity.Id);
        quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
        QuoteExtension.SubmitForApproval(quote1.Id);
        
    }
    
    
    
}