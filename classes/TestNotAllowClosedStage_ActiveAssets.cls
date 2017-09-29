@IsTest
public class TestNotAllowClosedStage_ActiveAssets {
    
    /*@IsTest(SeeAllData=true)
    public static void TestData_Error()
    {
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship',Email='abc@abc.com');
        insert ct;
        Product2 prd = new Product2(Name='EC-XS', Family='Product', IsActive=true, ProductCode='500210-001');
        insert prd;
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        opportunity.Pricebook2Id = standardPricebookId;
        opportunity.StageName = 'New';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Contact__c = ct.id;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = '';
        pocRequest.PhysicalProduct1__c = 'EC-XS';
        pocRequest.Quantity_Location_1__c = 1;
        insert pocRequest;
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?pocId=' + pocRequest.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController controller = new ShippingInputFormController();
        controller.SNSets = '123456789012';
        controller.Process();
        controller.getProductList();
        controller.getPartNumberList();
        controller.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = controller.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        controller.ShippedLineList[0].SelectProductId = prd.Id;
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
        Test.stopTest();
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :controller.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        try
        {
            opportunity.StageName='Closed Dead';
            update opportunity;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This selected stage cannot be updated as it has active physical assets.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Opportunity resultOpp=[Select StageName from Opportunity where Id=:opportunity.Id];
        System.assertEquals('New', resultOpp.StageName);
    }
    
    @IsTest(SeeAllData=true)
    public static void TestData()
    {
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship',Email='abc@abc.com');
        insert ct;
        Product2 prd = new Product2(Name='EC-XS', Family='Product', IsActive=true, ProductCode='500210-001');
        insert prd;
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        opportunity.Pricebook2Id = standardPricebookId;
        opportunity.StageName = 'New';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Contact__c = ct.id;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = '';
        pocRequest.PhysicalProduct1__c = 'EC-XS';
        pocRequest.Quantity_Location_1__c = 1;
        insert pocRequest;
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?pocId=' + pocRequest.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController controller = new ShippingInputFormController();
        controller.SNSets = '123456789012';
        controller.Process();
        controller.getProductList();
        controller.getPartNumberList();
        controller.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = controller.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        controller.ShippedLineList[0].SelectProductId = prd.Id;
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
        Test.stopTest();
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :controller.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        try
        {
            opportunity.StageName='Meets Customer Requirements';
            update opportunity;
            
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This selected stage cannot be updated as it has active physical assets.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Opportunity resultOpp=[Select StageName from Opportunity where Id=:opportunity.Id];
        System.assertEquals('Meets Customer Requirements', resultOpp.StageName);
        
    }*/
}