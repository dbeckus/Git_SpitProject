@IsTest
public class TestAutomatePOCRenewalExtensions {
    
    @IsTest(SeeAllData=True)
    public static void TestPocRenewalAssets_EdgeConnect()
    {
        
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
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
        opportunity.OwnerId=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.VirtualProduct5__c= 'EC-ORCH';
        request.VirtualQuantity5__c= 1;
        insert request;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        
        
        System.runAs(techUser)
        {
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            VirtualPOCFulfillmentController vircontroller = new VirtualPOCFulfillmentController(sc);
            vircontroller.save();
            List<Asset> asset = [Select License_End_Date__c,Product2.Name from Asset where POCRequest__c =: request.Id];
            System.assert(asset.size()>0);
            
            Request__C output=[Select Id,IsAllVirtual__c,Status__c,Target_End_Date__c from Request__c where Id=:request.Id];
            System.debug('output.IsAllVirtual__c'+output.IsAllVirtual__c);
            request.Status__c='Shipped - Extended';
            request.Target_End_Date__c=Date.today().addDays(10);
            update request;
            List<Asset> asset1 = [Select License_End_Date__c,Product2.Name,Is_Asset_Eligible_For_POC_Renewal_Ext__c from Asset where POCRequest__c =: request.Id];
            System.debug('output.Is_Asset_Eligible_For_POC_Renewal_Ext__c'+asset1[0].Is_Asset_Eligible_For_POC_Renewal_Ext__c);
            AutomatePOCRenewalExtensions obj = new AutomatePOCRenewalExtensions();
            Database.executeBatch(obj,1);
            Test.stopTest();
        }
        
      
        
        
    }
    
    @IsTest(SeeAllData=True)
    public static void TestPocRenewalAssets_ServiceProvider()
    {
        
        Account acc = new Account(Name='testECPOC',Partner_Type__c='Service Provider',ECSP__c=true);
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
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
        opportunity.OwnerId=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='Service Provider';
        request.Opportunity__c= opportunity.id;
        insert request;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        
        
        System.runAs(techUser)
        {
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            VirtualPOCFulfillmentController vircontroller = new VirtualPOCFulfillmentController(sc);
            vircontroller.save();
            List<Asset> asset = [Select License_End_Date__c,Product2.Name from Asset where POCRequest__c =: request.Id];
            System.assert(asset.size()>0);
            
            Request__C output=[Select Id,IsAllVirtual__c,Status__c,Target_End_Date__c from Request__c where Id=:request.Id];
            System.debug('output.IsAllVirtual__c'+output.IsAllVirtual__c);
            request.Status__c='Shipped - Extended';
            request.Target_End_Date__c=Date.today().addDays(10);
            update request;
            List<Asset> asset1 = [Select License_End_Date__c,Product2.Name,Is_Asset_Eligible_For_POC_Renewal_Ext__c from Asset where POCRequest__c =: request.Id];
            System.debug('output.Is_Asset_Eligible_For_POC_Renewal_Ext__c'+asset1[0].Is_Asset_Eligible_For_POC_Renewal_Ext__c);
            AutomatePOCRenewalExtensions obj = new AutomatePOCRenewalExtensions();
            Database.executeBatch(obj,1);
            Test.stopTest();
        }
        
       
        
        
    }
    
    @IsTest(SeeAllData=True)
    public static void TestPocRenewalAssets_WanOp()
    {
        
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spacc = new Account(Name='Silver Peak Systems');
        insert spacc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
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
        opportunity.OwnerId=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.Opportunity__c= opportunity.id;
        request.VirtualProduct1__c='VX 500';
        request.VirtualQuantity1__c=1;
        insert request;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        
        
        System.runAs(techUser)
        {
            Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            VirtualPOCFulfillmentController vircontroller = new VirtualPOCFulfillmentController(sc);
            vircontroller.save();
            List<Asset> asset = [Select License_End_Date__c,Product2.Name from Asset where POCRequest__c =: request.Id];
            System.assert(asset.size()>0);
            
            Request__C output=[Select Id,IsAllVirtual__c,Status__c,Target_End_Date__c from Request__c where Id=:request.Id];
            System.debug('output.IsAllVirtual__c'+output.IsAllVirtual__c);
            request.Status__c='Shipped - Extended';
            request.Target_End_Date__c=Date.today().addDays(10);
            update request;
            List<Asset> asset1 = [Select License_End_Date__c,Product2.Name,Is_Asset_Eligible_For_POC_Renewal_Ext__c from Asset where POCRequest__c =: request.Id];
            System.debug('output.Is_Asset_Eligible_For_POC_Renewal_Ext__c'+asset1[0].Is_Asset_Eligible_For_POC_Renewal_Ext__c);
            AutomatePOCRenewalExtensions obj = new AutomatePOCRenewalExtensions();
            Database.executeBatch(obj,1);
            Test.stopTest();
        }
    }    
    
    
}