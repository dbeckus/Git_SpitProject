@isTest
public class VirtualPOCFulfillmentControllerTest
{
    
     @IsTest(SeeAllData=true)
    static void testVirtualPOCFulfillmentController()
    {
        
        Request__c pocRequest = TestUtilities.createTestDataForVirtualPOCFulfillmentController();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
        
        controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        //system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        controller.save();
        Test.stopTest();
        //controller.saveAssets();
        //controller.setLicenseEncryption();
    }
     @IsTest
    static void testVirtualECPOCFulfillmentController()
    {
        Test.startTest();
        Request__c pocRequest = TestUtilities.createTestDataForVirtualPOCFulfillmentControllerECproduct();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
      	controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        //system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        Test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
    
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
           
           controller.save();
            
        }
       
        
        //controller.setLicenseEncryption();
    }
      @IsTest
    static void testVirtualECOrchFulfillmentController()
    {
         Test.startTest();
        Request__c pocRequest = TestUtilities.createTestDataForVirtualPOCECORCHESTRATOR();
        
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
        Test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
    
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
           
           controller.save();
            
        }
        
        //controller.setLicenseEncryption();
    }
    @isTest
    static void testVirtualECOrchFulfillmentController_Perpetual()
    {
        
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
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
        Test.startTest();
        insert pocRequest;     
      
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
        controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        //system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        Test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
    
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
           
           controller.save();
            
        }
        
        //controller.setLicenseEncryption();
    }
    @IsTest
    static void testVirtualECOrchFulfillmentController_Metered()
    {
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Metered',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
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
        
        insert opportunity;
       
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='Metered';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'EC-SP-MET';
        pocRequest.VirtualQuantity1__c= 1;
      	Test.startTest();
        insert pocRequest;     
       
        ApexPages.StandardController sc = new ApexPages.StandardController(pocRequest);
        VirtualPOCFulfillmentController controller = new VirtualPOCFulfillmentController(sc);
        controller.addAsset();
        Integer maxIndex = controller.VirtualAssets.size() - 1;
        //system.debug(controller.ProductOptions);
        for(Integer i = maxIndex; i >= 0; i--)
        {
            ApexPages.currentPage().getParameters().put('rmIndex', String.valueOf(i));
            controller.removeAsset();
        }
        Test.stopTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
    
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
           
           controller.save();
            
        }
        
        //controller.setLicenseEncryption();
    }
      @IsTest(SeeAllData=true)
    static void testCreatePOC()
    {
        Id accountId = TestUtilities.createTestAccount();
        Id contactId = TestUtilities.createTestContact(accountId);
		
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = TestUtilities.createTestOpportunityRequest(accountId, standardPricebookId);
        opp.OwnerId = Userinfo.getUserId();
         
		Lead lead= TestUtilities.CreateTestLead();
       
      	Request__c pocReq=  VirtualPOCFulfillmentController.createPOC(contactId, lead, 'EC-BASE-1Y','prane', opp);
       	System.assert(pocReq.Id != null);
      
    }
}