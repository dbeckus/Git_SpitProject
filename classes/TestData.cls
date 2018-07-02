@IsTest
public class TestData {
    @IsTest
    public static void test1_Account()
    {
        Test.startTest();
        Profile prof = [select Id,name from Profile where Name='12-SP Portal' limit 1];
        Account acc = new Account(Name = 'Test Opp Account',Type='Prospect',OwnerId=UserInfo.getUserId());
        insert acc;
        Contact con = new Contact(LastName='test',email='test-user@fakeemail.com',AccountId=acc.Id);
        insert con;
        System.debug('con data');
        User u1 = new User( email='test-user@fakeemail.com',contactid = con.id, profileid = prof.Id, UserName='test-user@fakeemail.com', alias='tuser1', CommunityNickName='tuser1',
                           TimeZoneSidKey='America/New_York', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1',
                           LanguageLocaleKey='en_US', FirstName = 'Test', LastName = 'User' ); 
        insert u1;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            u1.isActive=true;
            u1.IsPortalEnabled=true;
            update u1;
            
            User useroutput=[Select Id,profileid,Profile.Name,IsActive,contactid from User where Id=:u1.Id];
            System.debug('useroutput Data' + useroutput);
            Account accOutput=[Select Id,IsCustomerPortal from Account where Id=:acc.Id ];
            System.debug('accOutput'+ accOutput.IsCustomerPortal);
            accOutput.IsCustomerPortal=false;
            update accOutput;
            Contact con1 =[Select Id,CanAllowPortalSelfReg from Contact where id=:con.Id];
            System.assertEquals(false, con1.CanAllowPortalSelfReg);
            
        }
        
        
        Test.stopTest();
        
    }
}