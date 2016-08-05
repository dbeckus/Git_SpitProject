global with sharing class SubscriptionAdminController{
   
    
    public String  assetWithSummaryJSON  { get; set; }
    public String  assetPhoneHomeSummary  { get; set; }
   
    public SubscriptionAdminController() {
        List<License__c>  assetWithSummary = [SELECT  AssetId__r.Status, AssetId__r.Contract_Type__c, Id,  Duration__c, AssetId__r.Account.Name, AssetId__r.Ship_Date__c,
                                            License_Expiration__c, Start_Date__c, AssetId__r.Model__c, Quantity__c,  SerialNumber__c, AssetId__c, Name, Key__c
                                            FROM License__c  
                                            where AssetId__r.Status ='Customer Subscription' and AssetId__r.Account.Name not in ( 'TESTING ACCOUNT', 'Virtual Upgrade - DO NOT SUPPORT') ];
         assetWithSummaryJSON= JSON.serialize(assetWithSummary);   
         List<Asset_Summary__c>  assetPhoneHomeSummaryList = [SELECT Asset__r.Name, LAN_Total_15_days__c, Last_Contact__c, Platform__c, 
                                 Reduction_Total_15_days__c, Release__c, WAN_Total_15_days__c FROM Asset_Summary__c where Asset__r.Status = 'Customer Subscription' ];
         assetPhoneHomeSummary= JSON.serialize(assetPhoneHomeSummaryList);   
    }    
    
    @RemoteAction
    public static List<Account> getAccounts(String inputString) {
        String modInput = inputString + '%';
         List<Account> accts =  [SELECT Name from Account WHERE Name like :modInput and Type in ('Customer') LIMIT 25];
         return accts;
    }
    
}