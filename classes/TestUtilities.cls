/*
 * This class provides the methods to create test data.
 */

public class TestUtilities
{
    //Creates test data for the test methods of "VirtualPOCFulfillmentController".
    public static Request__c createTestDataForVirtualPOCFulfillmentController()
    {
        Id accountId = createTestAccount();
        Id contactId = createTestContact(accountId);
        Id standardPricebookId = getStandardPricebookId();
        Id opportunityId = createTestOpportunity(accountId, standardPricebookId);
        return createTestPOCRequest(opportunityId, contactId);
    }
//Creates test data for the test methods of "VirtualPOCFulfillmentController".
    public static Request__c createTestDataForVirtualPOCFulfillmentControllerECproduct()
    {
        Id accountId = createTestAccount();
        Id contactId = createTestContact(accountId);
        Id standardPricebookId = getStandardPricebookId();
        Id opportunityId = createTestOpportunity(accountId, standardPricebookId);
        return createTestECPOCRequest(opportunityId, contactId);
    }    
    
    public static Request__c createTestDataForVirtualPOCECORCHESTRATOR()
    {
        Id accountId = createTestAccount();
        Id contactId = createTestContact(accountId);
        Id standardPricebookId = getStandardPricebookId();
        Id opportunityId = createTestOpportunity(accountId, standardPricebookId);
        return createTestECORCHPOCRequest(opportunityId, contactId);
    }    
	
    //Creates test data for the test methods of "CustomPortalEditAssetController".
    public static Asset createTestDataForCustomPortalEditAssetController()
    {
        Id accountId = createTestAccount();
        Product2 product = createTestProduct();
        return createTestAsset(accountId, product.Id);
    }
    
    public static Id createTestAccount()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        return account.Id;
    }
    
    public static Id createTestContact(Id accountId)
    {
        Contact contact = new Contact();
        contact.AccountId = accountId;
        contact.FirstName = 'acme';
        contact.LastName = 'acme';
        contact.Email = 'abc@abc.com';
        insert contact;
        return contact.Id;
    }
    
    public static Id createTestOpportunity(Id accountId, Id pricebookId)
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = accountId;
        opportunity.Pricebook2Id = pricebookId;
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        return opportunity.Id;
    }
    public static opportunity createTestOpportunityRequest(Id accountId, Id pricebookId)
    {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = accountId;
        opportunity.Pricebook2Id = pricebookId;
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        return opportunity;
    }    
    
     public static Lead CreateTestLead()
    {
        Lead lead = new Lead();
        lead.Company ='acme';
        lead.LastName='test lastName';
        
        //lead.OwnerId = Userinfo.getUserId();
        insert lead;
        return lead;
    }    
    
    
    public static Product2 createTestProduct()
    {
        Product2 product = new Product2();
        product.Name = 'acme';
        product.ProductCode = 'acme';
        insert product;
        return product;
    }
    
    public static Asset createTestAsset(Id accountId, Id productId)
    {
        Asset asset = new Asset();
        asset.Name = 'acme';
        asset.SerialNumber = '000000';
        asset.AccountId = accountId;
        asset.Product2Id = productId;
        insert asset;
        return asset;
    }
    
    public static Request__c createTestPOCRequest(Id opportunityId, Id contactId)
    {
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunityId;
        pocRequest.POC_Contact__c = contactId;
        pocRequest.GMS_Needed__c = 'Virtual';
        pocRequest.Evaluation_Product_1__c = 'VX 3000';
        pocRequest.Evaluation_Product_2__c = 'VX 5000';
        pocRequest.Quantity_Location_1__c = 1;
        pocRequest.Quantity_Location_2__c = 1;
        insert pocRequest;
        return pocRequest;
    }
    public static Request__c createTestECPOCRequest(Id opportunityId, Id contactId)
    {
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunityId;
        pocRequest.POC_Contact__c = contactId;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = 'Virtual';
        pocRequest.Evaluation_Product_1__c = 'EC-BASE-1Y';
        pocRequest.Evaluation_Product_2__c = 'EC-BASE-1Y';
        pocRequest.Quantity_Location_1__c = 1;
        pocRequest.Quantity_Location_2__c = 1;
        insert pocRequest;
        return pocRequest;
    }
    
   
    public static Request__c createTestECORCHPOCRequest(Id opportunityId, Id contactId)
    {
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunityId;
        pocRequest.POC_Contact__c = contactId;
        pocRequest.GMS_Needed__c = 'Virtual';
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.Evaluation_Product_1__c = 'EC-ORCH';
        pocRequest.Quantity_Location_1__c = 1;
       
        insert pocRequest;
        return pocRequest;
    }
    public static RMA__c createTestRMA(Id accountId, Id contactId, Id pocRequestId)
    {
        RMA__c rma = new RMA__c();
        rma.Account__c = accountId;
        rma.Contact__c = contactId;
        rma.Request__c = pocRequestId;
        insert rma;
        return rma;
    }
    
    public static RMA_Item__c createTestRMAItem(Id rmaId, Id assetId, Id productId)
    {
        RMA_Item__c rmaItem = new RMA_Item__c();
        rmaItem.RMA__c = rmaId;
        rmaItem.Asset__c = assetId;
        rmaItem.Product2__c = productId;
        insert rmaItem;
        return rmaItem;
    }
    
    public static Id getStandardPricebookId()
    {
        Id pricebookId;
        Pricebook2[] pricebooks = [select Id from Pricebook2 where IsStandard = true and IsActive = true];
        if(!pricebooks.isEmpty())
        {
            pricebookId = pricebooks[0].Id;
        }
        return pricebookId;
    }
}