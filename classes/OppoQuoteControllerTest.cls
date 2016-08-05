@isTest
public class OppoQuoteControllerTest
{
    @isTest(SeeAllData=true)
    public static void testController()
    {
        //Initial test parameters.
        //create opportunity, product, priceboock, pricebookentry, opportunitylineitem 
        Product2 prod = new product2(name='x');
        insert prod;
        Product2 prod2 = new product2(name='y');
        insert prod2;
        Pricebook2 stdPb = [select Id from Pricebook2 where isStandard=true limit 1];
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod.id, unitprice=1.0, isActive=true);
        insert new PricebookEntry(pricebook2id = stdPb.id, product2id = prod2.id, unitprice=2.0, isActive=true);
        //creates a new pricebook with an entry for this product
        Pricebook2 book = new Pricebook2(name='test');
        insert book;
        PricebookEntry entry = new PricebookEntry(pricebook2id=book.id, product2id=prod.id, unitprice=1.0, isActive=true);
        insert entry;
        //PricebookEntry entry =
        insert new PricebookEntry(pricebook2id=book.id, product2id=prod2.id, unitprice=1.0, isActive=true);
             
        //create opportunity and opportunity line item.
        Opportunity oppo = new Opportunity(name='test', pricebook2id=book.id, stageName='Discovery', CloseDate=Date.newInstance(2006,10,10));
        insert oppo;
        OpportunityLineItem oli = new OpportunityLineItem(opportunityid=oppo.id, pricebookentryid=entry.id, unitprice=1.5, quantity=2);
        insert oli;
        
        PageReference refer = new PageReference('/apex/NewQuote');
        Test.setCurrentPage(refer);
        ApexPages.currentPage().getParameters().put('id', oppo.Id);
        OppoQuoteController controller = new OppoQuoteController(new ApexPages.StandardController(oppo));
        System.debug(controller.oppo.OpportunityLineItems );
        controller.getPricebooks();        
        controller.stage = OppoQuoteController.CopyStage.DoNotCopy.ordinal();
        controller.quote.Quote_Valid_Until__c = Date.today();
        controller.quote.Quote_Date__c = Date.today();
        controller.save();
        System.assert([select count() from Quote_Line__c where Quote__c = :controller.quote.Id] == 0);
        
        controller = new OppoQuoteController(new ApexPages.StandardController(oppo));       
        controller.stage = OppoQuoteController.CopyStage.CopyOnly.ordinal();
        controller.quote.Quote_Valid_Until__c = Date.today();
        controller.quote.Quote_Date__c = Date.today();
        controller.save();
        System.debug([select count() from Quote_Line__c where Quote__c = :controller.quote.Id]);
        System.assert([select count() from Quote_Line__c where Quote__c = :controller.quote.Id] == 1);
        
        controller = new OppoQuoteController(new ApexPages.StandardController(oppo));
        controller.stage = OppoQuoteController.CopyStage.CopyAndEdit.ordinal();
        controller.quote.Quote_Valid_Until__c = Date.today();
        controller.quote.Quote_Date__c = Date.today();
        controller.save();
        System.assert([select count() from Quote_Line__c where Quote__c = :controller.quote.Id] == 1);
        
        controller = new OppoQuoteController(new ApexPages.StandardController(oppo));
        controller.stage = OppoQuoteController.CopyStage.CopyAndEdit.ordinal();
        controller.save();
        System.assert([select count() from Quote_Line__c where Quote__c = :controller.quote.Id] == 1);
    }
}