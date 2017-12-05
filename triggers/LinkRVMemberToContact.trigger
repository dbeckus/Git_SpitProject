/*
 * Sets the Contact on new RVMember
 * The contact should have same email address with the RVMember
 */
trigger LinkRVMemberToContact on rvpe__RVMember__c (before insert)
{
    Map<String, rvpe__RVMember__c> rvMemberMap = new Map<String, rvpe__RVMember__c>();    //key: email address, value: RVMember
    Set<String> rvMemberRVAccountIds = new Set<String>();
    String duplicatedEmails = '';
    for(rvpe__RVMember__c rvMember : trigger.new)
    {
        if(rvMember.rvpe__Email__c != null && rvMember.rvpe__Email__c.trim() != '')
        {
            if(!rvMemberMap.containsKey(rvMember.rvpe__Email__c))
            {
                rvMemberMap.put(rvMember.rvpe__Email__c, rvMember);
                rvMemberRVAccountIds.add(rvMember.rvpe__RVAccount__c);
            }
            else if(duplicatedEmails.indexOf(rvMember.rvpe__Email__c) < 0)
            {
                duplicatedEmails += rvMember.rvpe__Email__c + ' \r\n';
            }
        }
    }
    
    //Constructs a map which is used to look for the account id when a new contact needs to be created.
    Map<String, String> rvAccountMap = new Map<String, String>();  //key: rv account id, value: sf account id
    for(rvpe__RVAccount__c rvAccount : [select Id, rvpe__SFAccount__c from rvpe__RVAccount__c where Id in :rvMemberRVAccountIds])
    {
        rvAccountMap.put(rvAccount.Id, rvAccount.rvpe__SFAccount__c);
    }
    
    //Constructs a map which contains the email and the id of last created contact.
    Map<String, String> contactEmailMap = new Map<String, String>();
    for(Contact contact : [select Id, Email from Contact where Email in :rvMemberMap.keySet() order by LastModifiedDate])
    {
        contactEmailMap.put(contact.Email, contact.Id);
    }
    
    //If no contacts matched, creates a new contact.
    List<Contact> newContacts = new List<Contact>();
    for(String rvMemberEmail : rvMemberMap.keySet())
    {
        if(!contactEmailMap.containsKey(rvMemberEmail))
        {
            rvpe__RVMember__c rvMember = rvMemberMap.get(rvMemberEmail);
            Contact contact = new Contact();
            contact.FirstName = rvMember.rvpe__FirstName__c;
            contact.LastName = rvMember.rvpe__LastName__c;
            if(contact.LastName == null || contact.LastName == '')
            {
                contact.LastName = rvMember.Name;
            }
            contact.Phone = rvMember.rvpe__Phone__c;
            contact.Email = rvMember.rvpe__Email__c;
            contact.AccountId = rvAccountMap.get(rvMember.rvpe__RVAccount__c);
            newContacts.add(contact);
        }
    }
    if(!newContacts.isEmpty())
    {
        insert newContacts;
    }
    for(Contact contact : newContacts)
    {
        contactEmailMap.put(contact.Email, contact.Id);
    }
    
    for(rvpe__RVMember__c rvMember : trigger.new)
    {
        if(rvMember.rvpe__Email__c != null && rvMember.rvpe__Email__c.trim() != '')
        {
            rvMember.rvpe__SFContact__c = contactEmailMap.get(rvMember.rvpe__Email__c);
        }
    }
    
    if(duplicatedEmails <> '')
    {
        List<User> users = [select Id from User where Name = 'Dennis Beckus' and ProfileID = '00e30000000elKyAAI'];
        if(!users.isEmpty())
        {
            FeedItem feedItem = new FeedItem();
            feedItem.Type = 'TextPost';
            feedItem.Body = 'Duplicate RV Members are found on following email(s): \r\n' + duplicatedEmails;
            feedItem.ParentId = users[0].Id;
            insert feedItem;
        }
    }
}