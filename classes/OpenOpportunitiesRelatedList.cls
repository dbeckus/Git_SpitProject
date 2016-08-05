public class OpenOpportunitiesRelatedList {
    private  final Account acctId;
    public List<Opportunity> OpenOppsList {get;set;}
    public List<Opportunity> RenewalOppsList {get;set;}
    public List<Lead> PendingDealReg {get;set;}
    private String pageName;
    public OpenOpportunitiesRelatedList(ApexPages.StandardController stdController)
    {
         acctId=(Account) stdController.getRecord();
        pageName=getPageName(ApexPages.currentPage().getUrl());
        if(pageName=='ShowOpenOppRelatedListToPartner')
        { OpenOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name from opportunity where Registering_Partner__c=:acctId.Id and Type in ('New Business','Follow on Business')and IsClosed=false];
        
        }
        if(pageName=='ShowRenewalOppRelatedListToPartner')
        {
            RenewalOppsList=[Select Id,Name,CloseDate,Owner.Name,StageName,Amount,ForecastCategoryName,Registering_Partner__r.Name,Registering_Partner_Sales_Rep__r.Name,Next_Step_Reporting__c from opportunity where Registering_Partner__c=:acctId.Id and Type = 'Support Renewal' and IsClosed=false];
        }
        if(pageName=='ShowPendingDealRegToPartner')
        {
            PendingDealReg=[Select Id,Name,Company,Registered_Partner__r.Name,Registered_Partner_Sales_Rep__r.Name,Status,RSM__r.Name,CSM__r.Name,Registration_Expiration__c,Deal_ID__c from Lead where Registered_Partner__c=:acctId.Id and Status in ('Draft','Submitted') and LeadSource='Deal Registration'];
            
        }
       
        
    }
    
    private String getPageName(String url)
    {
        pageName='';
        if(url!=null && url.indexOf('/apex/') != -1)
        {
            if(url.indexOf('?') != -1 )
            {
                pageName=url.subString(url.indexOf('/apex/')+6,url.indexOf('?'));
            }
            else 
            {
                pageName=url.subString(url.indexOf('/apex/')+6);
            }
        }
        return pageName;
    }

}