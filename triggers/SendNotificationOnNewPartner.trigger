/*
 * When a new partner portal user is created, update the checkbox on Account to notify partner team.
 */
trigger SendNotificationOnNewPartner on User (after insert) 
{
    Set<Id> contactIds = new Set<Id>();
    for(User usr : Trigger.new)
    {
        if(usr.UserType == 'PowerPartner' && usr.ContactId != null && usr.IsActive == true)
        {
            contactIds.add(usr.ContactId);
        }
    }
    if(contactIds.size() > 0)
    {
        List<Account> partners = [select Id from Account where Id in (select AccountId from Contact where Id in :contactIds)];
        for(Account p : partners)
        {
            p.Partner_Portal_Enabled__c = true;
        }
        Database.update(partners, false);
    }
}