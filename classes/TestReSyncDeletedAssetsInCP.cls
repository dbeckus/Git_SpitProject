@IsTest
public class TestReSyncDeletedAssetsInCP {
    
    @IsTest
    public static void CheckSyncFlag()
    {
        Account testAccount = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert testAccount;
        Account spAccount = new Account(Name='Silver Peak Systems',EC_Customer_Date__c=Date.today());
        insert spAccount;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='New', ForecastCategoryName ='Omitted', AccountId=testAccount.Id,Product_Type__c='Both');
        insert testOpp;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        insert request;
        Product2 testProduct = new Product2(Name='EC-BASE-1Y',Model__c='EC-BASE-1Y',Product_Category__c='Subscription', Forecast_Category__c = 'Virtual', Family='Virtual Image', IsActive=true);
        insert testProduct;
        Asset asset = new Asset(Name='001HHD898JJJ',AccountId=testAccount.Id,Product2Id=testProduct.Id,Status='Customer Evaluation',POCRequest__c=request.Id);
        insert asset;
        delete asset;
        Account acc=[Select Sync_Virtual_Assets_with_CP__c from Account where Id=:testAccount.Id];
        System.assertEquals(true, acc.Sync_Virtual_Assets_with_CP__c);
        
    }
    
}