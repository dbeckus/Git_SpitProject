public  class QuoteHelper {

    public static Opportunity SetOpportunityProductTypeToNone(Quote__c quoteDtl)
    {
        
        Opportunity oppToUpdate = new Opportunity(Id=quoteDtl.Opportunity__c);
        oppToUpdate.Product_Type__c='';
       return oppToUpdate;
    }  
   
    public static List<Quote__c> GetPrimaryQuote(Id oppId)
    {
        List<Quote__c> lstQuote=[Select Id from Quote__c where Opportunity__c=:oppId and Primary__c=true];
        return lstQuote;
    }
   
    public static Opportunity SetOpportunityProductType(Quote__c quoteDtl)
    {
        string oppProductType;
        integer ecProduct=0;
        integer spProduct=0;
        integer nonEcProduct=0;
        List<Quote_Line__c> quoteLineLst = [Select Id, Product__r.Name, Product__r.Product_Type__c From Quote_Line__c where quote__c = :quoteDtl.Id];
        if(quoteLineLst!=null && quoteLineLst.size()>0)
        {
            for(Quote_Line__c item: quoteLineLst)
            {
                string prodName= item.Product__r.Name;
                if(prodName.startsWith('EC') && item.Product__r.Product_Type__c=='EDGECONNECT')
                {ecProduct++;}
              	else if(prodName.startsWith('EC')&& (item.Product__r.Product_Type__c=='EC-SP-Perpetual'||item.Product__r.Product_Type__c=='EC-SP-Metered'))
                {spProduct++;}
                else if(!prodName.startsWith('EC'))
                {nonEcProduct++;}
                
            }
        }
        if((ecProduct>0 && ecProduct==quoteLineLst.size())|| (ecProduct>0 && nonEcProduct>0))
        { oppProductType='EDGECONNECT';  }
        else  if(spProduct>0 && spProduct==quoteLineLst.size())
        { oppProductType='EC-SP';  }
        else if(nonEcProduct>0 && nonEcProduct==quoteLineLst.size())
        { oppProductType='NX/VX';}
        else
        {oppProductType='';}
        Opportunity oppToUpdate = new Opportunity(Id=quoteDtl.Opportunity__c);
        oppToUpdate.Product_Type__c=oppProductType;
        return oppToUpdate;
       
    }
}