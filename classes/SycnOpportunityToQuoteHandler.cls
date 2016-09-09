public class SycnOpportunityToQuoteHandler {    
    public static void sycnOpportunityDateToQuoteDateOnUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap)
    {
        Opportunity oldOpp;
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity newOpp : newMap.values())
        {
            oldOpp = oldMap.get(newOpp.Id);
            if(oldOpp.Contract_Activation_Date__c != newOpp.Contract_Activation_Date__c || oldOpp.Closedate != newOpp.CloseDate)
            {
                oppIds.add(newOpp.Id);
            }
        }
        
        if(!oppIds.isEmpty())
        {
         	sycnDate(oppIds);   
        }
    }
    
    private static void sycnDate(Set<Id> oppIds)
    {
        List<SBQQ__Quote__c> quotes = [select Id, SBQQ__StartDate__c, SBQQ__Opportunity2__r.Contract_Activation_Date__c, SBQQ__Opportunity2__r.CloseDate from SBQQ__Quote__c where SBQQ__Opportunity2__c in :oppIds and SBQQ__Primary__c = true];
        if(!quotes.isEmpty())
        {
            for(SBQQ__Quote__c quote : quotes)
            {
                if(quote.SBQQ__Opportunity2__r.Contract_Activation_Date__c != null)
                {
                    quote.SBQQ__StartDate__c = quote.SBQQ__Opportunity2__r.Contract_Activation_Date__c;
                }
                else
                {
                    quote.SBQQ__StartDate__c = quote.SBQQ__Opportunity2__r.CloseDate;
                }
            }  
            update quotes;
        }
    }
}