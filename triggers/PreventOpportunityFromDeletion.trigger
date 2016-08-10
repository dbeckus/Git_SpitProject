/*
 * Only allows admin users to delete opps.
 */
trigger PreventOpportunityFromDeletion on Opportunity (before delete) 
{
    User currentUser = [select Id, Profile.PermissionsModifyAllData, Profile.PermissionsCustomizeApplication from User where Id=:UserInfo.getUserId() limit 1];
    Boolean isAdmin = currentUser.Profile.PermissionsModifyAllData && currentUser.Profile.PermissionsCustomizeApplication;
    if(!isAdmin)
    {
        for(Opportunity opp : Trigger.old)
        {
            opp.addError('You are not allowed to delete opportunities.');
        }
    }
}