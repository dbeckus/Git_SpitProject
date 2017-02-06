/*
 * if oppty owner is a partner portal user, sets Opportunity.RegisteredParter to the account of the owner.
 */
trigger SetRegisteredPartnerEqualtoPartner on Opportunity (before insert, before update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<ID> userIds = new Set<ID>(); 
        for(Opportunity oppty : Trigger.new)
        {
            if(Trigger.isInsert)
            {
                userIds.add(oppty.OwnerId);
            }
            else if(Trigger.isUpdate)
            {
                Opportunity oldOppty = Trigger.oldMap.get(oppty.Id);
                if(oppty.OwnerId != oldOppty.OwnerId)
                {
                    //user is updating the owner
                    userIds.add(oppty.OwnerId);
                }
            }
        }
        
        if(userIds.size() > 0)
        {
            List<User> users = [select Id, ContactId, Contact.AccountId, UserType from User where Id in :userIds and UserType='PowerPartner'];
            for(Opportunity oppty : Trigger.new)
            {
                for(User user : users)
                {
                    if(user.Id == oppty.OwnerId && user.ContactId != null)
                    {
                        oppty.Registered_Partner__c = user.Contact.AccountId;
                        break;
                    }
                }
            }
        }
    }
}