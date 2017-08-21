@IsTest
public class TestCalculateContractedAmounts {
    
    @isTest(SeeAllData=true)
    public static void TestCalculateContractedAmounts_EC()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline',Finance_Reviewed__c=true);
        insert testOpp;
        Product2 testsfProduct = new Product2(Name='EC-BASE-3Y', Forecast_Category__c = 'Virtual',Term__c=3, Family='Virtual Image', IsActive=true,Product_Type__c='EDGECONNECT',isQuotable__c=true,TCV_Enabled__c=true,ACV_Enabled__c=true,NTCV_Enabled__c=true);
        insert testsfProduct;
        Product2 testhdProduct = new Product2(Name='EC-L-SP', Forecast_Category__c = 'Product',Term__c=3, Family='Product', IsActive=true,Product_Type__c='EDGECONNECT',isQuotable__c=true,TCV_Enabled__c=false,ACV_Enabled__c=false,NTCV_Enabled__c=false);
        insert testhdProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
       	Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry entry1= new PricebookEntry(pricebook2id = stdPb.id, product2id = testsfProduct.id, unitprice=1.0, isActive=true);
        insert entry1;
        PricebookEntry entry2= new PricebookEntry(pricebook2id = stdPb.id, product2id = testhdProduct.id, unitprice=2.0, isActive=true);
        insert entry2;
      
        OpportunityLineItem lineItem1= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry1.id,Quantity=2,UnitPrice=2000);
        insert lineItem1;
        lineItem1.UnitPrice=3000;
        update lineItem1;
        OpportunityLineItem lineItem2= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry2.id,Quantity=2,UnitPrice=2000);
        insert lineItem2;
      	lineItem2.UnitPrice=3000;
        update lineItem2;
        Opportunity output=[Select Comp_Rate1__c,Total_Comp_Rate__c,Comp_Rate2__c,Annual_Contract_Value__c,Net_Contract_Value__c,Total_Contract_Value__c,ECSP_HDWR_Amount__c from Opportunity where Id=:testOpp.Id];
        System.assertEquals(2000, output.Annual_Contract_Value__c);
        System.assertEquals(6000, output.Total_Contract_Value__c);
        System.assertEquals(4000, output.Net_Contract_Value__c);
        
        System.assertEquals(2000, output.Comp_Rate1__c);
        System.assertEquals(6000, output.Total_Comp_Rate__c);
        System.assertEquals(4000, output.Comp_Rate2__c);
        Test.stopTest();
    }
   
    @isTest(SeeAllData=true)
    public static void TestCalculateContractedAmounts_NX()
    {
        Test.startTest();
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems');
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline',Finance_Reviewed__c=true);
        insert testOpp;
        Product2 testsfProduct = new Product2(Name='VX-3000', Forecast_Category__c = 'Virtual',Term__c=3, Family='Virtual Image', IsActive=true,Product_Type__c='NX/VX',isQuotable__c=true,TCV_Enabled__c=true,ACV_Enabled__c=true,NTCV_Enabled__c=true);
        insert testsfProduct;
        Product2 testhdProduct = new Product2(Name='NX-5000', Forecast_Category__c = 'Product', Family='Product', IsActive=true,Product_Type__c='NX/VX',isQuotable__c=true,TCV_Enabled__c=true,ACV_Enabled__c=true,NTCV_Enabled__c=true);
        insert testhdProduct;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id);
        insert testContact;
       	Pricebook2 stdPb = [select Id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry entry1= new PricebookEntry(pricebook2id = stdPb.id, product2id = testsfProduct.id, unitprice=1.0, isActive=true);
        insert entry1;
        PricebookEntry entry2= new PricebookEntry(pricebook2id = stdPb.id, product2id = testhdProduct.id, unitprice=2.0, isActive=true);
        insert entry2;
      
        OpportunityLineItem lineItem1= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry1.id,Quantity=2,UnitPrice=3000);
        insert lineItem1;
        lineItem1.UnitPrice=3000;
        update lineItem1;
        OpportunityLineItem lineItem2= new OpportunityLineItem(OpportunityId=testOpp.Id, pricebookentryid=entry2.id,Quantity=2,UnitPrice=3000);
        insert lineItem2;
      	lineItem2.UnitPrice=3000;
        update lineItem2;
            
        Opportunity output=[Select Comp_Rate1__c,Total_Comp_Rate__c,Comp_Rate2__c,Annual_Contract_Value__c,Net_Contract_Value__c,Total_Contract_Value__c,ECSP_HDWR_Amount__c from Opportunity where Id=:testOpp.Id];
        System.assertEquals(0, output.Annual_Contract_Value__c);
        System.assertEquals(0, output.Total_Contract_Value__c);
        System.assertEquals(0, output.Net_Contract_Value__c);
        
        System.assertEquals(0, output.Comp_Rate1__c);
        System.assertEquals(12000, output.Total_Comp_Rate__c);
        System.assertEquals(12000, output.Comp_Rate2__c);
        Test.stopTest();
    }
    
}