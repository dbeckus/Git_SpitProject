public class UserTriggerHandler implements ITriggerHandler {
    public UserTriggerHandler()
    {
        if(system.isFuture()) return;
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
            for(User newUser :(List<User>)newItems)
            {
                System.debug(' newUser.UserType '+newUser.UserType);
                if((newUser.UserType=='Customer Portal Manager'||newUser.UserType=='Customer Portal User'||newUser.UserType=='PowerCustomerSuccess' || newUser.UserType=='PowerPartner' ) && newUser.IsActive)
                {
                    if(SilverPeakUtils.IsUserNameExistswithEmail(newUser.Email))
                    {
                        newUser.addError('There is an active portal license registered with this email address.');
                    }
                }
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            Set<Id> users = IsUserInPatch(newItems.keyset());
            for (Id userId : newItems.keyset())
            {
                User newUser= (User)newItems.get(userId);
                User oldUser= (User)oldItems.get(userId);     
                if(!newUser.IsActive && oldUser.IsActive)
                {
                    if(users.contains(userId))
                    {
                        newUser.addError('This user is in a patch team. You cannot deactivate this user before replacing the team member.');
                    }
                }
                if(newUser.IsActive && !oldUser.IsActive && (newUser.UserType=='Customer Portal Manager'||newUser.UserType=='Customer Portal User'||newUser.UserType=='PowerCustomerSuccess' || newUser.UserType=='PowerPartner' ))
                {
                    if(SilverPeakUtils.IsUserNameExistswithEmail(newUser.Email))
                    {
                        newUser.addError('There is an active portal license registered with this email address.');
                    }
                }
                
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        boolean isSynced=false;
        if(oldItems.size()>0)
        {
            for(Id userId:oldItems.keySet())
            {
                User oldAccinfo= (User)oldItems.get(userId);
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            Set<Id> contactIds = new Set<Id>();
            Set<Id> newUserIds = new Set<Id>();
            Set<Id> syncUserIds = new Set<Id>();
            for (Id userId : newItems.keyset())
            {
                User newUser= (User)newItems.get(userId);
                if(newUser.UserType == 'PowerPartner' && newUser.ContactId != null && newUser.IsActive == true)
                {
                    contactIds.add(newUser.ContactId);
                }
                if(newUser.UserType == 'PowerPartner' && newUser.IsActive)
                {
                    newUserIds.add(newUser.Id);
                }
                System.debug('newUser.ContactId '+ newUser.ContactId);
                if(newUser.ContactId!=null)
                {
                    syncUserIds.add(newUser.Id);
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
           
            PartnerPortalUserSharing.willSharePortalUser(new List<Id>(newUserIds));
            UpdateContacts(syncUserIds);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> conList= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            Set<Id> userIds = new Set<Id>();
            Set<Id> newUserIds = new Set<Id>();
    		Set<Id> deactivateUserIds = new Set<Id>();
            for (Id userId : newItems.keyset())
            {
                User newUser= (User)newItems.get(userId);
                User oldUser= (User)oldItems.get(userId);     
                if(oldUser.IsActive!=newUser.IsActive && !newUser.IsActive && ((newUser.UserType=='Customer Portal Manager')||(newUser.UserType=='Customer Portal User')||(newUser.UserType=='PowerCustomerSuccess')))
                {
                    conList.add(oldUser.ContactId);
                }
                if(newUser.ContactId!=null && contactChanged(newUser, oldUser))
                {
                    userIds.add(oldUser.Id);
                }
                
                if(newUser.IsActive && !oldUser.IsActive)
                {
                    newUserIds.add(newUser.Id);
                }
                if(!newUser.IsActive && oldUser.IsActive)
                {
                    deactivateUserIds.add(oldUser.Id);
                }
            }
            PartnerPortalUserSharing.willSharePortalUser(new List<Id>(newUserIds));
            PartnerPortalUserSharing.willRemoveSharingPortalUser(new List<Id>(deactivateUserIds));
            if(conList.size()>0)
            {
                ContactOwnershipHelper.DisableAllowSelfReg(conList);
            }
            if(userIds.size()>0)
            {
                UpdateContacts(userIds);
            }
            
         
            
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private Boolean ContactChanged(User newUser, User oldUser)
    {
        return newUser.Email != oldUser.Email || newUser.Phone != oldUser.Phone || newUser.MobilePhone != oldUser.MobilePhone || newUser.Country != oldUser.Country || newUser.State != oldUser.State || newUser.City != oldUser.City || newUser.PostalCode != oldUser.PostalCode || newUser.Street != oldUser.Street;
    }
    
    private void UpdateContacts(Set<Id> portalUserIds)
    {
        
        System.debug('portalUserIds');
        List<Contact> contactsToUpdate= new List<Contact>();
        List<User> portalUsers = [select Id, ContactId, Email, Phone, MobilePhone, Country, State, City, PostalCode, Street from User where Id in :portalUserIds];
        for(User portalUser : portalUsers)
        {
            contactsToUpdate.add(new Contact(Id=portalUser.ContactId, Email=portalUser.Email, Phone=portaluser.Phone, MobilePhone=portalUser.MobilePhone, MailingCountry=portalUser.Country, MailingState=portalUser.State, MailingPostalCode=portalUser.PostalCode, MailingCity=portalUser.City, MailingStreet=portalUser.Street));
        }
        try
        {
            System.debug(contactsToUpdate);
            Database.update(contactsToUpdate, false);
            System.debug('Success');
        }
        catch(Exception ex)
        {
            System.debug(ex);
        }
    }
    private static Set<Id> IsUserInPatch(Set<Id> lstUser)
    {
        Set<Id> wrongUsers = new Set<Id>();
        for(Patch__c patch : [select Id, Owner__c, RSM__c, ISR__c, CSM__c, SE__c from Patch__c where Owner__c in :lstUser or RSM__c in :lstUser or ISR__c in :lstUser or CSM__c in :lstUser or SE__c in :lstUser])
        {
            if(lstUser.contains(patch.Owner__c))
            {
                wrongUsers.add(patch.Owner__c);
            }
            if(lstUser.contains(patch.RSM__c))
            {
                wrongUsers.add(patch.RSM__c);
            }
            if(lstUser.contains(patch.ISR__c))
            {
                wrongUsers.add(patch.ISR__c);
            }
            if(lstUser.contains(patch.CSM__c))
            {
                wrongUsers.add(patch.CSM__c);
            }
            if(lstUser.contains(patch.SE__c))
            {
                wrongUsers.add(patch.SE__c);
            }
        }
        
        return wrongUsers;
    }
}