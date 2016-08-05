/*
 * Certain areas of rma item shouldn't be dispatched.
 * This trigger updates rma item when RMA is dispatched to enforce 
 *a workflow on rma item be fired and dispatch the rma if certain criteria is met.
 */
trigger DispatchRMAItem on RMA__c (after update) 
{
    List<RMA_Item__c> items = new List<RMA_Item__c>();
    for(RMA__c rma : Trigger.new)
    {
        RMA__c oldRMA = Trigger.oldMap.get(rma.Id);
        if(rma.Status__c == 'Dispatched' && oldRMA.Status__c != 'Dispatched')
        {
            items.addAll([select Id from RMA_Item__c where RMA__c=:rma.Id]);
        }
    }
    if(items.size() > 0)
    {
        update items;
    }
}