/*
 * Fulfill the POC request
 */
trigger FulfillVirtualRequest on Request__c (after insert) 
{
    for(Request__c request : Trigger.new)
    {
        if(request.IsAllVirtual__c == 1 && request.Auto_Fulfill__c == true)
        {
            VirtualPOCFulfillmentController pocController = new VirtualPOCFulfillmentController(new ApexPages.StandardController(request));
            pocController.isFromApex = true;
            if(request.Target_End_Date__c != null)
            {
                pocController.LicenseDurationDays = Date.today().daysBetween(request.Target_End_Date__c);
            }
            pocController.save();
        }
    }
}