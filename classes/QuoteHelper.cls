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
        integer nonEcProduct=0;
        List<Quote_Line__c> quoteLineLst = [Select Id, Product__r.Name From Quote_Line__c where quote__c = :quoteDtl.Id and Product__r.Family in ('Product','Virtual Image','Upgrade')];
        if(quoteLineLst!=null && quoteLineLst.size()>0)
        {
            for(Quote_Line__c item: quoteLineLst)
            {
                string prodName= item.Product__r.Name;
                if(prodName.startsWith('EC'))
                {ecProduct++;}
                if(!prodName.startsWith('EC'))
                {nonEcProduct++;}
                
            }
        }
        if(ecProduct>0 && ecProduct==quoteLineLst.size())
        { oppProductType='EDGECONNECT';  }
        else if(nonEcProduct>0 && nonEcProduct==quoteLineLst.size())
        {    oppProductType='NX/VX';}
        else if(ecProduct >0  && nonEcProduct >0) 
        {oppProductType='BOTH';}
        else
        {oppProductType='';}
        Opportunity oppToUpdate = new Opportunity(Id=quoteDtl.Opportunity__c);
        oppToUpdate.Product_Type__c=oppProductType;
        return oppToUpdate;
       
    }
}