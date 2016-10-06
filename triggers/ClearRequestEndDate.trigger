trigger ClearRequestEndDate on Request__c (after update) {
    Set<Id> shippedExtendedPOC= new Set<Id>();
    for(Request__c request: Trigger.New)
    {
        Request__c oldRequest = Trigger.oldMap.get(request.Id);
        System.debug(request.Status__c);
        System.debug(request.Type__c);
        System.debug(request.Requested_End_Date__c);
        System.debug(request.First_Extension_Granted__c);
        if(request.Status__c == 'Shipped - Extended' && request.Type__c =='Evaluation' && request.Requested_End_Date__c!=null && (request.First_Extension_Granted__c || request.Second_Extension_Granted__c ) )
        {
            //removes the poc link on assets
            shippedExtendedPOC.add(request.Id);
        }
    }   
    
    if(shippedExtendedPOC.size()>0)
    {
        
        List<Request__c> modifiedPOC = [Select Id, Requested_End_Date__c,Target_End_Date__c from Request__c where Id=:shippedExtendedPOC];
        List<Request__c> lstFinalUpdate = new List<Request__c>();
        for(Request__c req: modifiedPOC )
        {
            if(req.Requested_End_Date__c == req.Target_End_Date__c)
                {
                    req.Requested_End_Date__c = null;
                    lstFinalUpdate.add(req);
                }
            
        }
        
        try
        {
            if(lstFinalUpdate.size()>0)
            { update lstFinalUpdate;}
           
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
}