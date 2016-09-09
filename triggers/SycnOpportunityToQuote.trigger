trigger SycnOpportunityToQuote on Opportunity (after update) {
    if(Trigger.isUpdate)
    {
        SycnOpportunityToQuoteHandler.sycnOpportunityDateToQuoteDateOnUpdate(Trigger.oldMap, Trigger.newMap);
    }
}