@IsTest
public class TestPOCRenewalAssetsController {
    
    @IsTest(SeeAllData=True)
    public static void TestPocRenewalAssets_EdgeConnect()
    {
        Test.startTest();
        Account acc = new Account(Name='testECPOC');
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
        insert request;
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalQuantity1__c = 2;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        Test.stopTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.VirtualProduct5__c='EC-ORCH';
        request.VirtualQuantity5__c=1;
        update request;
        ApexPages.StandardController sc = new ApexPages.StandardController(request);
        VirtualPOCFulfillmentController vircontroller = new VirtualPOCFulfillmentController(sc);
        vircontroller.save();
        PageReference pageRef = new PageReference('/apex/POCAssetsRenewal?Id=' + request.Id);
        Test.setCurrentPage(pageRef);
        POCRenewalAssetsController renewController = new POCRenewalAssetsController(sc);
        renewController.License.License_Expiration__c = Date.today().addyears(1);
        System.assert(renewController.AssetList.size()>0);
        renewController.SaveAssets();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name from Asset where POCRequest__c =: request.Id];
        System.debug(asset[0].Product2.name);
        System.assertEquals(Date.today().addyears(1), asset[0].License_End_Date__c);
        
        
    }
    
    @IsTest(SeeAllData=True)
    public static void TestPocRenewalAssets_WanOP()
    {
        Test.startTest();
        Account acc = new Account(Name='testPOC');
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
        request.POC_Type__c='WAN Op';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='VRX-4';
        request.Evaluation_Product_2__c='VRX-4';
        request.VirtualProduct1__c='VRX-4';
        request.VirtualProduct2__c='VRX-6';
        request.VirtualQuantity1__c=1;
        request.VirtualQuantity2__c=1;
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        insert request;
        request.PhysicalProduct1__c = 'VX 3000';
        request.PhysicalQuantity1__c = 2;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        Test.stopTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        Request__c inputPOC =[Select VirtualProduct1__c, VirtualProduct2__c, VirtualProduct3__c,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c from Request__C where ID=: request.Id];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(request);
        VirtualPOCFulfillmentController vircontroller = new VirtualPOCFulfillmentController(sc);
        vircontroller.save();
        List<Asset> inputAsset = [Select License_End_Date__c,Product2.Name,Product2.Family from Asset where POCRequest__c =: request.Id];
        
        PageReference pageRef = new PageReference('/apex/POCAssetsRenewal?Id=' + request.Id);
        Test.setCurrentPage(pageRef);
        POCRenewalAssetsController renewController = new POCRenewalAssetsController(sc);
        renewController.License.License_Expiration__c = Date.today().addyears(1);
        System.assert(renewController.AssetList.size()>0);
        renewController.SaveAssets();
        List<Asset> asset = [Select License_End_Date__c,Product2.Name from Asset where POCRequest__c =: request.Id];
        System.debug(asset[0].Product2.name);
        System.assertEquals(Date.today().addyears(1), asset[0].License_End_Date__c);
        
        
    }
}