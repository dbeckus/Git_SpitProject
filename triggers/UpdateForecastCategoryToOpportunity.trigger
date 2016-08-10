/* 
 * If product.ForecastCategory is updated, updates it accordingly on Opportunity Products so that it roll-up summary to Opportunity correctly.
 */
trigger UpdateForecastCategoryToOpportunity on Product2 (after update) 
{
    Set<Id> productIds = new Set<Id>();
    for(Product2 prd : Trigger.new)
    {
        Product2 oldPrd = Trigger.oldMap.get(prd.Id);
        if(prd.Forecast_Category__c != oldPrd.Forecast_Category__c)
        {
            productIds.add(prd.Id);
        }
    }
    if(productIds.size() > 0)
    {
        List<Opportunity> opps = [select Id, (select Id, PricebookEntry.Product2.Forecast_Category__c from OpportunityLineItems) from Opportunity where Id in (select OpportunityId from OpportunityLineItem  where PricebookEntry.Product2Id in :productIds)];
        List<OpportunityLineItem> items = new List<OpportunityLineItem>();
        for(Opportunity opp : opps)
        {
            opp.Product_Forecast_Categories__c = '';
            for(OpportunityLineItem item : opp.OpportunityLineItems)
            {
                String productCategory = item.PricebookEntry.Product2.Forecast_Category__c;
                item.Forecast_Category__c = productCategory;
                items.add(item);
                if(productCategory != null && productCategory != '' && !opp.Product_Forecast_Categories__c.contains(productCategory))
                {
                    opp.Product_Forecast_Categories__c += productCategory + ';';
                }
            }
        }
        try
        {
            update items;
            update opps;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
}