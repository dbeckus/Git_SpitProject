@isTest
public class NewVirtualAssetControllerTest
{
    @isTest
    static void test()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact(LastName = 'acme', AccountId = account.Id);
        insert contact;
        Opportunity opportunity = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = Date.today().addDays(10),Product_Type__c='Both');
        insert opportunity;
        Request__c pocRequest = new Request__c(Opportunity__c = opportunity.Id, POC_Contact__c = contact.Id);
        insert pocRequest;
        Product2 prd = new Product2(Name='acme', Family = 'Virtual Image', IsActive=true);
        insert prd;
        insert new Asset_Mac__c();
        
        PageReference pageRef = new PageReference('/apex/NewVirtualAsset?accountId=' + account.Id + '&requestId=' + pocRequest.Id + '&contactId=' + contact.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        
        Asset asset = new Asset();
        NewVirtualAssetController controller = new NewVirtualAssetController(new ApexPages.StandardController(asset));
        system.assert(controller.Products.size() > 0);
        controller.Asset.Product2Id = controller.Products[0].getValue();
        controller.Asset.Evaluation_End_Date__c = Date.today().addDays(30);
        controller.save();
        
        Test.stopTest();
        
        String assetId = controller.Asset.Id;
        system.assertEquals(true, [select Used__c from Asset_Mac__c where AssetId__c = :assetId limit 1].Used__c);
        system.assertEquals(1, [select count() from License__c where AssetId__c = :assetId]);
        
        controller.Asset = controller.Asset.clone();
        controller.saveAndNew();
    }
}