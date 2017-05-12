@IsTest
public class TestAccountTriggerHandler {
    
     @IsTest
    public static void CloudPortalAccountNotDelete()
    {
        Account acc = new Account(Name='test', Cloud_Portal_Account_Key__c='Test CloudPortal',Cloud_Portal_Account_Name__c='Name');
        insert acc;
        try
        {
            delete acc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
     @IsTest
    public static void CloudPortalAccountAssetsNotDelete()
    {
        Account acc = new Account(Name='test');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Product2 prod = new Product2(Name='EC-BASE-1Y', ProductCode='acme', Model__c='acme');
        insert prod;
        Asset asset= new Asset();
        asset.Name='test';
        asset.SerialNumber='test';
        asset.AccountId=acc.Id;
        asset.Product2Id=prod.Id;
        asset.Status='Customer Subscription Active';
        asset.Quantity=1;
        insert asset;
        try
        {
            delete acc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
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
     @IsTest
    public static void TestSendEmailToDevOpsforMTO()
    {
        Account acc= new Account(Name='Test Data',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual-Orchestrator SP',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='test',Service_Provider_Location__c='EU (London)');
        insert acc;
        acc.Cloud_Portal_Account_Id__c='test';
        acc.Cloud_Portal_Account_Key__c='test';
        acc.Cloud_Portal_Account_Name__c='test';
        update acc;
    }
     @IsTest
    public static void ECSPFlag_AccountSyncedinCP()
    {
        Account acc=new Account(Name='Test',Cloud_Portal_Account_Name__c='Test',ECSP__c=true,Service_Provider_Account_type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com');
        insert acc;
        acc.ECSP__c=false;
        Profile p = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsServiceProviderTeam__c=true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) 
        {
            // The following code runs as user 'u' 
            try
            {
                update acc;
            }
            catch(Exception ex)
            {
                System.debug(ex.getMessage());
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot modify any fields in the service provider information section. Please contact service provider team.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
        }
        
    }
    @IsTest
    public static void ECSPFlag_AccountAssetsCreated()
    {
        Account acc=new Account(Name='Test',ECSP__c=true,Service_Provider_Account_type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com');
        insert acc;
        Account spacc=new Account(Name='Silver Peak Systems');
        insert spacc;
        Product2 product = new Product2(Name='EC-BASE-1Y', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='T-30', AccountId=acc.Id, Product2Id=product.Id,Status='Customer Evaluation');
        insert asset1;
        Profile p = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsServiceProviderTeam__c=true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) 
        {
            acc.ECSP__c=false;
            
            try
            {
                update acc;
            }
            catch(Exception ex)
            {
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot modify any fields in the service provider information section. Please contact service provider team.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
      @IsTest
    public static void TestUpdateAccountIsPartner()
    {
        Account acc=new Account(Name='Test',Partner_Application_Status__c='Pending');
        insert acc;
        acc.Partner_Application_Status__c='Approved';
        update acc;
    }
    @IsTest
    public static void AllowECSPFlagChange()
    {
         Account acc=new Account(Name='Test',ECSP__c=true,Service_Provider_Account_type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com');
            insert acc;
        Profile p = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, IsServiceProviderTeam__c=true,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) 
        {
           
            acc.ECSP__c=false;
            try
            {
                update acc;
            }
            catch(Exception ex)
            {
                System.debug(ex);
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot modify ECSP flag at this point of time. Please contact operations.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
    
   
}