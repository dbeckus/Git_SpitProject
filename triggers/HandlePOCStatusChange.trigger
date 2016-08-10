/*
 * If poc request status is changed to Returned or Closed-Won, unlink the poc and the assets
 * If poc request status is changed to Returned, close the EVAL RMA
 * If poc request status is changed to PendingReturn, create an EVAL RMA
 */
trigger HandlePOCStatusChange on Request__c (after update) 
{
     Set<Id> pendingReturnPocs = new Set<Id>();
     Set<Id> closedPocs = new Set<Id>();
     Set<Id> returnedPocs = new Set<Id>();
     Set<Id> datesChangedPocs = new Set<Id>();
     
     for(Request__c request : trigger.new)
     {
         Request__c oldRequest = Trigger.oldMap.get(request.Id);
         if((request.Status__c == 'Closed - Returned' || request.Status__c == 'Closed - Won') && request.Status__c != oldRequest.Status__c)
         {
             //removes the poc link on assets
             closedPocs.add(request.Id);
         }
         if(request.Status__c == 'Closed - Returned' && request.Status__c != oldRequest.Status__c)
         {
             //closes the RMA
             returnedPocs.add(request.Id);
         }
         if(request.Status__c == 'Pending Return' && request.Status__c != oldRequest.Status__c)
         {
             //creates eval RMA when request is not all virtual
             pendingReturnPocs.add(request.Id);
         }
         if(request.Target_End_Date__c != oldRequest.Target_End_Date__c)
         {
             //updates EvaluationEndDate on Assets to TargetEndDate on POC
             datesChangedPocs.add(request.Id);
         }
     }
     try
     {
         if(closedPocs.size() > 0)
         {
             PocRequestAutomationHelper.removePocLinkOnAsset(closedPocs);
         }
         if(pendingReturnPocs.size() > 0)
         {
             PocRequestAutomationHelper.createEvalRMA(pendingReturnPocs);
         }
         if(returnedPocs.size() > 0)
         {
             PocRequestAutomationHelper.closeRMAs(returnedPocs);
         }
         if(datesChangedPocs.size() > 0)
         {
             PocRequestAutomationHelper.updateAssetDate(datesChangedPocs);
         }
     }
     catch(PocRequestAutomationHelper.PocRequestAutomationException ex)
     {
         for(Request__c request : Trigger.new)
         {
             request.addError(ex.getMessage());
         }
     }
}