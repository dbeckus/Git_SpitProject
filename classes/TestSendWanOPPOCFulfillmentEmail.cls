@IsTest
public class TestSendWanOPPOCFulfillmentEmail {
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