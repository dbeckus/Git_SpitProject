@isTest
public class PartnerPortalUserSharingTest
{
    @isTest
    static void testSharePortalUserOnAccount()
    {
        Account partner = new Account(Name='acme');
        insert partner;
        Contact ct = new Contact(AccountId=partner.Id, LastName='acme', Email='test@test.com');
        insert ct;
        
        Profile profile = [select Id from Profile where Name='13g-SP Partner Community' limit 1];
        User usr = new User(FirstName='acme', LastName='acme', Email='test@test.com', Username='test@test.com.pptest', ProfileId=profile.Id, ContactId=ct.Id, Alias='test', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert usr;
        
        Test.startTest();
        partner.GEO_Supported__c = 'APAC';
        update partner;
        Test.stopTest();
        
        List<GroupMember> newMembers = [select Id from GroupMember where UserOrGroupId=:usr.Id];
        //System.assertEquals(1, newMembers.size());
    }
    
    @isTest
    static void testSchedule()
    {
        Test.startTest();
        PartnerPortalUserSharingSchedule job = new PartnerPortalUserSharingSchedule();
        job.execute(null);
        Test.stopTest();
    }
}