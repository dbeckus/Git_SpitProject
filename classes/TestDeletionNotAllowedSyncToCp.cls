@IsTest
public class TestDeletionNotAllowedSyncToCp {
    
    @IsTest
    public static void CloudPortalAccountNotDelete()
    {
        Account acc = new Account(Name='test', Cloud_Portal_Account_Key__c='Test CloudPortal',Cloud_Portal_Account_Name__c='Name');
        insert acc;
        try
        {
            delete acc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
     @IsTest
    public static void CloudPortalAccountAssetsNotDelete()
    {
        Account acc = new Account(Name='test');
        insert acc;
        Product2 prod = new Product2(Name='EC-BASE-1Y', ProductCode='acme', Model__c='acme');
        insert prod;
        Asset asset= new Asset();
        asset.Name='test';
        asset.SerialNumber='test';
        asset.AccountId=acc.Id;
        asset.Product2Id=prod.Id;
        asset.Status='Customer Subscription Active';
        asset.Quantity=1;
        insert asset;
        try
        {
            delete acc;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
    }
    
}