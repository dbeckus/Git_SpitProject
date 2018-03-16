/**
 Test methods of RenewalOpportunityController
 */
@isTest
public class RenewalOpportunityControllerTest
{
    @IsTest(SeeAllData=true)
    static void testRenewalOpportunityController()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
      //  insert usr;
       System.runAs(usr)
        {
        List<PriceBook2> pricebook = [select Id from Pricebook2 where Name = 'Enterprise' limit 1];
        Account acc = new Account(Name = 'acme',Default_PriceBook__c=pricebook[0].Id);
        insert acc;
        Opportunity opp = new Opportunity(Name = 'acme', CloseDate = System.today(), AccountId = acc.Id, StageName = 'Close Dead',
                                          Type = 'Support Renewal', Probability = 80, Opportunity_Source__c = 'RSM', ForecastCategoryName = 'Commit');
        insert opp;
        
       
        List<PriceBookEntry> entry = [select Id, Product2Id, ProductCode, UnitPrice from PricebookEntry where PriceBook2Id = :pricebook[0].Id and Product2.Family='Service' 
                                      and IsActive = true and ProductCode='300003-213' limit 1];
        OpportunityLineItem oppLine = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = entry[0].Id, Quantity = 1, UnitPrice = 10);
        insert oppLine;
        
        Test.startTest();
        
        PageReference page = new PageReference('/apex/RenewalOpportunity?id=' + opp.Id);
        Test.setCurrentPage(page);
        ApexPages.StandardController standardController = new ApexPages.StandardController(opp);
        RenewalOpportunityController controller = new RenewalOpportunityController(standardController);
        System.assertEquals(1, controller.NewProducts.size());
        
        controller.save();
        System.assert(controller.NewOpp.Id != null);

        Integer oldSize = controller.NewProducts.size();
        controller.addProduct();
        Integer newSize = controller.NewProducts.size();
        System.assertEquals(newSize, oldSize + 1);
        
        ApexPages.currentPage().getParameters().put('index', '0');
        controller.delProduct();
        newSize = controller.NewProducts.size();
        System.assertEquals(oldSize, newSize);
        
        String prdCode = RenewalOpportunityController.getProductCode((String)entry[0].Product2Id);
        System.assertEquals(entry[0].ProductCode, prdCode);
        
        System.assert(controller.ProductOptions.size() > 0);
        
        Test.stopTest();
        }
    }
}