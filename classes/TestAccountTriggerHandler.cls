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
    public static void OrchDomainDuplicate_Insert()
    {
        
        try
        {
            Account acc = new Account(Name='test', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc;
            Account acc1 = new Account(Name='test1', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc1;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Unity Orch Domain entered is used in another account. Kindly enter another domain name.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    @IsTest
    public static void OrchDomainDuplicate_Update()
    {
        
        try
        {
            Account acc = new Account(Name='test', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc;
            Account acc1 = new Account(Name='test1', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc7',Unity_Orch_Location__c='Canada (Central)');
            insert acc1;
            acc1.Unity_Orch_Domain__c='testabc6';
            update acc1;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Unity Orch Domain entered is used in another account. Kindly enter another domain name.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
      @IsTest
    public static void OrchDomainVersion_Insert()
    {
        
        try
        {
            Account acc = new Account(Name='test', Unity_Orch_Version__c='1222.21.1.12222');
            insert acc;
         
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('This field can only accept in **.**.**.***** format. For ex 8.1.14.33650.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
      @IsTest
    public static void OrchDomainVersion_Update()
    {
        
        try
        {
            Account acc = new Account(Name='test');
            insert acc;
            acc.Unity_Orch_Version__c='12.21.1.1222';
            update acc;
         
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('This field can only accept in **.**.**.***** format. For ex 8.1.14.33650.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    
     @IsTest
    public static void OrchDomainVersion_NotInSystem_Insert()
    {
        
        try
        {
            Releases__c rel= new  Releases__c();
            rel.Name='GMS 8.1';
            rel.Type__c='GMS';
            rel.Release_Date__c= Date.today();
            rel.Release__c= 'Test Data';
            insert rel;
            
            Builds__c build= new Builds__c();
            build.Name ='Test';
            build.Status__c='GA';
            build.Release__c= rel.Id;
            build.Build_Number__c='8.1.1.12222';
            insert build;
            
            Account acc = new Account(Name='test', Unity_Orch_Version__c='1.21.1.12222');
            insert acc;
         
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Invalid version number. Please enter valid version.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
      @IsTest
    public static void OrchDomainVersion_NotInSystem_Update()
    {
        
        try
        {
            Releases__c rel= new  Releases__c();
            rel.Name='GMS 8.1';
            rel.Type__c='GMS';
            rel.Release_Date__c= Date.today();
            rel.Release__c= 'Test Data';
            insert rel;
            
            Builds__c build= new Builds__c();
            build.Name ='Test';
            build.Status__c='GA';
            build.Release__c= rel.Id;
            build.Build_Number__c='8.1.1.12222';
            insert build;
            Account acc = new Account(Name='test', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc;
           	acc.Unity_Orch_Version__c='12.21.1.12222';
            update acc;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Invalid version number. Please enter valid version.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
      @IsTest
    public static void OrchDomainVersion_InSystem_Update()
    {
        
        try
        {
            Releases__c rel= new  Releases__c();
            rel.Name='GMS 8.1';
            rel.Type__c='GMS';
            rel.Release_Date__c= Date.today();
            rel.Release__c= 'Test Data';
            insert rel;
            
            Builds__c build= new Builds__c();
            build.Name ='Test';
            build.Status__c='GA';
            build.Release__c= rel.Id;
            build.Build_Number__c='8.1.1.12222';
            insert build;
            Account acc = new Account(Name='test', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc;
           	acc.Unity_Orch_Version__c='8.1.1.12222';
            update acc;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Invalid version number. Please enter valid version.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
      @IsTest
    public static void OrchDomainVersion_InSystem_Update_Underscore()
    {
        
        try
        {
            Releases__c rel= new  Releases__c();
            rel.Name='GMS 8.1';
            rel.Type__c='GMS';
            rel.Release_Date__c= Date.today();
            rel.Release__c= 'Test Data';
            insert rel;
            
            Builds__c build= new Builds__c();
            build.Name ='Test';
            build.Status__c='GA';
            build.Release__c= rel.Id;
            build.Build_Number__c='8.1.1_12222';
            insert build;
            Account acc = new Account(Name='test', Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='testabc6',Unity_Orch_Location__c='Canada (Central)');
            insert acc;
           	acc.Unity_Orch_Version__c='8.1.1.12222';
            update acc;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            Boolean expectedExceptionThrown =  e.getMessage().contains('Invalid version number. Please enter valid version.') ? true : false;
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
   // @IsTest
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
    @IsTest(SeeAllData=true)
    public static void test1_Account_UnityCloudCP_Assets()
    {
        Account acc=new Account(Name='Test',Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='test123',Unity_Orch_Location__c='US East (Ohio)');
        insert acc;
        Account spacc=new Account(Name='Silver Peak Systems');
        insert spacc;
        Product2 product = new Product2(Name='EC-ORCH-AAS-50-1Y',Model__c='EC-ORCH-AAS-50-1Y', Product_Type__c='EdgeConnect', Family='Virtual Image', Product_Category__c='Subscription', IsActive=true);
        insert product;
        Asset asset1 = new Asset(Name='T-30', AccountId=acc.Id, Product2Id=product.Id,Status='Customer Evaluation');
        insert asset1;
        
        acc.Unity_Orch_Domain__c='abc123';
        
        try
        {
            update acc;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot modify any fields in the unity cloud orchestrator section. Please contact operations team.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }
   @IsTest(SeeAllData=true)
    public static void test1_Account_UnityCloudSyncedinCP()
    {
        Account acc=new Account(Name='Test',Cloud_Portal_Account_Name__c='Test',Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='test123',Unity_Orch_Location__c='US East (Ohio)');
        insert acc;
        acc.Unity_Orch_Domain__c='abc123';
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
                Boolean expectedExceptionThrown =  ex.getMessage().contains('You cannot modify any fields in the unity cloud orchestrator section. Please contact operations team.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            
        }
    }
     @IsTest
    public static void UpdateOppTypeforAccount()
    {
        
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp1 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(30),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(100),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp2;
        Test.startTest();
        opp1.Finance_Reviewed__c=true;
        opp1.StageName='Closed Won';
        update opp1;
        
        List<Opportunity> result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:acc.Id];
        for(Opportunity opp: result)
        {
            System.assertEquals(opp.Type, 'Follow on Business');
        }
        Test.stopTest();
    }
    
      @IsTest
    public static void EnforcePortalUserGroup()
    {
        Test.startTest();
        Account acc = new Account(Name='acme', Type='Eval',GEO_Supported__c='NAM');
        insert acc;
       	acc.GEO_Supported__c='EMEA';
        update acc;
        Test.stopTest();
    }
}