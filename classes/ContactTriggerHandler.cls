public class ContactTriggerHandler implements ITriggerHandler {
    Map<Id,string> mapGEOUsers= new Map<Id,string>();
    Set<String> moveToSDCampaignStages = new Set<String> { '03 MQL', '04 SAL', '13 MQC', '14 SAC', 'MQL', 'SAL', 'MQC' };
        Set<String> rejectStatuses = new Set<String> { 'Sales Rejected', 'Rejected' };
            String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();
    Set<Id> contactIdsToBeMovedOff = new Set<Id>();
    Map<Id,Contact> contactsToBeUpdated = new Map<Id,Contact>();
    List<CampaignMember> newSDCampaignMembers = new List<CampaignMember>();
    Set<Id> setAcctsTargetAccountTrue = new Set<Id>();
    Set<Id> setAcctsTargetAccountFalse = new Set<Id>();
    List<Account> listAcctsToUpdate = new List<Account>();
    Set<Id> setTriggeredContacts = new Set<Id>();
    
    public ContactTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Contact con : (List<Contact>)newItems)
            {
                if(con.TechnicalPresalesReady__c)
                {
                    con.TechnicalPresalesReadyCertifiedBy__c = UserInfo.getUserId();
                }
                if(con.ABM_Target__c)
                {
                    setAcctsTargetAccountTrue.add(con.AccountId);
                }       
            }
            updateTargetAccountToTrue(setAcctsTargetAccountTrue);     
        }       
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id conId : newItems.keyset())
            {
                Contact oldContact=(Contact)oldItems.get(conId);
                Contact newContact=(Contact)newItems.get(conId);
                if(newContact.TechnicalPresalesReady__c!=oldContact.TechnicalPresalesReady__c)
                {
                    newContact.TechnicalPresalesReadyCertifiedBy__c= newContact.TechnicalPresalesReady__c?UserInfo.getUserId():null;
                }
                if(oldContact.ABM_Target__c != newContact.ABM_Target__c)
                {
                    if(newContact.ABM_Target__c){
                        setAcctsTargetAccountTrue.add(newContact.AccountId);
                    }
                    else if (!newContact.ABM_Target__c){
                        setAcctsTargetAccountFalse.add(newContact.AccountId);
                        setTriggeredContacts.add(newContact.Id);
                    }
                } 
            }
            updateTargetAccountToTrue(setAcctsTargetAccountTrue);
            updateTargetAccountToFalse(setAcctsTargetAccountFalse, setTriggeredContacts);
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        for(Id conId: oldItems.keySet()){
            Contact oldContact =(Contact)oldItems.get(conId);
            if(oldContact.ABM_Target__c){ 
                setAcctsTargetAccountFalse.add(oldContact.AccountId);
                setTriggeredContacts.add(oldContact.Id);
            } 
        }
        updateTargetAccountToFalse(setAcctsTargetAccountFalse, setTriggeredContacts);
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id conId : newItems.keyset())
            {
                Contact newContact= (Contact)newItems.get(conId);
                if(moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && newContact.Account.Type != 'Partner')
                {
                    if(!contactsToBeUpdated.containsKey(newContact.Id))
                    {
                        contactsToBeUpdated.put(newContact.Id, new Contact(Id=newContact.Id));
                    }
                    contactsToBeUpdated.get(newContact.Id).Lead_Sub_Status__c = null;
                    newSDCampaignMembers.add(new CampaignMember(ContactId = newContact.Id, CampaignId = sdCampaignId));
                }
            }
            
            MoveContactsInAndOutOfSDCampaign();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id conId : newItems.keyset())
            {
                Contact oldContact=(Contact)oldItems.get(conId);
                Contact newContact=(Contact)newItems.get(conId);
                if(newContact.Partner_Role__c != oldContact.Partner_Role__c && newContact.Partner_Role__c != null)
                {
                    accountIds.add(newContact.AccountId);
                    contactIds.add(newContact.Id);
                }
                if(moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && !moveToSDCampaignStages.contains(oldContact.Lead_Lifecycle_Stage__c) && newContact.Account.Type != 'Partner')
                {
                    if(!contactsToBeUpdated.containsKey(newContact.Id))
                    {
                        contactsToBeUpdated.put(newContact.Id, new Contact(Id=newContact.Id));
                    }
                    contactsToBeUpdated.get(newContact.Id).Lead_Sub_Status__c = null;
                    newSDCampaignMembers.add(new CampaignMember(ContactId = newContact.Id, CampaignId = sdCampaignId));
                }
                if(!moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && moveToSDCampaignStages.contains(oldContact.Lead_Lifecycle_Stage__c))
                {
                    contactIdsToBeMovedOff.add(newContact.Id);
                }
                if(rejectStatuses.contains(newContact.Lead_Status__c) && !rejectStatuses.contains(oldContact.Lead_Status__c))
                { 
                    if(!contactsToBeUpdated.containsKey(newContact.Id))
                    {
                        contactsToBeUpdated.put(newContact.Id, new Contact(Id=newContact.Id));
                    }
                    contactsToBeUpdated.get(newContact.Id).Contact_Me__c = false;
                    contactsToBeUpdated.get(newContact.Id).BANT_Qualified__c = false;
                    contactIdsToBeMovedOff.add(newContact.Id);
                }
            }
            if(!accountIds.isEmpty() && !contactIds.isEmpty())
            {
                UpdateUserPartnerRoleTriggerHandler.UpdateUsersRole(contactIds, accountIds);
            }
            MoveContactsInAndOutOfSDCampaign();
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        for(Id conId: newItems.keySet()){
            Contact newContact =(Contact)newItems.get(conId);
            if(newContact.ABM_Target__c){
                setAcctsTargetAccountTrue.add(newContact.AccountId);
            } 
        }
        updateTargetAccountToTrue(setAcctsTargetAccountTrue); 
    }
    
    
    private void MoveContactsInAndOutOfSDCampaign()
    {
        //Move contacts to SD campaign
        if(!newSDCampaignMembers.isEmpty())
        {
            Database.insert(newSDCampaignMembers, false);
        }
        
        //Move contacts off SD campaign
        if(!contactIdsToBeMovedOff.isEmpty())
        {
            delete [select Id from CampaignMember where CampaignId = :sdCampaignId and ContactId in :contactIdsToBeMovedOff];
        }
        if(!contactsToBeUpdated.isEmpty())
        {
            SilverPeakUtils.BypassingTriggers = true;
            Database.update(contactsToBeUpdated.values(), false);
            SilverPeakUtils.BypassingTriggers = false;
        }
    }
    
    private void updateTargetAccountToTrue(Set<Id> setAcctIds){
        if(setAcctIds != null && setAcctIds.size() > 0){
            for(Account acc: [Select Id, Target_Account__c from Account where Target_Account__c = False and Id IN :setAcctIds]){
                acc.Target_Account__c = True;
                listAcctsToUpdate.add(acc);
            }
            if(listAcctsToUpdate.size()>0){
                update listAcctsToUpdate;
            }
        }
    }
    
    private void updateTargetAccountToFalse(Set<Id> setAcctIds, Set<Id> setConIds){  
        if(setAcctIds != null && setAcctIds.size() > 0){
            List<Account> listAcctsWithABMTargetContacts = [Select Id, (Select Id, ABM_Target__c from Contacts where Id  NOT IN :setConIds and ABM_Target__c = True) from Account where Id IN :setAcctIds];
            for(Account acc: listAcctsWithABMTargetContacts){
                if(acc.Contacts.size()==0){
                    acc.Target_Account__c = False;
                    listAcctsToUpdate.add(acc);
                }
            }
            if(listAcctsToUpdate.size()>0){
                update listAcctsToUpdate;
            }
        }
    } 
}