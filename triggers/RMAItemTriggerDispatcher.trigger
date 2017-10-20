trigger RMAItemTriggerDispatcher on RMA_Item__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    TriggerDispatcher.Run(new RMAItemTriggerHandler());

}