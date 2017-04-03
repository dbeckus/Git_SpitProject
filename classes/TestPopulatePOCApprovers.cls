@IsTest
public class TestPopulatePOCApprovers {
   /* @IsTest
    public static void TestApprovers_SP()
    {
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
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
        insert opportunity;
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='Perpetual';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'EC-SP-50';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-100';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-200';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-1000';
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
    */
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
        update pocRequest;
        pocRequest.Trigger_POC_Approvers__c=true;
        update pocRequest;
        output=[Select Id , RSM__c,SE__c,RSM_Manager__c,RSM_VP_Sales__c,SE_Manager__c,SE_Director__c from Request__c where Id=:pocRequest.Id] ;
        System.assert(output.RSM_Manager__c!=null);
        System.assert(output.RSM__c!=null);
        System.assert(output.RSM_VP_Sales__c!=null);
        System.assert(output.SE_Manager__c!=null);
        System.assert(output.SE_Director__c!=null);
        System.assert(output.SE__c!=null);
        
    }
}