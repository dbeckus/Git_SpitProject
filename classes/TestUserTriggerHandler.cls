@ISTest
public class TestUserTriggerHandler {
    
    @isTest(seeAllData=true)
    static void testCheckUserActive()
    {
        Account acc = new Account(Name='TestData');
        insert acc;
        Contact con= new Contact(AccountId=acc.Id,LastName='Prane',Email='abc@abc.com');
        insert con;
         Contact con1= new Contact(AccountId=acc.Id,LastName='Prane',Email='abc@abc.com');
        insert con1;
        
        Profile prof=[Select Id from Profile where Name='12-SP Portal' LIMIT 1];
         Profile prof1=[Select Id from Profile where Name='System Administrator' LIMIT 1];
        User usr = new User(Alias = 'standt', Email='abc@abc.com', 
                            EmailEncodingKey='UTF-8', LastName='Prane', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=con.Id, IsActive=true,
                            TimeZoneSidKey='America/Los_Angeles', UserName='abc@abc.com');
        insert usr;
        Test.startTest();	
        try
        {
            User usr1 = new User(Alias = '12333', Email='abc@abc.com', 
                                 EmailEncodingKey='UTF-8', LastName='Prane11', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=con1.Id,IsActive=true,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='abc111111@abc.com');
            insert usr1;
            Test.stopTest();
        }
        catch(Exception ex)
        {
            System.debug(ex);
            System.assert(ex.getMessage().contains('There is an active portal license registered with this email address. Please enter other email address.'));
        }
        
    }
    
    
}