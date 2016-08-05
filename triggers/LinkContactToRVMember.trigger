/*
 * Sets the RVMember lookup on Contact (same email)
 */
trigger LinkContactToRVMember on rvpe__RVMember__c (after insert)
{
    Map<String, String> rvMemberIdMap = new Map<String, String>();   //key: email, value: rv member id
    for(rvpe__RVMember__c rvMember : trigger.new)
    {
        if(rvMember.rvpe__Email__c != null && rvMember.rvpe__Email__c.trim() != '')
        {
            rvMemberIdMap.put(rvMember.rvpe__Email__c, rvMember.Id);
        }
    }

    String duplicatedEmails = '';
    Set<String> matchedEmails = new Set<String>(); 
    List<Contact> contacts = [select Id, Name, Email, RV_Member__c from Contact where Email in :rvMemberIdMap.keySet() order by Email, LastModifiedDate DESC];
    for(Contact contact : contacts)
    {
        contact.RV_Member__c = rvMemberIdMap.get(contact.Email);
        
        if(matchedEmails.contains(contact.Email))
        {
        	if(duplicatedEmails.indexOf(contact.Email) < 0)
        	{
            	duplicatedEmails += contact.Email + ' \r\n';
        	}
        }
        else
        {
            matchedEmails.add(contact.Email);
        }
    }
    if(duplicatedEmails <> '')
    {
        List<User> users = [select Id from User where Name = 'Curtis Christensen'];
        if(!users.isEmpty())
        {
            FeedItem feedItem = new FeedItem();
            feedItem.Type = 'TextPost';
            feedItem.Body = 'Duplicate contacts are found on following email(s): \r\n' + duplicatedEmails;
            feedItem.ParentId = users[0].Id;
            insert feedItem;
        }
    }
    update contacts;
}