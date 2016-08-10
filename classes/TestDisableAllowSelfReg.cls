@IsTest
public class TestDisableAllowSelfReg {
    
    @IsTest(SeeAllData=true)
    public static void test1_Contact()
    {
        Test.startTest();
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            Profile prof = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        Account acc = new Account(Name = 'Test Opp Account');
        insert acc;
        Contact con = new Contact(LastName='test',email='test-user@fakeemail.com',AccountId=acc.Id);
        con.CanAllowPortalSelfReg=true;
        insert con;
        User u1 = new User( email='test-user@fakeemail.com', IsActive=true,contactid = con.id, profileid = prof.Id, UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1',
                           TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                           LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User'); 
        insert u1;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            u1.IsActive = false;
            //u1.IsPortalEnabled = false;
            update u1;
        }
        Test.stopTest();
        Contact con1 =[Select Id,CanAllowPortalSelfReg from Contact where id=:con.Id];
        System.assertEquals(false, con1.CanAllowPortalSelfReg);
    }
     @IsTest(SeeAllData=true)
    public static void test1_Account()
    {
        Test.startTest();
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            Profile prof = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
        Account acc = new Account(Name = 'Test Opp Account');
        insert acc;
        Contact con = new Contact(LastName='test',email='test-user@fakeemail.com',AccountId=acc.Id);
        con.CanAllowPortalSelfReg=true;
        insert con;
        User u1 = new User( email='test-user@fakeemail.com', IsActive=true,contactid = con.id, profileid = prof.Id, UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1',
                           TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                           LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ); 
        insert u1;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
           acc.IsCustomerPortal=false;
           update acc;
        }
        Test.stopTest();
        Contact con1 =[Select Id,CanAllowPortalSelfReg from Contact where id=:con.Id];
        System.assertEquals(false, con1.CanAllowPortalSelfReg);
    }
}