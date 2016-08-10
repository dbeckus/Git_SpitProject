/*
 * When portal user is created or updated, sync the contact detail (phone, email, address) to contact record
 */
trigger SyncUserContact on User (after update, after insert) 
{
    List<Id> userIds = new List<Id>();
    for(User usr : Trigger.new)
    {
        if(usr.ContactId != null)
        {
            if(Trigger.isInsert || (Trigger.isUpdate && contactChanged(usr, Trigger.oldMap.get(usr.Id))))
            {
                userIds.add(usr.Id);
            }
        }
    }
    
    if(userIds.size() > 0)
    {
        updateContacts(userIds);
    }
    
    private Boolean contactChanged(User newUser, User oldUser)
    {
        return newUser.Email != oldUser.Email || newUser.Phone != oldUser.Phone || newUser.MobilePhone != oldUser.MobilePhone || newUser.Country != oldUser.Country || newUser.State != oldUser.State || newUser.City != oldUser.City || newUser.PostalCode != oldUser.PostalCode || newUser.Street != oldUser.Street;
    }
    
    private void updateContacts(List<Id> portalUserIds)
    {
        List<Contact> contactsToUpdate= new List<Contact>();
        List<User> portalUsers = [select Id, ContactId, Email, Phone, MobilePhone, Country, State, City, PostalCode, Street from User where Id in :portalUserIds];
        for(User portalUser : portalUsers)
        {
            contactsToUpdate.add(new Contact(Id=portalUser.ContactId, Email=portalUser.Email, Phone=portaluser.Phone, MobilePhone=portalUser.MobilePhone, MailingCountry=portalUser.Country, MailingState=portalUser.State, MailingPostalCode=portalUser.PostalCode, MailingCity=portalUser.City, MailingStreet=portalUser.Street));
        }
        Database.update(contactsToUpdate, false);
    }
}