@isTest
public class ShippingInputFormControllerTest
{
	  @isTest
    static void testShippingInputFormController()
    {
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship');
        insert ct;
        Product2 prd = new Product2(Name='acme', Family='Product', IsActive=true, ProductCode='acme');
        insert prd;
        Asset asset = new Asset(Name = 'test', SerialNumber = '123456789012', AccountId = account.Id, ContactId = ct.Id, Product2Id=prd.Id);
        insert asset;
        Asset asset2 = new Asset(Name = 'test2', SerialNumber = '123456789013', AccountId = account.Id, ContactId = ct.Id, Product2Id=prd.Id);
        insert asset2;
        
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?accountId=' + account.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController controller = new ShippingInputFormController();
        controller.SNSets = '123456789012, 1234567890ab';
        controller.Process();
        controller.Shipment.To_Be_Swapped_Asset__c = asset2.Id;
        controller.getProductList();
        controller.getPartNumberList();
        
        List<ShippingInputFormController.ShipLineInfo> lines = controller.ShippedLineList;
        System.assertEquals(2, lines.size());
        System.assertEquals(true, lines[0].AssetIsExisted);
        System.assertEquals(false, lines[1].AssetIsExisted);
        lines[1].SelectProductId = prd.Id;
        
        controller.Save();
        System.assertEquals(0, ApexPages.getMessages().size());
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :controller.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        
        asset2 = [select Id, Status from Asset where Id=:asset2.Id limit 1];
        System.assertEquals('Pending Return – Support', asset2.Status);
    }
    
     @isTest
    static void testShippingInputFormControllerForPOC()
    {
       	
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship',Email='abc@abc.com');
        insert ct;
        Product2 prd = new Product2(Name='EC-XS', Family='Product', IsActive=true, ProductCode='500210-001');
        insert prd;
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Id opportunityId = TestUtilities.createTestOpportunity(account.Id, standardPricebookId);
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunityId;
        pocRequest.POC_Contact__c = ct.id;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = '';
        pocRequest.PhysicalProduct1__c = 'EC-XS';
        pocRequest.Quantity_Location_1__c = 1;
        insert pocRequest;
        //System.assert(pocRequest.id!=null);
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
        
    }
    
    
    @isTest
    static void testGetAssetPartNumber()
    {
        
        Product2 p = new Product2(Name='acme', ProductCode='acme2');
        insert p;
        ReplaceablePartNumberMatrix__c entry = new ReplaceablePartNumberMatrix__c(Name='acme', Asset_PN__c='acme1', Product_PN__c='acme2');
        insert entry;
        System.assertEquals(1, ShippingInputFormController.getAssetPartNumber(p.Id).size());
    }
    
    @isTest
    static void testIsValidSerialNumber()
    {
        PageReference ref = new PageReference('/apex/ShippingInputFormInternal');
        Test.setCurrentPage(ref);
        ShippingInputFormController controller = new ShippingInputFormController();
        System.assert(controller.isValidSerialNumber('1234567890ab'));
        System.assert(!controller.isValidSerialNumber('1234567890ax'));
        System.assert(controller.isValidSerialNumber('12-34-56-78-90-ab'));
        System.assert(!controller.isValidSerialNumber('12-34-56-78-90-ab-'));
        System.assert(!controller.isValidSerialNumber('12-34-56-78-90ab'));
        System.assert(controller.isValidSerialNumber('1234.5678.90ab'));
        System.assert(!controller.isValidSerialNumber('1234.567890ab'));
        System.assert(!controller.isValidSerialNumber('1234.5678.90ab.'));
        System.assert(!controller.isValidSerialNumber('.1234.5678.90ab'));
    }
    
     
}