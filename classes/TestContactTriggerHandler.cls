@IsTest
public class TestContactTriggerHandler {
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
    
    
    @isTest(seeAllData=true)
    static void testCheckPortalRoleAccess()
    {
        Account acc = new Account(Name='TestData');
        insert acc;
        Contact con= new Contact(AccountId=acc.Id,LastName='Prane',Email='abc@abc.com');
        insert con;
        
        Profile prof=[Select Id from Profile where Name='12d-SP Customer & Partner' LIMIT 1];
       	User usr = new User(Alias = 'standt', Email='abc@abc.com', 
                            EmailEncodingKey='UTF-8', LastName='Prane', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=con.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='abc@abc.com');
        insert usr;
        Contact con1= new Contact(AccountId=acc.Id,LastName='Prane',Email='abc@abc.com');
        insert con1;
        try
        {
            con1.CanAllowPortalSelfReg=true;
        	update con1;
        }
        catch(Exception ex)
        {
            System.assert(ex.getMessage().contains('There is an active portal license registered with this email address. Please enter other email address.'));
        }
        
    }
}