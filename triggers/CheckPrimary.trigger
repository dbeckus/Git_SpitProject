/*
 * Enforces only 1 quote can be checked primary
 */
trigger CheckPrimary on Quote__c (after insert, after update) 
{
    Set<Id> primaryQuotes = new Set<Id>();
    Set<Id> oppIds = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Quote__c qt : Trigger.new)
        {
            if(qt.Primary__c && qt.Opportunity__c != null)
            {
                primaryQuotes.add(qt.Id);
                oppIds.add(qt.Opportunity__c);
            }
        }
        
    }
    else if(Trigger.isUpdate)
    {
        for(Quote__c qt : Trigger.new)
        {
            Quote__c oldQuote = Trigger.oldMap.get(qt.Id);
            if(qt.Primary__c && !oldQuote.Primary__c && qt.Opportunity__c != null)
            {
                primaryQuotes.add(qt.Id);
                oppIds.add(qt.Opportunity__c);
            }
        }
    }
    
    if(primaryQuotes.size() > 0)
    {
        List<Quote__c> existingPrimaryQuotes = [Select Id from Quote__c where Opportunity__c in :oppIds and Primary__c=true];
        for(Quote__c existingPrimaryQuote : existingPrimaryQuotes)
        {
            if(!primaryQuotes.contains(existingPrimaryQuote.Id))
            {
                existingPrimaryQuote.Primary__c = false;
            }
        }
        try
        {
            update existingPrimaryQuotes;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
}