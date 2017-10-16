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
    
    //Contact updated with ABM Target 
    @isTest
    static void updateContactABMTarget(){
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Prospect';
        insert acc;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Vince';
        con1.LastName = 'Chase';
        con1.AccountId = acc.Id;
        con1.LeadSource = 'Sales';
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'John';
        con2.LastName = 'Chase';
        con2.AccountId = acc.Id;
        con2.LeadSource = 'Sales';
        insert con2;
        
        con1.ABM_Target__c = True;
        update con1;
        
        Account acc1 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(True, acc1.Target_Account__c);
        
        con1.ABM_Target__c = False;
        update con1;
        
        Account acc2= [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(False, acc2.Target_Account__c);
    }
    
    //Contact updated with ABM Target False but Account has different contact with ABM Target True
    @isTest
    static void updateMultipleContactABMTargetFalse(){
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Prospect';
        insert acc;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Vince';
        con1.LastName = 'Chase';
        con1.AccountId = acc.Id;
        con1.LeadSource = 'Sales';
        con1.ABM_Target__c = True;
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'John';
        con2.LastName = 'Chase';
        con2.AccountId = acc.Id;
        con2.LeadSource = 'Sales';
        con2.ABM_Target__c = True;
        insert con2;
        
        con1.ABM_Target__c = False;
        update con1;
        
        Account acc1 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(True, acc1.Target_Account__c);
    }
    
    //Contact undeleted with ABM Target True
    @isTest
    static void undeleteContactwithABMTargetTrue(){
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Prospect';
        insert acc;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Vince';
        con1.LastName = 'Chase';
        con1.AccountId = acc.Id;
        con1.LeadSource = 'Sales';
        con1.ABM_Target__c = True;
        insert con1;
        
        Contact con2 = new Contact();
        con2.FirstName = 'John';
        con2.LastName = 'Chase';
        con2.AccountId = acc.Id;
        con2.LeadSource = 'Sales';
        con2.ABM_Target__c = True;
        insert con2;
        
        delete con1;
        Account acc1 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(True, acc1.Target_Account__c);
        
        delete con2;
        Account acc2 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(False, acc2.Target_Account__c);
        
        undelete con1;
        Account acc3 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(True, acc3.Target_Account__c);
    }
    
    //Bulk Contacts test
    @isTest
    static void bulkContactsTest(){
        Account acc =  new Account();
        acc.Name = 'Test Account';
        acc.Type = 'Prospect';
        insert acc;    
        
        Contact[] listContactsToCreate = new Contact[]{};
            for(Integer x=0; x<200;X++){
                Contact ct = new Contact(AccountId=acc.Id, FirstName = 'Vince', LastName = 'Chase'+ x, ABM_Target__c = True, LeadSource = 'Sales');
                listContactsToCreate.add(ct);
            }
        
        Test.startTest();
        insert listContactsToCreate;
        
        Account acc1 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(True, acc1.Target_Account__c);
        
        Contact[] listContactsToDelete = new Contact[]{};
            for(Contact c: listContactsToCreate){
                listContactsToDelete.add(c);
            }
        
        delete listContactsToDelete;
        
        Account acc2 = [Select Id, Target_Account__c from Account where Id =:acc.Id];
        system.assertEquals(False, acc2.Target_Account__c);
        Test.stopTest();
    }
}