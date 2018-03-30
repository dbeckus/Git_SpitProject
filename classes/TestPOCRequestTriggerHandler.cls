@IsTest
public class TestPOCRequestTriggerHandler {
     @isTest
    static void testCopyAccountTeamEmailOnPOC()
    {
        Account account = new Account(Name='acme');
        Account account2 = new Account(Name='acme2');        
        insert new Account[] { account, account2};
            Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');
        Opportunity opp2 = new Opportunity(Name = 'acme2', AccountId = account2.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');        
        insert new Opportunity[] { opp, opp2 };        
            AccountTeamMember member = new AccountTeamMember(AccountId = account.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Manager');        
        AccountTeamMember member2 = new AccountTeamMember(AccountId = account2.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Systems Engineer');
        insert new AccountTeamMember[]{ member, member2 };                      
            Request__c request = new Request__c(Opportunity__c = opp.Id);
        Request__c request2 = new Request__c(Opportunity__c = opp2.Id);        
        insert new Request__c[]{ request, request2 };
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request.Id][0].Account_Manager_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request2.Id][0].System_Engineer_Email_1__c);
        member.TeamMemberRole = 'Systems Engineer';
        update member;        
        update request;
       
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request.Id][0].System_Engineer_Email_1__c);
        
    }
    @isTest
    public  static void testUpdatePocStatusToOpportunity_Open ()
    {
        Account acct = new Account(Name = 'Acme');
        insert acct;
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2006,10,10),AccountId = acct.Id);
        insert opp;
        Request__c poc = new Request__c( Opportunity__c = opp.Id, Status__c = 'Open');
        insert poc;
        Opportunity newOpp1 = [select Id,Has_Active_POCs__c from Opportunity where Id =: opp.Id];
        Account newAcct1 = [select Id, Has_Active_POCs__c from Account where Id =: acct.Id];
        system.assertEquals(false, newOpp1.Has_Active_POCs__c);
        system.assertEquals(false, newAcct1.Has_Active_POCs__c);        
    }
    @isTest
    public  static void testUpdatePocStatusToOpportunity_Closed()
    {
        Account acct = new Account(Name = 'Acme');
        insert acct;
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2006,10,10),AccountId = acct.Id);
        insert opp;
        Request__c poc = new Request__c( Opportunity__c = opp.Id, Status__c = 'Closed - Won');
        insert poc;
        Opportunity newOpp1 = [select Id,Has_Active_POCs__c from Opportunity where Id =: opp.Id];
        Account newAcct1 = [select Id, Has_Active_POCs__c from Account where Id =: acct.Id];
        system.assertEquals(false, newOpp1.Has_Active_POCs__c);
        system.assertEquals(false, newAcct1.Has_Active_POCs__c);        
    }
    @isTest
    public  static void testUpdatePocStatusToOpportunity_NotClosed()
    {
        Account acct = new Account(Name = 'Acme');
        insert acct;
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2006,10,10),AccountId = acct.Id);
        insert opp;
        Request__c poc = new Request__c( Opportunity__c = opp.Id, Status__c = 'Shipped');
        insert poc;
        Opportunity newOpp1 = [select Id,Has_Active_POCs__c from Opportunity where Id =: opp.Id];
        Account newAcct1 = [select Id, Has_Active_POCs__c from Account where Id =: acct.Id];
        system.assertEquals(true, newOpp1.Has_Active_POCs__c);
        system.assertEquals(true, newAcct1.Has_Active_POCs__c);        
    }
    @IsTest	
    public static void deleteRMA_Received()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='EC-XS';
        request.Evaluation_Product_2__c='EC-XS';
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        request.Status__c='Pending Return';
        insert request;
        Product2 product = new Product2();
        product.Name = 'Test EC';
        product.ProductCode = 'Test EC';
        product.Model__c = 'Test EC';
        product.Family='Product';
        insert product;
        Test.startTest();
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Evaluation';
        asset.Quantity = 1;
        asset.POCRequest__c=request.Id;
        insert asset;
        
        NewRMAHelper.createRmaOnPOC(string.valueOf(asset.Id));
        
        
        List<RMA__c> rmaItem=[Select Id from RMA__C where Request__c=:request.Id];
        System.assert(rmaItem!=null && rmaItem.size()>0);
        rmaItem[0].Status__c='Received';
        update rmaItem[0];
        Profile prof = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        System.runAs(usr){
            
            request.Status__c='Shipped - Extended';
            update request;
            
        }
        Test.stopTest();
    }
    
    @IsTest	
    public static void deleteRMA_NotReceived()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='EC-XS';
        request.Evaluation_Product_2__c='EC-XS';
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        request.Status__c='Pending Return';
        insert request;
        Product2 product = new Product2();
        product.Name = 'Test EC';
        product.ProductCode = 'Test EC';
        product.Model__c = 'Test EC';
        product.Family='Product';
        insert product;
        Test.startTest();
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Evaluation';
        asset.Quantity = 1;
        asset.POCRequest__c=request.Id;
        insert asset;
        
        NewRMAHelper.createRmaOnPOC(string.valueOf(asset.Id));
        
        
        List<RMA__c> rmaItem=[Select Id from RMA__C where Request__c=:request.Id];
        System.assert(rmaItem!=null && rmaItem.size()>0);
        rmaItem[0].Status__c='Awaiting Return';
        update rmaItem[0];
        Profile prof = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        System.runAs(usr){
            
            request.Status__c='Shipped - Extended';
            update request;
            
        }
        Test.stopTest();
    }
    @IsTest
    public static void TestApprovers_NAM()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account speAcc = new Account(Name='EMAIL SUPPORT CONTACTS');
        insert speAcc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        opportunity.Technical_Responsible__c=SEId.Id;
        opportunity.OwnerId=ownerId.Id;
        opportunity.Sales_Region__c='NAM-central';
        insert opportunity;
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='WAN Op';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'VX-2000';
        pocRequest.VirtualQuantity1__c= 5;
        
        insert pocRequest;  
        Request__c output=[Select Id , RSM__c,SE__c,RSM_Manager__c,RSM_VP_Sales__c,SE_Manager__c,SE_Director__c from Request__c where Id=:pocRequest.Id] ;
        System.assert(output.RSM_Manager__c!=null);
        System.assert(output.RSM__c!=null);
        System.assert(output.RSM_VP_Sales__c!=null);
        System.assert(output.SE_Manager__c!=null);
        System.assert(output.SE_Director__c!=null);
        System.assert(output.SE__c!=null);
    }
    @IsTest
    public static void TestApprovers_APAC()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account speAcc = new Account(Name='EMAIL SUPPORT CONTACTS');
        insert speAcc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        opportunity.Technical_Responsible__c=SEId.Id;
        opportunity.OwnerId=ownerId.Id;
        opportunity.Sales_Region__c='APAC';
        insert opportunity;
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='WAN Op';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'VX-2000';
        pocRequest.VirtualQuantity1__c= 5;
        
        insert pocRequest;  
        Request__c output=[Select Id , RSM__c,SE__c,RSM_Manager__c,RSM_VP_Sales__c,SE_Manager__c,SE_Director__c from Request__c where Id=:pocRequest.Id] ;
        System.assert(output.RSM_Manager__c!=null);
        System.assert(output.RSM__c!=null);
        System.assert(output.RSM_VP_Sales__c!=null);
        System.assert(output.SE_Manager__c!=null);
        System.assert(output.SE_Director__c!=null);
        System.assert(output.SE__c!=null); 
    }
    @IsTest
    public static void TestApprovers_Update()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account speAcc = new Account(Name='EMAIL SUPPORT CONTACTS');
        insert speAcc;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User owner2ndManagerId = new User(Alias = 'standt', Email='testUser2@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, 
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser2@uniquetest.com',IsActive=true);
        
        insert owner2ndManagerId;
        User owner1stManagerId = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner2ndManagerId.Id,
                                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com',IsActive=true);
        
        insert owner1stManagerId;
        User ownerId = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, managerId=owner1stManagerId.Id,
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com',IsActive=true);
        
        insert ownerId;
        
        User SE2ndManagerId = new User(Alias = 'standt', Email='testUser3@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, 
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser3@uniquetest.com',IsActive=true);
        
        insert SE2ndManagerId;
        User SE1stManagerId = new User(Alias = 'standt', Email='testUser4@uniquetest.com', 
                                       EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                       LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE2ndManagerId.Id,
                                       TimeZoneSidKey='America/Los_Angeles', UserName='testUser4@uniquetest.com',IsActive=true);
        
        insert SE1stManagerId;
        User SEId = new User(Alias = 'standt', Email='testUser5@uniquetest.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, managerId=SE1stManagerId.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser5@uniquetest.com',IsActive=true);
        
        insert SEId;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        opportunity.Technical_Responsible__c=SEId.Id;
        opportunity.OwnerId=ownerId.Id;
        opportunity.Sales_Region__c='APAC';
        insert opportunity;
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='WAN Op';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'VX-2000';
        pocRequest.VirtualQuantity1__c= 5;
        
        insert pocRequest;  
        Request__c output=[Select Id , RSM__c,SE__c,RSM_Manager__c,RSM_VP_Sales__c,SE_Manager__c,SE_Director__c from Request__c where Id=:pocRequest.Id] ;
        System.assert(output.RSM_Manager__c!=null);
        System.assert(output.RSM__c!=null);
        System.assert(output.RSM_VP_Sales__c!=null);
        System.assert(output.SE_Manager__c!=null);
        System.assert(output.SE_Director__c!=null);
        System.assert(output.SE__c!=null); 
        pocRequest.SE__c=null;
        pocRequest.SE_Director__c=null;
        pocRequest.SE_Manager__c=null;
        pocRequest.RSM__c=null;
        pocRequest.RSM_Manager__c=null;
        pocRequest.RSM_VP_Sales__c=null;
        Test.startTest();
        update pocRequest;
        pocRequest.Trigger_POC_Approvers__c=true;
        update pocRequest;
        Test.stopTest();
        output=[Select Id , RSM__c,SE__c,RSM_Manager__c,RSM_VP_Sales__c,SE_Manager__c,SE_Director__c from Request__c where Id=:pocRequest.Id] ;
        System.assert(output.RSM_Manager__c!=null);
        System.assert(output.RSM__c!=null);
        System.assert(output.RSM_VP_Sales__c!=null);
        System.assert(output.SE_Manager__c!=null);
        System.assert(output.SE_Director__c!=null);
        System.assert(output.SE__c!=null);
        
    }
    @IsTest
    public static void TestOrchCannotBeAddedonPOC()
    {
        Test.startTest();
        Account acc = new Account(Name='testECPOC',Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='test123',Unity_Orch_Location__c='US East (N. Virginia) (Current Production)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='EC-XS';
        request.Evaluation_Product_2__c='EC-XS';
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        request.Is_Unity_Cloud_Orchestrator__c=true;
        insert request;
        try
        {
            request = new Request__c(POC_Contact__c = contact.Id);
            request.POC_Type__c='EdgeConnect';
            request.Opportunity__c= opportunity.id;
            request.Evaluation_Product_1__c='EC-XS';
            request.Evaluation_Product_2__c='EC-XS';
            request.Quantity_Location_1__c=1;
            request.Quantity_Location_2__c=1;
            request.Is_Unity_Cloud_Orchestrator__c=true;
            insert request;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Unity Cloud Orchestrator cannot be requested as there is an existing active cloud orch asset or POC on this account.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
    @isTest
    static void testECToNonECPocRequest()
    {
        Account acc = new Account (Name='testEC');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id, FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalProduct2__c = 'EC-XS';
        request.PhysicalProduct3__c = 'EC-XS';
        request.PhysicalProduct4__c = 'EC-XS';
        request.PhysicalProduct5__c = 'EC-XS';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'EC-BASE-1Y';
        request.VirtualProduct2__c = 'EC-BASE-1Y';
        request.VirtualProduct3__c = 'EC-BASE-1Y';
        request.VirtualProduct4__c = 'EC-BASE-1Y';
        request.VirtualProduct5__c = 'EC-BASE-1Y';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;
        
        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.POC_Type__c='EdgeConnect';
        try
        {
            update request;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('EdgeConnect and Non-EdgeConnect products cannot be mixed') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }
        
    }  
    
    @isTest
    static void testNonECToECPocRequest()
    {
        Account acc = new Account (Name='testEC');
        insert acc;
        Contact contact = new Contact(AccountId=acc.Id,FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.PhysicalProduct1__c = 'NX-700';
        request.PhysicalProduct2__c = 'NX-1700';
        request.PhysicalProduct3__c = 'NX-2700';
        request.PhysicalProduct4__c = 'NX-3700';
        request.PhysicalProduct5__c = 'NX-5700';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'VRX-2';
        request.VirtualProduct2__c = 'VRX-2';
        request.VirtualProduct3__c = 'VRX-2';
        request.VirtualProduct4__c = 'VRX-2';
        request.VirtualProduct5__c = 'VRX-2';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;
        
        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.POC_Type__c='EdgeConnect';
        try
        {
            update request;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('EdgeConnect and Non-EdgeConnect products cannot be mixed') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }
        
    }  
    
    @isTest
    static void testUpdatePocRequest()
    {
        Account acc = new Account (Name='testEC');
        insert acc;
        Contact contact = new Contact(AccountID=acc.Id,FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.PhysicalProduct1__c = 'NX-700';
        request.PhysicalProduct2__c = 'NX-1700';
        request.PhysicalProduct3__c = 'NX-2700';
        request.PhysicalProduct4__c = 'NX-3700';
        request.PhysicalProduct5__c = 'NX-5700';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'VRX-2';
        request.VirtualProduct2__c = 'VRX-2';
        request.VirtualProduct3__c = 'VRX-2';
        request.VirtualProduct4__c = 'VRX-2';
        request.VirtualProduct5__c = 'VRX-2';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;
        
        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.Submission_Condition_Satisfied__c=true;
        try
        {
            update request;
        }
        catch(Exception e)
        {
            
        }
        System.assertEquals(true, request.Submission_Condition_Satisfied__c);
    } 
    @isTest(SeeAllData=true)
    static void testVirtualPOCFulfillmentController_VX()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'acme';
        contact.LastName = 'acme';
        contact.Email = 'abc@abc.com';
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        //opportunity.Pricebook2Id = pricebookId;
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Type__c = 'WAN Op';
        pocRequest.POC_Contact__c = contact.Id;
        pocRequest.GMS_Needed__c = 'Virtual';
        pocRequest.VirtualProduct1__c = 'VX-2000';
        //pocRequest.VirtualProduct2__c = 'VRX-2';
        pocRequest.Quantity_Location_1__c = 1;
        //pocRequest.Quantity_Location_2__c = 1;
        insert pocRequest;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
        
        controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        controller.save();
        
        pocRequest.Send_Email__c=true;
        update pocRequest;
        Test.stopTest();
        //controller.saveAssets();
        //controller.setLicenseEncryption();
    }
    @isTest(SeeAllData=true)
    static void testVirtualPOCFulfillmentController_VRX()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.FirstName = 'acme';
        contact.LastName = 'acme';
        contact.Email = 'abc@abc.com';
        insert contact;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        //opportunity.Pricebook2Id = pricebookId;
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Type__c = 'WAN Op';
        pocRequest.POC_Contact__c = contact.Id;
        pocRequest.GMS_Needed__c = 'Virtual';
        //pocRequest.VirtualProduct1__c = 'VX-2000';
        pocRequest.VirtualProduct1__c ='VRX-2';
        pocRequest.Quantity_Location_1__c = 1;
        //pocRequest.Quantity_Location_2__c = 1;
        insert pocRequest;
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
        
        controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        controller.save();
        
        pocRequest.Send_Email__c=true;
        update pocRequest;
        Test.stopTest();
        //controller.saveAssets();
        //controller.setLicenseEncryption();
    }
}