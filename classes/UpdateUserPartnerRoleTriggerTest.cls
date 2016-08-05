/**
 * The test class for UpdateUserPartnerRoleTriggerHandler class and UpdateUserPartnerRole trigger. 
 */

@isTest
private class UpdateUserPartnerRoleTriggerTest
{
    static final String PORTAL_PROFILE = '13a-SP Partner Portal';
    
    @isTest(seeAllData=true)
    static void testUpdatePartnerRole()
    {
        List<User> portalUsers = [select Id, ContactId, Contact.AccountId, Contact.Partner_Role__c from User where IsActive = true and Profile.Name = :PORTAL_PROFILE and ContactId != null and Contact.Partner_Role__c != 'Manager' limit 1];
        if(portalUsers.size() > 0)
        {
            User portalUser = portalUsers[0];
            if(portalUser.Contact != null && portalUser.Contact.AccountId != null)
            {
                Contact contact = portalUser.Contact;
                contact.Partner_Role__c = 'Manager';
                
                Test.startTest();
                update contact;
                List<UserRole> userRoles = [select Id from UserRole where PortalRole = 'Manager' and PortalAccountId = :contact.AccountId limit 1];
                if(userRoles.size() > 0)
                {
                    UserRole userRole = userRoles[0];
                    portalUser = [select UserRoleId from User where Id = :portalUser.Id];
                    System.assertEquals(userRole.Id, portalUser.UserRoleId);
                }
                Test.stopTest();  
            }
        }
    }
}