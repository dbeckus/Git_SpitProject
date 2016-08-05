/**
 * This trigger is used to update the User Role when the Partner Role is updated on the Contact Record.
 *
 */
trigger UpdateUserPartnerRole on Contact (after update)
{
    Set<Id> accountIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Contact contactOld;
    for(Contact contactNew : trigger.new)
    {
        contactOld = trigger.oldMap.get(contactNew.Id);
        if(contactNew.Partner_Role__c != contactOld.Partner_Role__c && contactNew.Partner_Role__c != null)
        {
            accountIds.add(contactNew.AccountId);
            contactIds.add(contactNew.Id);
        }
    }
    
    if(!accountIds.isEmpty() && !contactIds.isEmpty())
    {
        UpdateUserPartnerRoleTriggerHandler.UpdateUsersRole(contactIds, accountIds);
    }
}