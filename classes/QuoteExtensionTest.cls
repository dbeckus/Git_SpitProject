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
        Pricebook2 newPricebook =[select Id from Pricebook2 where Name='Enterprise' limit 1];
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
        
        Test.startTest();
        QuoteExtension.SetPrimaryQuoteAndSubmit(quote1.Id, opportunity.Id);
        Test.stopTest();
        quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
        quote2 = [select Primary__c from Quote__c where Id = :quote2.Id];
        System.assertEquals(true, quote1.Primary__c);
        System.assertEquals(false, quote2.Primary__c);
    }
    
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_DiscountJustification()
    {
        Account testAccount= new Account(Name='Test Account');
        insert testAccount;
        Account reseller= new Account(Name='Test Reseller',Reseller_Agreement__c=true,CreditHold__c =true,Type='Partner',Partner_Type__c='Reseller');
        insert reseller;
              Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription',Product_Type__c='EDGECONNECT', isActive = true, IsQuotable__c = true);
            insert product;
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',Sales_Region__c='APAC', StageName = 'Discovery', CloseDate = Date.today().addDays(1));
        insert opportunity;
        opportunity.Sales_Region__c='APAC';
        update opportunity;
        Quote__c quote1 = new Quote__c(Tier_1_Partner__c=reseller.Id,Quote_Name__c='Test',Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert quote1; 
        System.debug('Approval required'+ quote1.Approval_Required__c);
        Quote_Line__c quoteLine= new Quote_Line__c(Quote__c=quote1.Id,Discount_Percent__c=99,Quantity__c=10,Product__c=product.Id);
        insert quoteLine;
        
        QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
        string outputTest=QuoteExtension.SubmitForApproval(quote1.Id);
        System.debug('outputTest'+outputTest);
        System.assert(outputTest.contains('Discount Justification is empty. Please provide comments.'));
       
    }
    
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_SpecialInstructions()
    {
        Account testAccount= new Account(Name='Test Account');
        insert testAccount;
        Account reseller= new Account(Name='Test Reseller',Type='Partner',Partner_Type__c='Reseller');
        insert reseller;
        Account distributor= new Account(Name='Test Distributor',Type='Partner',Partner_Type__c='Distributor',Reseller_Agreement__c=true);
        insert distributor;
        //create opportunity and opportunity line item.
  
        try
        {
            Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription',Product_Type__c='EDGECONNECT', isActive = true, IsQuotable__c = true);
            insert product;            
            Opportunity oppo = new Opportunity(AccountId=testAccount.Id,name='test', stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
            insert oppo;
            Quote__c qt = new Quote__c(Tier_1_Partner__c=reseller.Id,Discount_Justification__c='Test', Tier_2_Partner__c=distributor.Id,  Quote_Name__c='Test',Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
            insert qt; 
            Quote_Line__c quoteLine= new Quote_Line__c(Quote__c=qt.Id,Discount_Percent__c=99,Quantity__c=10,Product__c=product.Id);
        	insert quoteLine;
            string outputTest=QuoteExtension.SubmitForApproval(qt.Id);
            System.debug('outputTest'+outputTest);
           // System.assert(outputTest.contains('Special Instructions is empty. Please provide comments.'));
        }
        catch(Exception ex)
        {
            
        }
        
            
           
       
    }
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_GEORegion()
    {
        Account testAccount= new Account(Name='Test Account');
        insert testAccount;
        Account reseller= new Account(Name='Test Reseller',Type='Partner',Partner_Type__c='Reseller');
        insert reseller;
        Account distributor= new Account(Name='Test Distributor',Type='Partner',Partner_Type__c='Distributor',Reseller_Agreement__c=true);
        insert distributor;
        //create opportunity and opportunity line item.
  
        try
        {
            Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription',Product_Type__c='EDGECONNECT', isActive = true, IsQuotable__c = true);
            insert product;
            
            Opportunity oppo = new Opportunity(AccountId=testAccount.Id,name='test',Sales_Region__c='Test', stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
            insert oppo;
            oppo.Sales_Region__c='';
            update oppo;
            Quote__c qt = new Quote__c(Tier_1_Partner__c=reseller.Id, Tier_2_Partner__c=distributor.Id,  Quote_Name__c='Test',Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
            insert qt; 
            qt.Special_Instructions__c='Test';
            qt.Discount_Justification__c='Test';
            Update qt;
            Quote_Line__c quoteLine= new Quote_Line__c(Quote__c=qt.Id,Discount_Percent__c=99,Quantity__c=10,Product__c=product.Id);
        	insert quoteLine;
            string outputTest=QuoteExtension.SubmitForApproval(qt.Id);
            System.debug('outputTest'+outputTest);
            System.assert(outputTest.contains('GEO is blank on the opportunity.Please populate this value or contact sales operations.'));
        }
        catch(Exception ex)
        {
            System.debug('Error'+ex);
        }

    }
    
    @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_ApprovalSubmit()
    {
        Account testAccount= new Account(Name='Test Account');
        insert testAccount;
        Account reseller= new Account(Name='Test Reseller',Type='Partner',Partner_Type__c='Reseller');
        insert reseller;
        Account distributor= new Account(Name='Test Distributor',Type='Partner',Partner_Type__c='Distributor',Reseller_Agreement__c=true);
        insert distributor;
        Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription', isActive = true, IsQuotable__c = true);
        insert product;
      
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',  StageName = 'Discovery', CloseDate = Date.today().addDays(1));
        insert opportunity;
       
        Quote__c quote1 = new Quote__c(Tier_1_Partner__c=reseller.Id, Tier_2_Partner__c=distributor.Id,Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(),Discount_Justification__c='test Data');
        insert quote1; 

        Quote_Line__c quoteLine= new Quote_Line__c(Quote__c=quote1.Id,Discount_Percent__c=46,Quantity__c=10,Product__c=product.Id);
        insert quoteLine;
        
        QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
        quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
        QuoteExtension.SubmitForApproval(quote1.Id);
        
    }
    
      @isTest(seeAllData=true)
    static void testQuoteExtension_ValidateCriteria_ApprovalSubmit_NotRequired()
    {
        Account testAccount= new Account(Name='Test Account');
        insert testAccount;
        Account reseller= new Account(Name='Test Reseller',Type='Partner',Partner_Type__c='Reseller');
        insert reseller;
        Account distributor= new Account(Name='Test Distributor',Type='Partner',Partner_Type__c='Distributor',Reseller_Agreement__c=true);
        insert distributor;
        Product2 product = new Product2(name = 'Test Product', Product_Category__c = 'Subscription', isActive = true, IsQuotable__c = true);
        insert product;
      
        Opportunity opportunity = new Opportunity(Name = 'Test Opportunity',  StageName = 'Discovery', CloseDate = Date.today().addDays(1));
        insert opportunity;
       
        Quote__c quote1 = new Quote__c(Tier_1_Partner__c=reseller.Id, Tier_2_Partner__c=distributor.Id,Opportunity__c = opportunity.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today(),Discount_Justification__c='test Data');
        insert quote1; 

   
        
        QuoteExtension ext = new QuoteExtension(new ApexPages.StandardController(quote1));
        quote1 = [select Primary__c from Quote__c where Id = :quote1.Id];
        QuoteExtension.SubmitForApproval(quote1.Id);
        
    }
    
    
}