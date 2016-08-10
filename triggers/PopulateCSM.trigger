/*
 * Populates CSM and RSM to MDF request when portal user did create/update
 */
trigger PopulateCSM on MDF_Request__c (before insert, before update) 
{
    if(Trigger.new.size() == 1)
    {
        if(Trigger.isInsert || (Trigger.isUpdate && addressChanged(Trigger.new[0], Trigger.old[0])))
        {
            updateCSM(Trigger.new[0]);
        }
    }
    
    private Boolean addressChanged(MDF_Request__c request, MDF_Request__c oldRequest)
    {
        return request.Event_Location_Country__c != oldRequest.Event_Location_Country__c || 
                request.Event_Location_State__c != oldRequest.Event_Location_State__c || 
                request.Event_Location_Zip__c != oldRequest.Event_Location_Zip__c;
    }
    
    private void updateCSM(MDF_Request__c request)
    {
        PatchRuleEngine.Target target = getMatchTarget(request);
        Id patchId = PatchRuleEngine.match(target);
        List<Patch__c> patch = [select Id, CSM__c, RSM__c from Patch__c where Id=:patchId limit 1];
        if(patch.size() > 0)
        {
            request.CSM__c = patch[0].CSM__c;
            request.RSM__c = patch[0].RSM__c;
        }
    }
    
    private PatchRuleEngine.Target getMatchTarget(MDF_Request__c request)
    {
        PatchRuleEngine.Target target = new PatchRuleEngine.Target();
        target.Country = request.Event_Location_Country__c;
        target.State = request.Event_Location_State__c;
        target.ZipCode = request.Event_Location_Zip__c;
        return target;
    }
}