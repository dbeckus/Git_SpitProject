public class QuoteController 
{   
    private Quote__c quote; //master quote object
    @testvisible
    private List<LineItem> items; //all the line items for a quote.
    public Id quoteId{get;set;} //quote id
    public String delId{get;set;} //quote_line__c id 
    public List<Quote_Line__c> itemsToDel;
    public Opportunity oppo { get; private set; }  
    public Boolean hasContact { get { return (quote.PreparedFor__c != null);} }
    public Contact contact { get; private set; }  
    Boolean validParameters; //check whether the page contains all the parameters needed.
    
    public String CurrencyFormat 
    {
        get
        {
            Decimal temp = 9999.99;
            return temp.format();
        }
    }
    
    //properties for lookup products
    public String filterValue{get;set;}
    public String searchKeyword{get;set;}
    //public boolean ECApprovalRequired { get; set; }
    public String OutputMessage { get; set; }
    public List<Product2> searchResults{get;set;}
    public String selectedProds{get;set;}
    //quote field Quote_Date__c
    public String quoteDate
    {
        get
        {
            if(quote != null && quote.Quote_Date__c != null)
            {
                return quote.Quote_Date__c.format();    
            }
            return null;
        }
    }
    //quote field Quote_Valid_Until__c
    public String validUntil
    {
        get
        {
            if(quote!= null && quote.Quote_Valid_Until__c != null)
            {
                return quote.Quote_Valid_Until__c.format();    
            }
            return null;
        }
    }
    
    //currency formatted total amount
    public String totalAmount
    {
        get
        {
            Decimal i = 0;
            if(items != null && items.size() > 0)
            {
                for(LineItem tmpItem : items)
                {
                    i += tmpItem.amount;
                }
            }
            return convertToCurrency(i);
        }
    }
    
    public Boolean showVirtualAlternative
    {
        get
        {
            if(quote.Show_Virtual_Alternatives__c)
            {
                for(Quote_Line__c line : quote.Quote_Lines__r)
                {
                    if(line.Product__r.Product_Category__c == 'Appliance' || line.Product__r.Forecast_Category__c == 'Physical')
                    {
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    public Quote__c getQuote()
    {
        return quote;
    }
    public void setQuote(Quote__c val)
    {
        quote = val;
    }
    public List<LineItem> getItems()
    {
        return items;
    }
    
    public List<LineItemGroup> getProductGroups()
    {
        List<LineItemGroup> groups = new List<LineItemGroup>();
        if (items != null)
        {
            for(LineItem item : items)
            {
                Boolean foundGroup = false;
                for(LineItemGroup itemGroup : groups)
                {
                    if(itemGroup.label == item.record.Product__r.Product_Category_Group__c || !quote.Show_Subtotal__c)
                    {
                        itemGroup.items.add(item);
                        foundGroup = true;
                        break;
                    }
                }
                if(!foundGroup)
                {
                    LineItemGroup itemGroup = new LineItemGroup();
                    itemGroup.label = item.record.Product__r.Product_Category_Group__c;
                    itemGroup.items.add(item);
                    groups.add(itemGroup);
                }
            }
        }
        return groups;
    }
    
    //constructor
    public QuoteController(ApexPages.StandardController controller)
    {
        quoteId = ((Quote__c)controller.getRecord()).Id;
        validParameters = true;
        if(quoteId != null)
        {
            init();
        }
        else
        {
            validParameters = false;
        }
    }
    public QuoteController()
    {
        if(quoteId != null)
        {
            init();
            filterValue = 'sssss';
        }
        else
        {
            filterValue = 'aaaaa';
        }
        quoteId = null;
    }
    
    void init()
    {
        quote = [Select Opportunity__r.Name, Opportunity__r.Description, Lastmodifieddate, Opportunity__r.Pricebook2Id, Opportunity__r.StageName, Stage__c, Show_Subtotal__c,
                 Quote_Valid_Until__c, Quote_Discount_Percent__c, Quote_Date__c, Approval_Made__c, PreparedFor__c, PreparedFor__r.Name, PreparedFor__r.Phone,
                 Quote_Amount_Rollup__c, Primary__c, Opportunity__c, Name, Id, PaymentTerm__c, Special_Instructions__c, ShowDiscount__c, Hide_Pricing__c, Show_Virtual_Alternatives__c, PaymentTermInstructions__c,
                 Bill_To_Address__c, Bill_To_City__c, Bill_To_State__c, Bill_To_Zip__c, Bill_To_Country__c,
                 Ship_To_Address__c, Ship_To_City__c, Ship_To_State__c, Ship_To_Zip__c, Ship_To_Country__c,
                 (Select Id, Name, Quote__c, Product__c, Quantity__c, Discount_Percent__c, Unit_Price__c, 
                  Line_Price__c, Product__r.Name, Product__r.Family, Product__r.productCode, product__r.description, Product__r.Product_Category__c, Product__r.Product_Category_Group__c, Product__r.Forecast_Category__c, Product__r.Virtual_Discount__c, Product__r.Subscription_Discount__c, Product__r.Not_Discountable__c 
                  From Quote_Lines__r Order by Product__r.Product_Category__c, product__r.productCode) 
                 From Quote__c where Id = :quoteId limit 1];
        if ( hasContact ) 
        {
            contact = quote.PreparedFor__r;
        }
        items = new List<LineItem>();
        itemsToDel = new List<Quote_Line__c>();
        for(Quote_Line__c line : quote.Quote_Lines__r)
        {
            LineItem tmpItem = new LineItem();
            //line.Quote__r = quote;
            tmpItem.record = line;
            tmpItem.NotDiscountable = line.Product__r.Not_Discountable__c;
            tmpItem.amount = line.Quantity__c * line.Unit_Price__c;
            tmpItem.amountCurrency = convertToCurrency(tmpItem.amount);
            tmpItem.needUpdate = false;
            List<PricebookEntry> pbEntries = [Select UnitPrice From PricebookEntry where Product2Id = :line.Product__c and Pricebook2Id = :quote.Opportunity__r.Pricebook2Id limit 1];
            if(pbEntries.size() > 0)
            {
                tmpItem.price = pbEntries[0];
                tmpItem.index = items.size();
                items.add(tmpItem);
            }
            else
            {
                //do nothing to the lines without a pricebook entry. 
            }
        }
        
        if ( quote.opportunity__c != null ) 
        {
            /* Set the related opportunity with the result of the query that traverses to account for display of the name
and down to get the primary contact role. */
            oppo = [select name, account.name, account.phone, Owner.Phone, Owner.Email, Owner.Name, Pricebook2Id,
                    (Select Id From OpportunityLineItems)
                    from opportunity where id = :quote.opportunity__c];  
            //Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingState, Account.ShippingCity, Account.ShippingStreet, 
            //Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingCity, Account.BillingStreet,           
        }
    }
    
    //calculate quoteline amount 
    void calcuAmount(LineItem li)
    {
        li.amount = li.record.Quantity__c * li.record.Unit_Price__c;
        li.amountCurrency = convertToCurrency(li.amount);
    }
    
    //set product of the quote line and calculate discount percent according to unit price
    public PageReference asyncUpdateProduct()
    {/*the recalculate part need to be optimized, each time this function is called, only one lineitem amount need to recalculate*/
        for(LineItem tmpItem : items)
        {
            if(tmpItem.record.Product__c != null && tmpItem.record.Product__r == null)
            {
                tmpItem.record.Product__r = [select Id, Name from Product2 where id = :tmpItem.record.Product__c limit 1];
                tmpItem.price = [Select UnitPrice From PricebookEntry where Product2Id = :tmpItem.record.Product__c and Pricebook2Id = :quote.Opportunity__r.Pricebook2Id limit 1];
            }
            //update discount according to unit price
            tmpItem.record.Discount_Percent__c = (1 - (tmpItem.record.Unit_Price__c * 1.0 / tmpItem.price.UnitPrice))*100;
            calcuAmount(tmpItem);
        }
        return null;
    }
    
    //set product of the quote line and calculate the unit price according to discount percent.
    public PageReference asyncUpdatePrice()
    {
        for(LineItem li : items)
        {
            if(li.record.Product__c != null && li.record.Product__r == null)
            {
                li.record.Product__r = [select Id, Name from Product2 where id = :li.record.Product__c limit 1];
                li.price = [Select UnitPrice From PricebookEntry where Product2Id = :li.record.Product__c and Pricebook2Id = :quote.Opportunity__r.Pricebook2Id limit 1];
            }                                        
            //update unit price according to discount
            li.record.Unit_Price__c = li.price.UnitPrice * (100 - ((li.record.Discount_Percent__c == null) ? 0 : li.record.Discount_Percent__c)) / 100;
            calcuAmount(li);
        }
        return null;
    }
    
    //get all categories as search condition
    public List<SelectOption> getFilterValues()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult res = Product2.Product_Category__c.getDescribe();
        List<Schema.PicklistEntry> entries = res.getPicklistValues();
        options.add(new SelectOption('all', 'All'));
        for(Schema.PicklistEntry entry : entries)
        {
            options.add(new SelectOption(entry.getValue(), entry.getLabel()));
        }
        return options;
    } 
    
    //get all the pricebooks
    public List<SelectOption> getPriceBooks()
    {
        List<SelectOption> options = new List<SelectOption>();
        for(Pricebook2 book : [select Id, Name from Pricebook2])
        {
            options.add(new SelectOption(book.Id, book.Name));
        }
        return options;
    }
    
    //search products with specific keyword and category
    public PageReference search()
    {
        if(oppo == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter the page in normal way.'));
            return null;
        }
        List<PriceBookEntry> entries = [select Id, Product2Id from PriceBookEntry where PriceBook2Id = :oppo.PriceBook2Id and PriceBookEntry.IsActive=True];
        List<Id> prodIds = new List<Id>();
        if(entries != null && entries.size() > 0)
        {
            for(PriceBookEntry entry : entries)
            {
                prodIds.add(entry.Product2Id);
            }      
            System.debug(prodIds);  
            //use soql if no search keyword is specified.
            if(searchKeyword == null || searchKeyword == '')
            {
                String soql = 'select Id, Name, Description, ProductCode, Product_Category__c from product2 where isActive = true  and isQuotable__c = True and Id in : prodIds ';
                if(!filterValue.equalsIgnoreCase('all'))
                {
                    soql += ' and Product_Category__c = \'' + filterValue + '\''; // + ' = ' + filterKeyword;
                }
                soql += ' limit 1000';
                searchResults = Database.query(soql);
                
                return null;
            }
            //use sosl to search specific search keyword
            else
            {
                try
                {
                    String sosl = 'find \'' + String.escapeSingleQuotes(searchKeyword) + '\' in all fields returning product2(Id, Name, Description, ProductCode, Product_Category__c where isActive=true and isQuotable__c=true and Id in :prodIds';
                    if(!filterValue.equalsIgnoreCase('all'))
                    {
                        sosl += ' and Product_Category__c = \'' + filterValue + '\'';// + ' = ' + filterKeyword;                
                    }
                    sosl += ')';
                    System.debug(sosl);
                    List<List<Sobject>> tmpResults = search.query(sosl);
                    if(tmpResults != null && tmpResults.size() > 0)
                    {
                        searchResults = (List<Product2>)tmpResults[0];
                    }
                }
                catch(exception ex)
                {
                    return null;
                }
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    
    //add records to editlineitems page and redirect page
    public PageReference addProducts()
    {
        if(selectedProds != null && selectedProds != '')
        {
            String[] prods = selectedProds.split(';', 0); //selectedprods is set in the page.
            if(prods != null && prods.size() > 0)
            {
                List<Product2> products = [select Id, Name, Not_Discountable__c from Product2 where Id in :prods];
                for(Product2 prod : products)
                {
                    LineItem tmpItem = new LineItem();
                    Quote_Line__c rcd = new Quote_Line__c(Quote__c = quote.id, Quote__r = quote, Unit_price__c = 0.0, Quantity__c = 0.0, Discount_Percent__c = 0.0, product__c = prod.Id );
                    tmpItem.amount = 0;
                    tmpItem.record = rcd;
                    tmpItem.NotDiscountable = prod.Not_Discountable__c;
                    tmpItem.index = items.size();
                    items.add(tmpItem);
                }
            }
        }
        if(items!= null && items.size() > 0)
        {
            asyncUpdatePrice(); //temporary set price.
        }
        return new PageReference('/apex/editQuoteLines?id=' + quote.Id);
    }
    
    //add records to editlineitems page and remain in the current page
    public PageReference quickAddProducts()
    {
        Integer i = 0;
        if(selectedProds != null && selectedProds != '')
        {
            String[] prods = selectedProds.split(';', 0); //selectedprods is set in the page.
            if(prods != null && prods.size() > 0)
            {
                List<Product2> products = [select Id, Name, Not_Discountable__c from Product2 where Id in :prods];
                for(Product2 prod : products)
                {
                    LineItem tmpItem = new LineItem();
                    Quote_Line__c rcd = new Quote_Line__c(Quote__c = quote.id, Quote__r = quote, Unit_price__c = 0.0, Quantity__c = 0.0, Discount_Percent__c = 0.0, product__c = prod.Id );
                    tmpItem.amount = 0;
                    tmpItem.record = rcd;
                    tmpItem.NotDiscountable = prod.Not_Discountable__c;
                    tmpItem.index = items.size();
                    items.add(tmpItem);
                    i++;
                }
            }
        }
        if(items!= null && items.size() > 0)
        {
            asyncUpdatePrice(); //temporary set price.
        }
        if(i > 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, i + ' product(s) added.'));
        }
        //searchKeyword = '';
        //searchResults = new List<Product2>();
        //selectedProds = '';
        return null;
    }
    //redirect pages
    public PageReference quotePage()
    {
        return new PageReference('/' + quote.Id);
    }
    public PageReference oppoPage()
    {
        return new PageReference('/' + quote.Opportunity__c);
    }
    public PageReference editQuoteLinesPage()
    {
        if(quote == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter the page in normal way.'));
            return null;
        }
        return new PageReference('/apex/editQuoteLines?id='  + quote.Id);
    }
    
    //redirect to select products page.
    public PageReference add()
    {
        if(quote == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter the page in normal way.'));
            return null;
        }
        return new PageReference('/apex/LookupProducts?id=' + quote.id);
    }
    
    //delete selected line, add record to delete list
    public PageReference del() 
    {
        try
        {
            Integer delIndex = Integer.valueOf(ApexPages.CurrentPage().getParameters().get('delIndex'));   
            if(delIndex >= 0 && delIndex < items.size())
            {
                //if the record to delete is an existsing one, add it to delete list.
                if(items[delIndex].record.Id != null)
                {
                    itemsToDel.add(items[delIndex].record);
                }
                //remove selected line from page                
                items.remove(delIndex);
                //reindex lines
                for(Integer i = 0; i < items.size(); i++)
                {
                    items[i].index = i;
                }
            }
        }
        catch(exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }        
        return null;
    }
    //reload the editquoteline page
    public PageReference reset() 
    {
        init();
        return null;
    }
    //save function for editquoteline page. 
    public PageReference save()
    {
        List<Quote_Line__c> itemsToUpsert = new List<Quote_Line__c>();
        if(items != null && items.size()> 0)
        {
            for(LineItem tmpItem : items)
            {
                itemsToUpsert.add(tmpItem.record);
            }
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            if(itemsToUpsert.size() > 0)
            {
                upsert itemsToUpsert; //upsert quote lines
            }
            if(itemsToDel.size() > 0)
            {
                delete itemsToDel; //delete quote lines;
            }
            System.debug('Opp Id'+ quote.Opportunity__r.Id);
            
            init();
           
            
        }
        catch (Exception exc) 
        { 
            Database.rollback(sp);
            ApexPages.addMessages(exc); 
            return null;
        }
        return quotePage();
    }
    
    public PageReference saveAndMakePrimary()
    {
        save();
        PageReference result = new PageReference('/apex/editQuoteLines?id=' + quote.Id + '&reloadOppo=1');
        result.setRedirect(true);
        return result;
    }
    
    public PageReference closePopup() {        
      /*  ECApprovalRequired = false; 
        //PageReference result = new PageReference('/apex/editQuoteLines?id=' + quote.Id + '&reloadOppo=1');
        //result.setRedirect(true);*/
        return quotePage();
        
    }     
    
    //generate a pdf page for current quote
    public PageReference attachQuote()
    {
        
       /* Quote__c quoteDtl=[Select Id,Name,EC_Approval__c,PreparedFor__c,PreparedFor__r.Email,Approval_Required__c,Approval_Made__c from Quote__c where Id=:quote.Id ];
        if(quoteDtl!=null && !quoteDtl.EC_Approval__c  && !quoteDtl.Approval_Made__c  && QuoteEmailReviewHelper.IsECApprovalRequired(quoteDtl))
        {
            if(quoteDtl.Approval_Required__c==0)
            {
                
                ECApprovalRequired=true;
                SendEmailForECApproval(quoteDtl);
            }
            return null;
        }*/
        
        
        String aName = 'Quotation for ' + oppo.Account.Name + ' ' + quote.name + '.pdf';
        delete [select Id from Attachment where parentId = :quote.id and name = :aName];
        // Get the page definition 
        PageReference pdfPage = new PageReference( '/apex/quotePDF' );
        
        // set the quote id on the page definition
        pdfPage.getParameters().put('id',quote.id);
        
        //generate the pdf blob
        Blob pdfBlob;
        if(Test.isRunningTest())
        {
            pdfBlob = Blob.valueOf('TestPDF');            
        }
        else
        {
            pdfBlob = pdfPage.getContent();
        }
        
        
        // create the attachment against the quote
        Attachment a = new Attachment(parentId = quote.id, name = aName, body = pdfBlob);
        
        // insert the attachment
        insert a;
        
        //update quote stage to presented
        quote.Stage__c = 'Presented';
        update quote;
        
        // send the user back to the quote detail page
        //return controller.view();
        return quotePage();
        
    }
    
/*
    private void SendEmailForECApproval(Quote__c quoteDtl)
    {
        try
        {
            QuoteEmailReviewHelper.SendEmailForECApproval(quoteDtl);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An email has been sent to "Sales Operations" for EC Approval review. <script>setTimeout("top.close()", 3000)</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }*/
    //clone current quote
    public PageReference cloneQuoteWithProducts()
    {
        Quote__c twinQuote = quote.clone(false, true);
        twinQuote.Primary__c = false;  //new quote should not set as primary.
        twinQuote.Quote_Date__c = Date.today();
        twinQuote.Quote_Valid_Until__c = Date.today().addDays(30);
        insert twinQuote;
        
        // create new quote lines
        Quote_Line__c[] qlines = new list<Quote_Line__c>(); 
        for(LineItem lItem : items) 
        {
            Quote_Line__c ql = new Quote_Line__c(
                Quote__c = twinQuote.id,
                Discount_Percent__c = lItem.record.Discount_Percent__c,
                Quantity__c = lItem.record.Quantity__c,
                Unit_Price__c = lItem.record.Unit_Price__c,
                Product__c = lItem.record.Product__c
            ); 
            qlines.add(ql);     
        }
        insert qlines;
        return new PageReference('/' + twinQuote.Id);
    }
    
    public PageReference cloneQuoteWithoutProducts()
    {
        PageReference ref = new PageReference('/' + quoteId + '/e?clone=1&nooverride=1&retURL=%2F' + quoteId + '&00N500000022E28=' + Date.today().addDays(30).format());
        return ref;
    }
    
    //copy child objects to quote or opportunity, according the the parameters
    public PageReference copy()
    {
        // implement copy to and from opportunity given page parameters
        string reloadQuote = ApexPages.CurrentPage().getParameters().get('reloadQuote');
        string reloadOppo = ApexPages.CurrentPage().getParameters().get('reloadOppo');
        
        if ( reloadOppo != null ) 
        { 
            Boolean success = copyLineItemsToOppo();
            if(success)
            {
                return quotePage() ;    
            }
            else
            {
                return null;
            }
        }
        if ( reloadQuote != null ) 
        { 
            copyLineItemsToQuote(); 
            return quotepage(); 
        }
        return null;
    }
    
    //convert a decimal value to currency formatted string
    private String convertToCurrency(Decimal d)
    {
        String convertResult = '$';
        d = (d == null) ? 0 : d;
        convertResult += d.setScale(2).format();
        /*if(convertResult.contains('.'))
{
if(convertResult.length() - convertResult.indexOf('.') == 2)
{
convertResult += '0';
}
}
else
{
convertResult += '.00';
}*/
        return convertResult;    
    }
    
    //set current quote as primary quote of the opportunity
    void setPrimaryQuote()
    {
        List<Quote__c> quotes = [select Opportunity__c, Id, Name from Quote__c where Opportunity__c = :quote.Opportunity__c];
        for(Quote__c q : quotes)
        {            
            if(q.Id == quote.Id)
            {
                q.Primary__c = true;
                update q;
            }
        }
    }
    
    //copy LineItems To Opportunity
    public Boolean copyLineItemsToOppo()
    {
        id opptyId = quote.Opportunity__r.id; 
        List<Opportunity> targetOpp = [select Id, IsClosed, IsWon from Opportunity where Id=:opptyId limit 1];
        if(targetOpp.size() == 1)
        {
            if(targetOpp[0].IsClosed && targetOpp[0].IsWon)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot change Amount on an Closed Won opportunity'));
                return false;
            }
        }
        
        // find the appropriate pricebookentries for each product2 id
        List<ID> productIdList = new List<ID>();
        for (LineItem item : items) 
        {
            productIdList.add(item.record.Product__c);
        }
        List<PricebookEntry> priceBookEntries = [Select id, Product2Id, Pricebook2Id From PricebookEntry
                                                 where pricebook2id = :quote.Opportunity__r.Pricebook2Id and
                                                 product2id in :productIdList];
        Map<Id,Id> productIdToPricebookEntryIdMap = new Map<Id,Id>();
        for(PricebookEntry p : pricebookEntries) 
        {
            productIdToPricebookEntryIdMap.put(p.product2Id, p.id);
        }
        SavePoint sp = Database.setSavePoint();
        try
        {
            // clear out old opportunity line items
            List<OpportunityLineItem> oldLineItems = [select id from OpportunityLineItem where opportunityId = :opptyId];
            delete oldLineItems;
            // insert new ones
            List<OpportunityLineItem> newLineItems = new List<OpportunityLineItem>();
            for(LineItem tmpItem : items)
            { 
                newLineItems.add(New OpportunityLineItem(opportunityId = opptyId,
                                                         quantity = tmpItem.record.Quantity__c,
                                                         unitPrice =  tmpItem.record.Unit_Price__c,
                                                         pricebookEntryId = productIdToPricebookEntryIdMap.get(tmpItem.record.Product__c)                                              
                                                        ));
            }
            insert newLineItems;
            setPrimaryQuote(); // since we just overwrote the opp 
            
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to update opportunity and set quote primary. The message is: ' + ex.getMessage()));
            return false;
        }
        return true;
    }
    
   
    //copy LineItems To Quote
    public void copyLineItemsToQuote()
    {
        // delete any existing quote lines
        OpportunityLineItem[] olist;
        olist = [Select Id, OpportunityId, SortOrder, PricebookEntryId, Quantity, 
                 TotalPrice, UnitPrice, ListPrice, ServiceDate, DiscountPercent__c, Description, CreatedDate, 
                 CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
                 IsDeleted , PricebookEntry.Name, PricebookEntry.Product2id
                 From OpportunityLineItem 
                 where OpportunityId = :quote.Opportunity__c ];
        
        // create new quote lines
        Quote_Line__c[] qlines = new list<Quote_Line__c>(); 
        for ( OpportunityLineItem oitem : olist) 
        {
            Quote_Line__c ql = new Quote_Line__c(
                Quote__c = quote.id,
                Discount_Percent__c = oitem.DiscountPercent__c,
                Quantity__c = oitem.Quantity,
                Unit_Price__c = oitem.UnitPrice,
                Product__c = oitem.PricebookEntry.Product2id
            ); 
            qlines.add(ql);     
        }
        
        delete quote.Quote_Lines__r; 
        if ( qlines.size() > 0 ) 
        {
            insert qlines;
        }
    }
    
    public Decimal priceForVXPurchase
    {
        get
        {
            Decimal result = 0;
            for(Quote_Line__c line : quote.Quote_Lines__r)
            {
                result += line.Line_Price__c * (line.Product__r.Virtual_Discount__c == null ? 1 : line.Product__r.Virtual_Discount__c/100);
            }
            return result;
        }
    }
    
    public Decimal priceForVXSubscription
    {
        get
        {
            Decimal result = 0;
            for(Quote_Line__c line : quote.Quote_Lines__r)
            {
                result += line.Line_Price__c * (line.Product__r.Subscription_Discount__c == null ? 1 : line.Product__r.Subscription_Discount__c/100);
            }
            return result;
        }
    }
    
    public class LineItemGroup
    {
        public LineItemGroup()
        {
            items = new List<LineItem>();
        }
        
        public String label { get; set; }
        public List<LineItem> items { get; set; }
        public Decimal subtotal
        {
            get
            {
                Decimal result = 0;
                for(LineItem item : this.items)
                {
                    result += item.record.Line_Price__c;
                }
                return result;
            }
        }
    }
    
    //each line item object is a row in the editquoteline page
    @testvisible
    public class LineItem
    {
        public Quote_Line__c record {get;set;}
        public Boolean NotDiscountable { get; set; }
        public String amountCurrency {get;set;}
        public Decimal amount {get;set;}
        public Integer index {get;set;}
        public Boolean needUpdate {get;set;}
        public PricebookEntry price {get;set;}        
    }
}