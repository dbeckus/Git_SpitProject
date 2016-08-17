@IsTest
public class TestPOCExtensionController {
    @IsTest
    public static void POCTest_Active()
    {
        Id accountId = TestUtilities.createTestAccount();
        Id contactId = TestUtilities.createTestContact(accountId);
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = TestUtilities.createTestOpportunityRequest(accountId, standardPricebookId);
        opp.OwnerId = Userinfo.getUserId();
        
        Lead lead= TestUtilities.CreateTestLead();
        
        Request__c pocReq=  VirtualPOCFulfillmentController.createPOC(contactId, lead, 'EC-BASE-1Y','prane', opp);
        System.debug(pocReq.Status__c);
        System.assert(pocReq.Id != null);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            
            pocReq.Status__c='Shipped';
            pocReq.Target_End_Date__c=Date.today().addDays(30);
            update pocReq;
            //PageReference refer = new PageReference('/apex/ExtensionRequestPopup?Id='+pocReq.Id);
            //Test.setCurrentPage(refer);
            Test.startTest();
            POCExtensionController controller= new POCExtensionController(new ApexPages.StandardController(pocReq));
            controller.POCRequest.Extension_Justification__c='test';
            controller.SaveExtension();
            Test.stopTest();
        }
        
        
        
        
    }
    
    @IsTest
    public static void POCTest_PendingReturn()
    {
        Account emailSupportAcc= new Account(Name='Email Support Contacts');
        insert emailSupportAcc;
        Id accountId = TestUtilities.createTestAccount();
        Id contactId = TestUtilities.createTestContact(accountId);
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = TestUtilities.createTestOpportunityRequest(accountId, standardPricebookId);
        opp.OwnerId = Userinfo.getUserId();
        
        Lead lead= TestUtilities.CreateTestLead();
        
        Request__c pocReq=  VirtualPOCFulfillmentController.createPOC(contactId, lead, 'EC-BASE-1Y','prane', opp);
        System.debug(pocReq.Status__c);
        System.assert(pocReq.Id != null);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            Test.startTest();
            pocReq.Status__c='Pending Return';
            pocReq.Target_End_Date__c=Date.today();
            update pocReq;
            //PageReference refer = new PageReference('/apex/ExtensionRequestPopup?Id='+pocReq.Id);
            //Test.setCurrentPage(refer);
            
            POCExtensionController controller= new POCExtensionController(new ApexPages.StandardController(pocReq));
            controller.POCRequest.Extension_Justification__c='test';
            controller.SaveExtension();
            Test.stopTest();
        }
        
        
        
        
    }
    @IsTest
    public static void POCTest_ValidationMessage1()
    {
        Account emailSupportAcc= new Account(Name='Email Support Contacts');
        insert emailSupportAcc;
        Id accountId = TestUtilities.createTestAccount();
        Id contactId = TestUtilities.createTestContact(accountId);
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = TestUtilities.createTestOpportunityRequest(accountId, standardPricebookId);
        opp.OwnerId = Userinfo.getUserId();
        
        Lead lead= TestUtilities.CreateTestLead();
        
        Request__c pocReq=  VirtualPOCFulfillmentController.createPOC(contactId, lead, 'EC-BASE-1Y','prane', opp);
        System.debug(pocReq.Status__c);
        System.assert(pocReq.Id != null);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            Test.startTest();     
            try
            {
                POCExtensionController controller= new POCExtensionController(new ApexPages.StandardController(pocReq));
                controller.SaveExtension();
            }
            catch(Exception ex)
            {
                System.assert(ex.getMessage().contains('Please enter the reason for POC Extension.'));
            }
            
            Test.stopTest();
        }
    }
     @IsTest
    public static void POCTest_ValidationMessage2()
    {
        Account emailSupportAcc= new Account(Name='Email Support Contacts');
        insert emailSupportAcc;
        Id accountId = TestUtilities.createTestAccount();
        Id contactId = TestUtilities.createTestContact(accountId);
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = TestUtilities.createTestOpportunityRequest(accountId, standardPricebookId);
        opp.OwnerId = Userinfo.getUserId();
        
        Lead lead= TestUtilities.CreateTestLead();
        
        Request__c pocReq=  VirtualPOCFulfillmentController.createPOC(contactId, lead, 'EC-BASE-1Y','prane', opp);
        System.debug(pocReq.Status__c);
        System.assert(pocReq.Id != null);
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            Test.startTest();     
            try
            {
                POCExtensionController controller= new POCExtensionController(new ApexPages.StandardController(pocReq));
                controller.POCRequest.Extension_Justification__c='test';
                controller.POCRequest.Requested_End_Date__c=null;
                controller.SaveExtension();
            }
            catch(Exception ex)
            {
                System.assert(ex.getMessage().contains('Please enter Extend To Date.'));
            }
            
            Test.stopTest();
        }
    }
}