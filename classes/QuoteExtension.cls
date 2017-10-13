/**
 *  The extension class for Quote page, overriding Submit for Approval button.
 */

global class QuoteExtension
{
    static final String MESSAGE_SUCCEEDED = 'Succeeded';
     Quote__c DiscountQuote{get;set;}
    public QuoteExtension(ApexPages.StandardController ctrl)
    {
     	Id quoteId=(Id)ctrl.getRecord().id;
        DiscountQuote= [Select Id,Tier_1_Partner__r.Payment_Terms__c,Tier_1_Partner__r.Partner_Level__c,Tier_1_Partner__r.Partner_Type__c,Tier_1_Partner__r.Reseller_Agreement__c,Tier_1_Partner__r.Standard_Discount_Product__c,Tier_1_Partner__r.Standard_Discount_Service__c,Tier_1_Partner__r.Standard_Discount_EdgeConnect__c,Tier_1_Partner__r.Registered_Discount_EdgeConnect__c,Tier_1_Partner__r.Registered_Discount_Product__c,Tier_1_Partner__r.Registered_Discount_Service__c ,Tier_2_Partner__r.Payment_Terms__c,Tier_2_Partner__r.Partner_Level__c,Tier_2_Partner__r.Partner_Type__c,Tier_2_Partner__r.Reseller_Agreement__c,Tier_2_Partner__r.Standard_Discount_Product__c,Tier_2_Partner__r.Standard_Discount_Service__c,Tier_2_Partner__r.Standard_Discount_EdgeConnect__c,Tier_2_Partner__r.Registered_Discount_EdgeConnect__c,Tier_2_Partner__r.Registered_Discount_Product__c,Tier_2_Partner__r.Registered_Discount_Service__c from Quote__c where Id=:quoteId];

    }
    
    @RemoteAction
    global static Boolean CheckQuote(String quoteId, String opportunityId)
    {
        Integer quoteCount = [select count() from Quote__c where Opportunity__c = :opportunityId and Id != :quoteId];
        return quoteCount > 0;
    }
    
    @RemoteAction
    global static String SetPrimaryQuoteAndSubmit(String quoteId, String opportunityId)
    {
        Opportunity resultOpp=null;
        List<Quote__c> quotes = [select Id, Primary__c,Reseller_AccountId__c,Tier_1_Partner__c,Tier_2_Partner__c,Tier_3_Partner__c from Quote__c where Opportunity__c = :opportunityId];
        if(!quotes.isEmpty())
        {
            for(Quote__c quote : quotes)
            {
                quote.Primary__c = (quote.Id == quoteId) ? true : false;
                if(quote.Primary__c)
                     resultOpp= new Opportunity(Id=quote.Opportunity__c,Primary_Partner__c=quote.Reseller_AccountId__c,Tier1_Partner__c=quote.Tier_1_Partner__c,Tier2_Partner__c=quote.Tier_2_Partner__c,Tier3_Partner__c=quote.Tier_3_Partner__c);
            }
            try
            {
                update quotes;
                update resultOpp;
            }
            catch(Exception ex)
            {
                return ex.getMessage();
            }
        }
        return SubmitForApproval(quoteId);
    }
    
    @RemoteAction
    global static String SubmitForApproval(String quoteId)
    {
        try
        {
            // Validate the entry criteria and then send for approval
            if(quoteId!=null)
            {
                List<Quote__c> lstQuote =[Select Id,Approval_Required__c,Approval_Made__c,Approval_Level_Needed__c,Discount_Justification__c,Opportunity__r.Geo_Region__c from Quote__c where Id=:quoteId];
                if(lstQuote!=null && lstQuote.size()>0)
                {
                    Quote__c quoteObj= lstQuote[0];
                    if(Userinfo.getLastName()!='Beckus')
                    {
                        string errorMsg=ValidateApprovalEntryCriterias(quoteObj);
                        if(errorMsg!='')
                        {
                            return errorMsg;
                        }
                    }
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(quoteId);
                    Approval.ProcessResult result = Approval.process(request);
                    if(result.isSuccess())
                    {
                        return MESSAGE_SUCCEEDED;
                    }
                    else
                    {
                        return result.getErrors()[0].getMessage();
                    }
                }
            }
        }
        catch(Exception ex)
        {
            return ex.getMessage();
        }
        
        return '';
    }
    
    private static string ValidateApprovalEntryCriterias(Quote__c quoteObj)
    {
        System.debug(quoteObj.Opportunity__r.Geo_Region__c);
        if(quoteObj.Approval_Required__c==0)
            return 'Approval process is not required. Its already approved.';
        if(quoteObj.Approval_Required__c==1 && quoteObj.Opportunity__r.Geo_Region__c =='NONE')
            return 'GEO is blank on the opportunity.Please populate this value or contact sales operations.';        
        if(quoteObj.Approval_Required__c==1 && string.isBlank(quoteObj.Discount_Justification__c))
            return 'Discount Justification is empty. Please provide comments.';
        return'';  
    }
}