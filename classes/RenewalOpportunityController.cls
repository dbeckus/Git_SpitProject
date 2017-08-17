/*
 * Controller of page RenwalOpportunity
 */
public class RenewalOpportunityController 
{
    private List<Product2> AllRenewalProducts;
    
    public RenewalOpportunityController(ApexPages.StandardController controller) 
    {
        opp = (Opportunity)controller.getRecord();
        Opportunity oldOpp = [Select Id, Pricebook2Id,Product_Type__c,Account.ECSP__c from Opportunity where Id =:opp.Id];
        List<Product2> products=null;
        
        if(oldOpp.Product_Type__c=='NX/VX')
            products = [select Id, Name, ProductCode from Product2 where Is_Renewal__c=1 and Product_Type__c='NX/VX' and IsActive = true];
        else if(oldOpp.Product_Type__c=='EDGECONNECT')
            products = [select Id, Name, ProductCode from Product2 where Is_Renewal__c=1 and Product_Type__c='EDGECONNECT' and IsActive = true];
        else if(oldOpp.Product_Type__c=='EC-SP')
            products = [select Id, Name, ProductCode from Product2 where Is_Renewal__c=1 and Product_Type__c in('EC-SP-Perpetual','EC-SP-Metered','EC-SP-Term') and IsActive = true];
        else if(oldOpp.Account.ECSP__c)
            products = [select Id, Name, ProductCode from Product2 where Is_Renewal__c=1 and IsActive = true and Product_Type__c in('EC-SP-Perpetual','EC-SP-Metered','EC-SP-Term')];
        else
            products = [select Id, Name, ProductCode from Product2 where Is_Renewal__c=1 and IsActive = true and Product_Type__c in('NX/VX','EDGECONNECT')];
        Map<String, Id> prdCode2prdId = new Map<String, Id>();
        for(Product2 prd : products)
        {
            prdCode2prdId.put(prd.ProductCode, prd.Id);
        }
        AllRenewalProducts = [select Id, Name, ProductCode, Description from Product2 where Id in :prdCode2prdId.values() order by Name];
        
        
        opp.Name += ' MR ' + (opp.CloseDate.year() + 1);
        opp.CloseDate = opp.CloseDate.addYears(1);
        opp.Type = 'Support Renewal';
        opp.StageName = 'Renewal';
        opp.Opportunity_Source__c='';
        opp.ForecastCategoryName = 'Commit';
        opp.Probability = 50;
        
        
        opp.Pricebook2Id = oldOpp.Pricebook2Id;
        
        try
        {
            opp.RecordTypeId = Schema.sObjectType.Opportunity.getRecordTypeInfosByName().get('Maintenance').getRecordTypeId();
        }
        catch(Exception ex)
        {}
        
        List<Pricebook2> pricebook = [select Id from Pricebook2 where Id =:opp.Pricebook2Id];
        
        if(pricebook.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'No Pricebook is associate with the Parent Opportunity'));
        }
        else
        {  
            pricebookId = pricebook[0].Id;
            
            NewProducts = new List<ProductInfo>();
            List<OpportunityLineItem> oppLines = [select Id, PriceBookEntry.Product2Id, PriceBookEntry.Product2.ProductCode, PriceBookEntry.Product2.Name, Quantity, UnitPrice, ListPrice, 
                                                  PriceBookEntry.Product2.Family, PriceBookEntry.Product2.IsActive, Description from OpportunityLineItem where OpportunityId = :opp.Id 
                                                  and PricebookEntry.Product2.IsActive = true];
            Map<Id, OpportunityLineItem> productId2OpportunityLineItem = new Map<Id, OpportunityLineItem>();
            if(!oppLines.IsEmpty())
            {
                for(OpportunityLineItem line : oppLines)
                {
                    String productCode = line.PriceBookEntry.Product2.ProductCode;
                    Id productId = null; 
                    for(Product2 prd : AllRenewalProducts)
                    {
                        if(prd.ProductCode == productCode + 'R' || prd.ProductCode == productCode)
                        {
                            productId = prd.Id;
                            break;
                        }
                    }
                    productId2OpportunityLineItem.put(productId, line);
                }
                productId2OpportunityLineItem.remove(null);
                Map<Id, Decimal> productId2UnitPrice = new Map<Id, Decimal>();
                Map<Id, Boolean> productId2Discountable = new Map<Id, Boolean>();
                for(PricebookEntry entry : [select Id, Product2Id,Product2.Not_Discountable__c, UnitPrice from PricebookEntry where Pricebook2Id = :pricebookId and Product2Id in :productId2OpportunityLineItem.keySet()])
                {
                    productId2UnitPrice.put(entry.Product2Id, entry.UnitPrice);
                    productId2Discountable.put(entry.Product2Id,entry.Product2.Not_Discountable__c);
                }
                
                for(Id productId : productId2OpportunityLineItem.keySet())
                {
                    OpportunityLineItem oppLineItem = productId2OpportunityLineItem.get(productId);
                    Decimal unitPrice = productId2UnitPrice.get(productId);
                    Boolean isNotDiscountable=productId2Discountable.get(productId);
                    if(unitPrice != null) 
                    {
                        decimal finalAmt =!isNotDiscountable?(unitPrice * getDiscountFromOpportunityLineItem(oppLineItem)):unitPrice;
                        NewProducts.add(new ProductInfo(productId, oppLineItem.Quantity, finalAmt.setScale(2)));
                    }
                }
            }
        }
    }
    
    public Opportunity opp { get; set; }
    public Opportunity NewOpp { get; set; }
    public List<ProductInfo> NewProducts { get; set; }
    public Id pricebookId { get; set; }
    
    public List<SelectOption> ProductOptions 
    { 
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            for(Product2 prd : AllRenewalProducts)
            {
                String label = prd.Name + ': ' + prd.Description;
                if(label.length() > 60)
                {
                    label = label.substring(0, 60) + '...';
                }
                options.add(new SelectOption(prd.Id, label));
            }
            return options;
        }
    }
    
    public PageReference save()
    {
        if(validateInput())
        {
            SavePoint sp = Database.setSavePoint();
            try
            {
                NewOpp = opp.clone(false, false, false, false);
                if(NewOpp.Type=='Subscription Renewal' || NewOpp.Type=='EC Renewal' )
                {
                    NewOpp.RecordTypeId='012500000005bUb';
                }
                if(NewOpp.Type=='Support Renewal')
                {
                    NewOpp.RecordTypeId='012500000005bUg';
                }
                insert NewOpp;
                
                update (new Opportunity(Id = opp.Id, RenewedOpportunity__c = NewOpp.Id));
                
                List<PricebookEntry> allEntries = [select Id, Product2Id, UnitPrice from PricebookEntry where Pricebook2Id = :pricebookId];
                List<PricebookEntry> newEntries = new List<PricebookEntry>();
                for(ProductInfo prdInfo : NewProducts)
                {
                    Boolean found = false;
                    
                    for(PricebookEntry entry : allEntries)
                    {
                        if(entry.Product2Id == prdInfo.ProductId)
                        {
                            found = true;
                            break;
                        }
                    }
                    
                    if(!found)
                    {
                        PricebookEntry newEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prdInfo.ProductId, UnitPrice = prdInfo.SalesPrice);
                        newEntries.add(newEntry);
                    }
                }
                insert newEntries;
                
                allEntries = [select Id, Product2Id, UnitPrice from PricebookEntry where Pricebook2Id = :pricebookId];
                List<OpportunityLineItem> newItems = new List<OpportunityLineItem>();
                for(ProductInfo prdInfo : NewProducts)
                {
                    for(PricebookEntry entry : allEntries)
                    {
                        if(entry.Product2Id == prdInfo.ProductId)
                        {
                            newItems.add(prdInfo.createLineItem(NewOpp.Id, entry.Id, 0, prdInfo.SalesPrice, prdInfo.Quantity));
                            break;
                        }
                    }
                }
                upsert newItems;
                
                return new PageReference('/' + NewOpp.Id);
            }
            catch(Exception e)
            {
                Database.rollback(sp);
                ApexPages.addMessages(e);
                
                return null;
            }
        }
        return null;
    }
    
    public PageReference addProduct()
    {
        ProductInfo prd = new ProductInfo(AllRenewalProducts.get(0).Id, 0, 0);
        NewProducts.add(prd);
        
        return null;
    }
    
    public PageReference delProduct()
    {
        String index = ApexPages.currentPage().getParameters().get('index');
        try
        {
            NewProducts.remove(Integer.valueOf(index));
        }
        catch(Exception ex)
        {
        }
        return null;
    }
    
    @RemoteAction
    public static String getProductCode(String productId)
    {
        if(productId instanceOf Id)
        {
            List<Product2> prds = [select Id, Name, ProductCode from Product2 where Id=:productId limit 1];
            if(prds.size() > 0)
            {
                return prds[0].ProductCode;
            }
        }
        return null;
    }
    
    private Boolean validateInput()
    {
        for(ProductInfo prdInfo : NewProducts)
        {
            if(prdInfo.Quantity == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Product quantity cannot be zero.'));
                return false;
            }
        }
        return true;
    }
    
    private Decimal getDiscountFromOpportunityLineItem(OpportunityLineItem line)
    {
        if(line.UnitPrice >= line.ListPrice)
        {
            return 0.77;
        }
        else
        {
            return line.UnitPrice / line.ListPrice;
        }
    } 
    
    public class ProductInfo
    {
        public ProductInfo(Id productId, Decimal qty, Decimal price)
        {
            this.ProductId = productId;
            this.Quantity = qty;
            this.SalesPrice = price;
        }
        
        public Id ProductId { get; set; }
        public String ProductCode 
        { 
            get
            {
                return RenewalOpportunityController.getProductCode(ProductId);
            }
        }
        public String Description { get; set; }
        public Decimal Quantity { get; set; }
        public Decimal SalesPrice { get; set; }
        
        public OpportunityLineItem createLineItem(Id oppId, Id pricebookId, Decimal discount, Decimal unitPrice, Decimal qty)
        {
            return new OpportunityLineItem(OpportunityId = oppId, PriceBookEntryId = pricebookId, UnitPrice = unitPrice, Quantity = qty);
        }
    }
}