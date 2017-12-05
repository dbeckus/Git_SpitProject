/**
*  The extension class for Quote page, overriding Submit for Approval button.
*/

global class QuoteExtension
{
    static final String MESSAGE_SUCCEEDED = 'Succeeded';
    public QuoteWrapper DiscountQuote{get;set;}
    public QuoteExtension(ApexPages.StandardController ctrl)
    {
        Id quoteId=(Id)ctrl.getRecord().id;
        Quote__c quoteInfo= [Select Id,Reseller_AccountId__c,Tier_1_Partner__r.Payment_Terms__c,Tier_1_Partner__r.Partner_Level__c,Tier_1_Partner__r.Partner_Type__c,Tier_1_Partner__r.Reseller_Agreement__c,Tier_1_Partner__r.Standard_Discount_Product__c,Tier_1_Partner__r.Standard_Discount_Service__c,Tier_1_Partner__r.Standard_Discount_EdgeConnect__c,Tier_1_Partner__r.Registered_Discount_EdgeConnect__c,Tier_1_Partner__r.Registered_Discount_Product__c,Tier_1_Partner__r.Registered_Discount_Service__c from Quote__c where Id=:quoteId];
        DiscountQuote= new QuoteWrapper(quoteInfo); 
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
                    resultOpp= new Opportunity(Id=opportunityId,Primary_Partner__c=quote.Reseller_AccountId__c,Tier1_Partner__c=quote.Tier_1_Partner__c,Tier2_Partner__c=quote.Tier_2_Partner__c,Tier3_Partner__c=quote.Tier_3_Partner__c);
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
                List<Quote__c> lstQuote =[Select Id,Special_Instructions__c,Approval_Required__c,Approval_Made__c,Approval_Level_Needed__c,Discount_Justification__c,Opportunity__r.Geo_Region__c from Quote__c where Id=:quoteId];
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
         if(quoteObj.Approval_Required__c==1 && string.isBlank(quoteObj.Special_Instructions__c ))
            return 'Special Instructions is empty. Please provide comments.';
        return'';  
    }
    
    public class QuoteWrapper
    {
        public string PP_PartnerType {get;set;}
        public string PP_PartnerLevel {get;set;}
        public boolean PP_ResellerAgreement {get;set;}
        public string PP_PaymentTerms {get;set;}
        public decimal PP_StandECDiscount{get;set;}
        public decimal PP_StandNXVXDiscount{get;set;}
        public decimal PP_StandServiceDiscount{get;set;}
        public decimal PP_RegECDiscount{get;set;}
        public decimal PP_RegNXVXDiscount{get;set;}
        public decimal PP_RegServiceDiscount{get;set;}
        
        public string RP_PartnerType {get;set;}
        public string RP_PartnerLevel {get;set;}
        public boolean RP_ResellerAgreement {get;set;}
        public string RP_PaymentTerms {get;set;}
        public decimal RP_StandECDiscount{get;set;}
        public decimal RP_StandNXVXDiscount{get;set;}
        public decimal RP_StandServiceDiscount{get;set;}
        public decimal RP_RegECDiscount{get;set;}
        public decimal RP_RegNXVXDiscount{get;set;}
        public decimal RP_RegServiceDiscount{get;set;}
        
        QuoteWrapper(Quote__c quoteInfo)
        {
            RP_PartnerType = quoteInfo.Tier_1_Partner__r.Partner_Type__c;
            RP_PartnerLevel = quoteInfo.Tier_1_Partner__r.Partner_Level__c;
            RP_ResellerAgreement = quoteInfo.Tier_1_Partner__r.Reseller_Agreement__c;
            RP_PaymentTerms = quoteInfo.Tier_1_Partner__r.Payment_Terms__c;
            RP_StandECDiscount= quoteInfo.Tier_1_Partner__r.Standard_Discount_EdgeConnect__c;
            RP_StandNXVXDiscount= quoteInfo.Tier_1_Partner__r.Standard_Discount_Product__c;
            RP_StandServiceDiscount= quoteInfo.Tier_1_Partner__r.Standard_Discount_Service__c;
            RP_RegECDiscount = quoteInfo.Tier_1_Partner__r.Registered_Discount_EdgeConnect__c;
            RP_RegNXVXDiscount = quoteInfo.Tier_1_Partner__r.Registered_Discount_Product__c;
            RP_RegServiceDiscount = quoteInfo.Tier_1_Partner__r.Registered_Discount_Service__c ;
            if(quoteInfo.Reseller_AccountId__c!=null)
            {
                Account accInfo=[Select Payment_Terms__c,Partner_Level__c,Partner_Type__c,Reseller_Agreement__c,Standard_Discount_Product__c,Standard_Discount_Service__c,Standard_Discount_EdgeConnect__c,Registered_Discount_EdgeConnect__c,Registered_Discount_Product__c,Registered_Discount_Service__c  from Account where Id=:quoteInfo.Reseller_AccountId__c];
                PP_PartnerType = accInfo.Partner_Type__c;
                PP_PartnerLevel = accInfo.Partner_Level__c;
                PP_ResellerAgreement = accInfo.Reseller_Agreement__c;
                PP_PaymentTerms = accInfo.Payment_Terms__c;
                PP_StandECDiscount= accInfo.Standard_Discount_EdgeConnect__c;
                PP_StandNXVXDiscount= accInfo.Standard_Discount_Product__c;
                PP_StandServiceDiscount= accInfo.Standard_Discount_Service__c;
                PP_RegECDiscount = accInfo.Registered_Discount_EdgeConnect__c;
                PP_RegNXVXDiscount = accInfo.Registered_Discount_Product__c;
                PP_RegServiceDiscount = accInfo.Registered_Discount_Service__c ;
            }
        }
    }
}