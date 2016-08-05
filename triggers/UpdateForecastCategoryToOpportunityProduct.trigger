/* 
 * When adding products to opp, updates the ForecastCategory to opp line item
 */
trigger UpdateForecastCategoryToOpportunityProduct on OpportunityLineItem (before insert) 
{
    Map<Id, Id> pbentryId2prodId = new Map<Id, Id>();
    Map<Id, String> productId2ForecastCategory = new Map<Id, String>();
    Set<Id> pbentryIds = new Set<Id>();
    for(OpportunityLineItem item : Trigger.new)
    {
        pbentryIds.add(item.PricebookEntryId);
    }
    for(PricebookEntry entry : [select Id, Product2Id from PricebookEntry where Id in :pbentryIds])
    {
        pbentryId2prodId.put(entry.Id, entry.Product2Id);
    }
    
    for(Product2 prd : [select Id, Forecast_Category__c from Product2 where Id in :pbentryId2prodId.values()])
    {
        productId2ForecastCategory.put(prd.Id, prd.Forecast_Category__c);
    }
    
    for(OpportunityLineItem item : Trigger.new)
    {
        Id prodId = pbentryId2prodId.get(item.PricebookEntryId);
        item.Forecast_Category__c = productId2ForecastCategory.get(prodId);
    }
}