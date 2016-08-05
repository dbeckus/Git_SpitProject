/**
 * update RMA status value from "Dispatch Rejected" to "Dispatch" when product of RMA Item is changed.
 */
trigger UpdateRMAStatus on RMA_Item__c (after update) 
{
    List<RMA__c> rmas = new List<RMA__c>();
    Set<Id> rmaIds = new Set<Id>();
    for(RMA_Item__c item : trigger.new)
    {
        rmaIds.add(item.RMA__c);
    }
    List<RMA__c> relatedRMAs = [select Id, Status__c,Lock_Dispatch_Shipment__c from RMA__c where Id in :rmaIds];
    
    Map<Id, RMA__c> Id2RMA = new Map<Id, RMA__c>();
    for(RMA__c rma : relatedRMAs)
    {
        Id2RMA.put(rma.Id, rma);
    }
    
    for(RMA_Item__c item : trigger.new)
    {
        RMA_Item__c oldItem = trigger.oldMap.get(item.Id);
        RMA__c rma = Id2RMA.get(item.RMA__c);
        
        if(oldItem.Product2__c != null && oldItem.Product2__c != item.Product2__c && rma.Status__c == 'Dispatch Rejected' && !rma.Lock_Dispatch_Shipment__c)
        {
            rma.Status__c = 'Dispatched';
            rmas.add(rma);
        }
    }
    if(rmas.size() > 0)
    {
        update rmas;
    }
}