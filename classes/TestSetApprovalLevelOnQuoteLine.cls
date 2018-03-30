@IsTest
public class TestSetApprovalLevelOnQuoteLine {
    @IsTest(SeeAllData=true)
    public static void CheckApprovalLevel_EdgeConnect()
    {
        PriceBook2 pb1 = [select Id from Pricebook2 where Name='Enterprise' limit 1];
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        Account account = new Account(Name='acme', ownerId = testUser.Id,Registered_Discount_Product__c=10,Registered_Discount_EdgeConnect__c=20,Registered_Discount_Service__c=30);
        insert account;
        Account tierAcc = new Account(Name='acme',Type='Partner',Partner_Type__c='Reseller',Reseller_Agreement__c=true, ownerId = testUser.Id,Registered_Discount_Product__c=10,Registered_Discount_EdgeConnect__c=20,Registered_Discount_Service__c=30);
        insert tierAcc;
        Product2 product = new Product2(Name='EC-BASE-1Y',Product_Type__c='EDGECONNECT', Product_Category__c='Subscription', Family = 'Virtual Image');
        insert product;
        Opportunity opp = new Opportunity(OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id, Name='acme', AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        insert opp;
        PricebookEntry entry = [select Id, Product2Id, UnitPrice from PricebookEntry where PriceBook2Id=:pb1.Id and isActive = true limit 1];
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = entry.Id, Quantity = 123, TotalPrice = 1300);//, Product2Id = product.Id);
        insert oppLineItem;
        Quote__c quote = new Quote__c(Opportunity__c = opp.Id, Tier_1_Partner__c=tierAcc.id, Quote_Date__c = date.Today(), Quote_Valid_Until__c = date.Today()+10);
        insert quote;
        Quote_Line__c quoteLine = new Quote_Line__c(Quote__c = quote.Id, Product__c = product.Id, Unit_Price__c = 234, Quantity__c = 123, Discount_Percent__c = 25);
        insert quoteLine;
        Quote_Line__c quoteLinetest = [select ApprovalLevel__c, Id from Quote_Line__c where Id =: quoteLine.Id];
        system.assertEquals(quoteLinetest.ApprovalLevel__c, 1);
    }
    @IsTest(SeeAllData=true)
    public static void CheckApprovalLevel_NXVX()
    {
        PriceBook2 pb1 = [select Id from Pricebook2 where Name='Enterprise' limit 1];
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        Account account = new Account(Name='acme', ownerId = testUser.Id,Registered_Discount_Product__c=10,Registered_Discount_EdgeConnect__c=20,Registered_Discount_Service__c=30);
        insert account;
        Account tierAcc = new Account(Name='acme',Type='Partner',Partner_Type__c='Reseller',Reseller_Agreement__c=true, ownerId = testUser.Id,Registered_Discount_Product__c=10,Registered_Discount_EdgeConnect__c=20,Registered_Discount_Service__c=30);
        insert tierAcc;
        Product2 product = new Product2(Name='VX-2000',Model__c='VX-2000',Product_Type__c='NX/VX', Product_Category__c='Subscription', Family = 'Virtual Image');
        insert product;
        Opportunity opp = new Opportunity(OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id, Name='acme', Primary_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        insert opp;
        PricebookEntry entry = [select Id, Product2Id, UnitPrice from PricebookEntry where  PriceBook2Id=:pb1.Id and isActive = true limit 1];
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = entry.Id, Quantity = 123, TotalPrice = 1300);//, Product2Id = product.Id);
        insert oppLineItem;
        Quote__c quote = new Quote__c(Opportunity__c = opp.Id, Tier_1_Partner__c=tierAcc.id,Quote_Date__c = date.Today(), Quote_Valid_Until__c = date.Today()+10);
        insert quote;
        Quote_Line__c quoteLine = new Quote_Line__c(Quote__c = quote.Id, Product__c = product.Id, Unit_Price__c = 234, Quantity__c = 123, Discount_Percent__c = 15);
        insert quoteLine;
        Quote_Line__c quoteLinetest = [select ApprovalLevel__c, Id from Quote_Line__c where Id =: quoteLine.Id];
        system.assertEquals(quoteLinetest.ApprovalLevel__c, 1);
    }
    @IsTest(SeeAllData=true)
    public static void CheckApprovalLevel_Main()
    {
        PriceBook2 pb1 = [select Id from Pricebook2 where Name='Enterprise' limit 1];
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        Account account = new Account(Name='acme', ownerId = testUser.Id,Registered_Discount_Product__c=10,Registered_Discount_EdgeConnect__c=20,Registered_Discount_Service__c=30);
        insert account;
        Product2 product = new Product2(Name='NX-7700-RENEWAL-CONTRACT',Model__c='NX-7700',Product_Type__c='NX/VX', Product_Category__c='Maintenance-1 Day', Family = 'Service');
        insert product;
        Opportunity opp = new Opportunity(OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id, Name='acme', Primary_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        insert opp;
        PricebookEntry entry = [select Id, Product2Id, UnitPrice from PricebookEntry where  PriceBook2Id=:pb1.Id and isActive = true limit 1];
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = entry.Id, Quantity = 123, TotalPrice = 1300);//, Product2Id = product.Id);
        insert oppLineItem;
        Quote__c quote = new Quote__c(Opportunity__c = opp.Id, Quote_Date__c = date.Today(), Quote_Valid_Until__c = date.Today()+10);
        insert quote;
        Quote_Line__c quoteLine = new Quote_Line__c(Quote__c = quote.Id, Product__c = product.Id, Unit_Price__c = 234, Quantity__c = 123, Discount_Percent__c = 40);
        insert quoteLine;
        Quote_Line__c quoteLinetest = [select ApprovalLevel__c, Id from Quote_Line__c where Id =: quoteLine.Id];
        system.assertEquals(quoteLinetest.ApprovalLevel__c, 3);
    }

}