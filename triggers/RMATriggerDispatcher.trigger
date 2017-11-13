trigger RMATriggerDispatcher on RMA__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
TriggerDispatcher.Run(new RMATriggerHandler());
}