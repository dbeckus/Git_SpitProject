@IsTest
public class TestUpdateOpportunityProductType {
    
   	@isTest(SeeAllData=true)
    public static void TestOppTypeWhenMadePrimary_ChangeinQuoteLine()
    {
        Product2 prod = new product2(name='EC-BASE',Product_Type__c='EDGECONNECT', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod;
        Product2 prod2 = new product2(name='y',Product_Type__c='NX/VX', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
        
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;    
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug('controller exists');
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);
        
        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 
        
        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        controller.saveAndMakePrimary();        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
        
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        
        Opportunity opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals('EDGECONNECT',opp.Product_Type__c);                     
        
        ApexPages.currentPage().getParameters().put('delIndex', '1');
        controller.del();
        //calculate discount by price
        controller.items[1].record.Unit_Price__c = 0.75;
        controller.asyncUpdateProduct();       
        controller.save();       
        controller.attachQuote();
        
        opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals('EDGECONNECT',opp.Product_Type__c);   
        Test.stopTest();
    }  
    @isTest(SeeAllData=true)
    public static void TestOppTypeWhenMadePrimary_NX()
    {
        Product2 prod = new product2(name='x',Product_Type__c='NX/VX', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod;
        Product2 prod2 = new product2(name='y',Product_Type__c='NX/VX', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
        
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;    
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug('controller exists');
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);
        
        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 
        
        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        controller.saveAndMakePrimary();        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
        
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        
        Opportunity opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals('NX/VX',opp.Product_Type__c);                     
        
        Test.stopTest();
    }
   	@isTest(SeeAllData=true)
    public static void TestOppTypeWhenMadePrimary_EC()
    {
        Product2 prod = new product2(name='EC-BASE',Product_Type__c='EDGECONNECT', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod;
        Product2 prod2 = new product2(name='EC-PLUS', Product_Type__c='EDGECONNECT',Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
        
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;    
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug('controller exists');
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);
        
        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 
        
        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        controller.saveAndMakePrimary();        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
        
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        
        Opportunity opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals('EDGECONNECT',opp.Product_Type__c);                     
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void TestOppTypeWhenMadePrimary_SP()
    {
        Product2 prod = new product2(name='EC-SP-PLUS',Product_Type__c='EC-SP-Term', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod;
        SYSTEM.debug('prod.Id'+prod.Id);
        Product2 prod2 = new product2(name='EC-BASE-PLUS',Product_Type__c='EC-SP-Term', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod2;
        SYSTEM.debug('prod2.Id'+prod2.Id);
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
        
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;    
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug('controller exists');
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);
        
        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        System.debug('SP controller.searchResults[0].Id '+controller.searchResults[0].Id );
        System.debug('SP controller.searchResults[1].Id '+controller.searchResults[1].Id );
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 
        
        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        controller.saveAndMakePrimary();        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
        
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        
        Opportunity opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals('EC-SP',opp.Product_Type__c);                     
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    public static void TestOppTypeWhenMadeNotPrimary_None()
    {
        Product2 prod = new product2(name='x', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod;
        Product2 prod2 = new product2(name='EC-PLUS', Product_Category__c = 'Subscription', isActive = true, isQuotable__c = true,Family='Virtual Image');
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
        
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        Quote__c qt = new Quote__c(Opportunity__c = oppo.Id, Quote_Valid_Until__c = Date.today(), Quote_Date__c = Date.today());
        insert qt;    
        
        Test.startTest();
        //test constructor
        QuoteController controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug('controller exists');
        PageReference refer = new PageReference('/apex/EditQuoteLines');
        Test.setCurrentPage(refer);
        
        //copy line items from opportunity to quote
        ApexPages.currentPage().getParameters().put('reloadQuote', '1');
        controller.copy();
        System.assert([Select count() from Quote_Line__c where Quote__c = :qt.Id] == 1);
        ApexPages.currentPage().getParameters().remove('reloadQuote');
        
        //reload controller since copy line items from opportunity refreshs the quote's child records.
        controller = new QuoteController(new ApexPages.StandardController(qt));
        System.debug(controller.items.size());
        controller.getProductGroups();
        //search all products
        controller.add();
        controller.searchKeyword = '';
        controller.getFilterValues();
        controller.filterValue = 'all';
        controller.search();  
        
        controller.add();
        controller.filterValue = 'Subscription';
        controller.search();
        controller.selectedProds = controller.searchResults[0].Id + ';' + controller.searchResults[1].Id + ';' ;
        controller.addProducts();
        Quote_Line__c line = controller.items[1].record;
        line.Quantity__c = 2;
        line.Discount_Percent__c = 50;        
        String cf = controller.CurrencyFormat;
        String qd = controller.QuoteDate;
        String vu = controller.validUntil;
        String ta = controller.totalAmount;
        Boolean sa = controller.showVirtualAlternative;
        Quote__c q = controller.getQuote();
        List<QuoteController.LineItem> its = controller.getItems();
        Quote_Line__c line2 = controller.items[2].record;
        line2.Quantity__c = 2;
        line2.Discount_Percent__c = 20; 
        
        System.assert(controller.items.size() == 3);     
        controller.asyncUpdatePrice();
        
        controller.saveAndMakePrimary();        
        controller.attachQuote();
        controller.cloneQuoteWithProducts();
        
        //copy line items from quote to opportunity
        ApexPages.currentPage().getParameters().put('reloadOppo', '1');
        controller.copy();
        
        qt.Primary__c=false;
        update qt;
        Opportunity opp =[Select Id,Product_Type__c from Opportunity where Id =:oppo.Id];
        System.assertEquals(null,opp.Product_Type__c);                     
        
        Test.stopTest();
    }
}