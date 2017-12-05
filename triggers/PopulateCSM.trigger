/*
* Populates CSM and RSM to MDF request when portal user did create/update
* 
* @ChangeLog 9/19/2016 Share MDF Owner access to MDF CAM
* 23MAY2017 - only invoke udpateCSM method on before insert - allows employee users to update after submitted by partner
* 26MAY2017 - removed before insert and updateCSM method - moved to CreatePurchasingRequests.tgr to resolve bug
*/
trigger PopulateCSM on MDF_Request__c (before insert, before update, after insert, after update) 
{
    if(Trigger.new.size() == 1)
    {
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