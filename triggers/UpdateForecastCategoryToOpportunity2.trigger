/* 
 * Update Opp.ProductForecastCategories after new product is added to opportunity
 */
trigger UpdateForecastCategoryToOpportunity2 on OpportunityLineItem (after insert, after delete, after undelete) 
{
    Set<Id> oppIds = new Set<Id>();
    if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(OpportunityLineItem item : Trigger.new)
        {
            oppIds.add(item.OpportunityId);
        }
    }
    else if(Trigger.isDelete)
    {
        for(OpportunityLineItem item : Trigger.old)
        {
            oppIds.add(item.OpportunityId);
        }
    }
    
    if(oppIds.size() > 0)
    {
        List<Opportunity> opps = [select Id, (select Id, PricebookEntry.Product2.Forecast_Category__c from OpportunityLineItems) from Opportunity where Id in :oppIds];
        for(Opportunity opp : opps)
        {
            opp.Product_Forecast_Categories__c = '';
            for(OpportunityLineItem item : opp.OpportunityLineItems)
            {
                String productCategory = item.PricebookEntry.Product2.Forecast_Category__c;
                if(productCategory != null && productCategory != '' && !opp.Product_Forecast_Categories__c.contains(productCategory))
                {
                    opp.Product_Forecast_Categories__c += productCategory + ';';
                }
            }
        }
        try
        {
            update opps;
        }
        catch(Exception ex)
        {
            if(Trigger.isDelete)
            {
                Trigger.old[0].addError(ex.getMessage());
            }
            else
            {
                Trigger.new[0].addError(ex.getMessage());
            }
        }
    }
}