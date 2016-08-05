/*
 * Add partner portal user to public groups for the content sharing.
 * Fires on user creation or activate/deactivate
 */
trigger AddPartnerPortalUserToPublicGroup on User (after insert, after update) 
{
    Set<Id> newUserIds = new Set<Id>();
    Set<Id> deactivateUserIds = new Set<Id>();

    if(trigger.IsInsert)
    {
        for(User userNew : Trigger.New)
        {
            if(userNew.UserType == 'PowerPartner' && userNew.IsActive)
            {
                newUserIds.add(userNew.Id);
            }
        }
    }

    if(trigger.IsUpdate)
    {
        for(User userNew : Trigger.New)
        {
            if(userNew.UserType == 'PowerPartner')
            {
                User userOld = trigger.oldMap.get(userNew.Id);
                if(userNew.IsActive && !userOld.IsActive)
                {
                    newUserIds.add(userNew.Id);
                }
                if(!userNew.IsActive && userOld.IsActive)
                {
                    deactivateUserIds.add(userOld.Id);
                }
            }
        }
    }

    PartnerPortalUserSharing.sharePortalUser(new List<Id>(newUserIds));
    PartnerPortalUserSharing.removeSharingPortalUser(new List<Id>(deactivateUserIds));
}