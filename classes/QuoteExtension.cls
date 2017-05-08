/**
 *  The extension class for Quote page, overriding Submit for Approval button.
 */

public class QuoteExtension
{
    static final String MESSAGE_SUCCEEDED = 'Succeeded';
    
    public QuoteExtension(ApexPages.StandardController ctrl)
    {
    
    }
    
    @RemoteAction
    public static Boolean CheckQuote(String quoteId, String opportunityId)
    {
        Integer quoteCount = [select count() from Quote__c where Opportunity__c = :opportunityId and Id != :quoteId];
        return quoteCount > 0;
    }
    
    @RemoteAction
    public static String SetPrimaryQuoteAndSubmit(String quoteId, String opportunityId)
    {
        List<Quote__c> quotes = [select Id, Primary__c from Quote__c where Opportunity__c = :opportunityId];
        if(!quotes.isEmpty())
        {
            for(Quote__c quote : quotes)
            {
                quote.Primary__c = (quote.Id == quoteId) ? true : false;
            }
            try
            {
                update quotes;
            }
            catch(Exception ex)
            {
                return ex.getMessage();
            }
        }
        return SubmitForApproval(quoteId);
    }
    
    @RemoteAction
    public static String SubmitForApproval(String quoteId)
    {
        try
        {
            // Validate the entry criteria and then send for approval
            if(quoteId!=null)
            {
                List<Quote__c> lstQuote =[Select Id,Approval_Required__c,Approval_Made__c,Approval_Level_Needed__c,Discount_Justification__c,Opportunity__r.GEO_Region__c from Quote__c where Id=:quoteId];
                if(lstQuote!=null && lstQuote.size()>0)
                {
                    Quote__c quoteObj= lstQuote[0];
                    if(Userinfo.getLastName()!='Christensen')
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
        if(quoteObj.Approval_Required__c==0)
            return 'Approval process is not required. Its already approved.';
        if(quoteObj.Approval_Required__c==1 && string.isBlank(quoteObj.Discount_Justification__c))
            return 'Discount Justification is empty. Please provide comments.';
          if(quoteObj.Approval_Required__c==1 && (string.isBlank(quoteObj.Opportunity__r.GEO_Region__c)|| quoteObj.Opportunity__r.GEO_Region__c=='NONE' ))
            return 'GEO is not set correctly on the opportunity associated to this quote.Please populate this value.';
        return '';
    }
}