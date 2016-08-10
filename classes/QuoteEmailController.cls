public class QuoteEmailController
{
    class QuoteLine
    {
        public PricebookEntry price{get;set;} 
        public Quote_Line__c record{get;set;}
    }
    public Opportunity getOppo() 
    {
        List<Opportunity> oppos = [select name, account.name, account.phone, Owner.Phone, Owner.Email, Owner.Name, 
                    (Select Id From OpportunityLineItems)
                    from opportunity where id = :quote.opportunity__c limit 1];
                    //Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingCity, Account.ShippingStreet, 
                    //Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingCity, Account.BillingStreet, 
        if(oppos != null && oppos.size() > 0)
        {
            return oppos[0];
        }
        return null;
    }

    private List<QuoteLine> lines;
    public List<QuoteLine> getLines()
    {
        lines = new List<QuoteLine>();
        List<Quote_Line__c> quoteLines = [Select Id, Name, Quantity__c, Product__c, Discount_Percent__c, Unit_Price__c, Line_Price__c, Product__r.Name, product__r.productCode, product__r.description, Product__r.Product_Category__c From Quote_Line__c where Quote__c = :quote.Id order by Product__r.Product_Category__c, product__r.productCode]; 
        List<PricebookEntry> entries = [Select UnitPrice, Product2Id From PricebookEntry where Pricebook2Id = :quote.Opportunity__r.Pricebook2Id];
        for(Quote_Line__c quoteLine : quoteLines)
        {
            QuoteLine line = new QuoteLine();
            line.record = quoteLine;
            for(PricebookEntry entry : entries)
            {
                if(entry.Product2Id == quoteLine.Product__c)
                {
                    line.price = entry;
                    break;
                }                
            }
            lines.add(line);
        }
        return lines;
    }

    public Quote__c quote
    {
        get
        {
            List<Quote__c> quotes = [Select Opportunity__r.Name, Opportunity__r.Description, Lastmodifieddate, Opportunity__r.Pricebook2Id, Opportunity__r.StageName, Stage__c, 
                    Quote_Valid_Until__c, Quote_Discount_Percent__c, Quote_Date__c, PreparedFor__c, PreparedFor__r.Name, PreparedFor__r.Phone,
                    Quote_Amount_Rollup__c, Primary__c, Opportunity__c, Name, Id, PaymentTerm__c, Special_Instructions__c, ShowDiscount__c, PaymentTermInstructions__c,
                    Bill_To_Address__c, Bill_To_City__c, Bill_To_State__c, Bill_To_Zip__c, Bill_To_Country__c,
                    Ship_To_Address__c, Ship_To_City__c, Ship_To_State__c, Ship_To_Zip__c, Ship_To_Country__c,
                    (Select Id, Name, Quote__c, Product__c, Quantity__c, Discount_Percent__c, Unit_Price__c, 
                        Line_Price__c, Product__r.Name, product__r.productCode, product__r.description, Product__r.Product_Category__c 
                        From Quote_Lines__r order by Product__r.Product_Category__c, product__r.productCode) 
                    From Quote__c where Id = :quote.Id limit 1];
            if(quotes != null && quotes.size() > 0)
            {
                quote = quotes[0];
            }
            return quote;

        }
        set;
    }
    
    public QuoteEmailController()
    {
        quote = new Quote__c();
    }
    
    @isTest
    static void test()
    {
        QuoteEmailController controller = new QuoteEmailController();
        Quote__c quote = controller.quote;
        List<QuoteLine> lines = controller.getLines();
        Opportunity opp = controller.getOppo();
    }
}