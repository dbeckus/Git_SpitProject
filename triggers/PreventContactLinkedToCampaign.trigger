/*
 * When a contact is to be linked to a campaign, find or create a lead to link instead.
 */
trigger PreventContactLinkedToCampaign on CampaignMember (before insert) 
{
    /*Set<Id> contactIds = new Set<Id>();
    for(CampaignMember campaignMember : Trigger.new)
    {
        if(campaignMember.ContactId != null)
        {
            contactIds.add(campaignMember.ContactId);
        }
    }
    
    Set<String> emails = new Set<String>();
    List<Contact> contacts = [select Id, OwnerId, Owner.IsActive, Account.Name, FirstName, LastName, Title, Email, Phone, MobilePhone, Fax, MailingCountry, MailingState, MailingCity, MailingStreet, MailingPostalCode, LeadSource from Contact where Id in :contactIds];
    for(Contact ct : contacts)
    {
        if(ct.Email != null)
        {
            emails.add(ct.Email);
        }
    }
    List<Lead> existingLeads = [select Id, Email from Lead where IsConverted=false and Email in :emails];
    Map<Id, Lead> contact2Lead = new Map<Id, Lead>();
    for(Contact ct : contacts)
    {
        Boolean leadExisted = false;
        if(ct.Email != null)
        {
            for(Lead ld : existingLeads)
            {
                if(ld.Email == ct.Email)
                {
                    contact2Lead.put(ct.Id, ld);
                    leadExisted = true;
                    break;
                }
            }
        }
        if(!leadExisted)
        {
            contact2Lead.put(ct.Id, getLeadFromContact(ct));
        }
    }
    upsert contact2Lead.values();
    
    List<Contact> contactsToUpdate = new List<Contact>();
    for(Id contactId : contact2Lead.keyset())
    {
        contactsToUpdate.add(new Contact(Id=contactId, Campaign_Lead__c=contact2Lead.get(contactId).Id));
    }
    update contactsToUpdate;
    
    for(CampaignMember campaignMember : Trigger.new)
    {
        if(campaignMember.ContactId != null)
        {
            campaignMember.LeadId = contact2Lead.get(campaignMember.ContactId).Id;
            campaignMember.ContactId = null;
        }
    }
    
    private Lead getLeadFromContact(Contact ct)
    {
        Lead ld = new Lead(FirstName=ct.FirstName, LastName=ct.LastName, Company=ct.Account.Name);
        ld.OwnerId = (ct.Owner.IsActive) ? ct.OwnerId : UserInfo.getUserId();
        ld.Title = ct.Title;
        ld.Phone = ct.Phone;
        ld.MobilePhone = ct.MobilePhone;
        ld.Email = ct.Email;
        ld.Fax = ct.Fax;
        ld.Country = ct.MailingCountry;
        ld.State = ct.MailingState;
        ld.City = ct.MailingCity;
        ld.Street = ct.MailingStreet;
        ld.PostalCode = ct.MailingPostalCode;
        ld.LeadSource = ct.LeadSource;
        if(String.isEmpty(ld.Company))
        {
            ld.Company = 'Unknown Company';
        }
        return ld;
    }*/
}