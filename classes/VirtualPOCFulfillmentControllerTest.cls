@isTest
public class VirtualPOCFulfillmentControllerTest
{
    
    @isTest
    static void testVirtualPOCFulfillmentController()
    {
        Request__c pocRequest = TestUtilities.createTestDataForVirtualPOCFulfillmentController();
        
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
        //controller.saveAssets();
        //controller.setLicenseEncryption();
    }
    
      @isTest
    static void testVirtualECPOCFulfillmentController()
    {
        Test.startTest();
        Request__c pocRequest = TestUtilities.createTestDataForVirtualPOCFulfillmentControllerECproduct();
        
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
     @isTest(SeeAllData=true)
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