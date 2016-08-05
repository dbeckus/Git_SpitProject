/**
 *  Trigger handler class for UpdatePartnerRoleOnUser trigger.
 */

public class UpdateUserPartnerRoleTriggerHandler
{
    @future
    public static void UpdateUsersRole(Set<Id> contactsIdSet, Set<Id> accountsIdSet)
    {
        Map<Id, Map<String, Id>> accountId2PortalRoleMap = new Map<Id, Map<String, Id>>(); //Key: AccountId, Value: Map(Key: PortalRole, Value: UserRoleId)
        for(UserRole role : [select Id, Name, PortalAccountId, PortalRole from UserRole where PortalAccountId in :accountsIdSet])
        {
            if(!accountId2PortalRoleMap.containsKey(role.PortalAccountId))
            {
                accountId2PortalRoleMap.put(role.PortalAccountId, new Map<String, Id>());
            }
            accountId2PortalRoleMap.get(role.PortalAccountId).put(role.PortalRole, role.Id);
        }
        
        List<User> users = [select Id, ContactId, Contact.AccountId, Contact.Partner_Role__c, UserRoleId from User where ContactId in :contactsIdSet and IsActive = true];
        Map<String, String> partnerRole2PortalRoleMap = new Map<String, String> { 'Executive' => 'Executive', 'Manager' => 'Manager', 'User' => 'Worker'}; //Key: Partner_Role__c on Contact, Value: PortalRole on UserRole
        String portalRole, roleId;
        for(User user : users)
        {
            if(accountId2PortalRoleMap.containsKey(user.Contact.AccountId))
            {
                portalRole = partnerRole2PortalRoleMap.get(user.Contact.Partner_Role__c);
                roleId = accountId2PortalRoleMap.get(user.Contact.AccountId).get(portalRole);
            }
            user.UserRoleId = roleId;
        }
        update users;
    }
}