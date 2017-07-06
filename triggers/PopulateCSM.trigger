/*
* Populates CSM and RSM to MDF request when portal user did create/update
* 
* @ChangeLog 9/19/2016 Share MDF Owner access to MDF CAM
*/
trigger PopulateCSM on MDF_Request__c (before insert, before update, after insert, after update) 
{
    if(Trigger.new.size() == 1)
    {
        if(Trigger.isBefore)
        {
            //if(Trigger.isInsert || (Trigger.isUpdate && addressChanged(Trigger.new[0], Trigger.old[0])))
            {
                updateCSM(Trigger.new[0]);
            }   
        }
        // Share MDF Owner access to MDF CAM
        if(Trigger.isAfter)
        {
            if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.new[0].OwnerId != Trigger.old[0].OwnerId || Trigger.new[0].CSM__c != Trigger.old[0].CSM__c || Trigger.new[0].RSM__c != Trigger.old[0].RSM__c)))
            {   
                MDF_Request__Share mdfShare = new MDF_Request__Share(ParentId = Trigger.new[0].Id, UserOrGroupId = Trigger.new[0].CSM__c, AccessLevel = 'Edit');
                Database.insert(mdfShare, false);
            }
        }
    }
    
    /*private Boolean addressChanged(MDF_Request__c request, MDF_Request__c oldRequest)
    {
        return request.Event_Location_Country__c != oldRequest.Event_Location_Country__c || 
            request.Event_Location_State__c != oldRequest.Event_Location_State__c || 
            request.Event_Location_Zip__c != oldRequest.Event_Location_Zip__c || 
            request.Account__c != oldRequest.Account__c;
    }*/
    
    private void updateCSM(MDF_Request__c request)
    {
        List<Account> accs = [select Id, Name, Patch__r.CSM__c, Patch__r.RSM__c from Account where Id=:request.Account__c limit 1];
        /*String accName = (accs.size() > 0) ? accs[0].Name : '';
        PatchRuleEngine.Target target = getMatchTarget(request, accName);
        Id patchId = PatchRuleEngine.match(target);
        List<Patch__c> patch = [select Id, CSM__c, RSM__c from Patch__c where Id=:patchId limit 1];*/
        if(accs.size() > 0)
        {
            request.CSM__c = accs[0].Patch__r.CSM__c;
            request.RSM__c = accs[0].Patch__r.RSM__c;
        }
    }
    
    /*private PatchRuleEngine.Target getMatchTarget(MDF_Request__c request, String accountName)
    {
        PatchRuleEngine.Target target = new PatchRuleEngine.Target();
        target.Company = accountName;
        target.Country = request.Event_Location_Country__c;
        target.State = request.Event_Location_State__c;
        target.ZipCode = request.Event_Location_Zip__c;
        return target;
    }*/
}