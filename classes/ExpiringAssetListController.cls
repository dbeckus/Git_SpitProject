/*
* Controller of ExpiringAssetList VF component.
* Get a list of assets which will expirate on license end date and related to a contact.
*/

public with sharing class ExpiringAssetListController 
{
    public Id ContactId                   { get; set; }
    public Id AccountId                   { get; set; }
    public Date LicenseExpirationDate     { get; set; } 
    public Boolean IsECAsset     { get; set; } 
    public List<Asset> Assets 
    {
        get
        {
            if(AccountId == null)
            {
                if(IsECAsset)
                {
                    return [SELECT SerialNumber, Model__c,Licenses_Nodes__c,Bandwidth_Nodes__c,EC_Product_Name__c FROM Asset WHERE Product2.Name like 'EC%' and  License_End_Date__c = :LicenseExpirationDate AND ContactId = :ContactId ORDER BY SerialNumber];
                }
                else
                {
                    return [SELECT SerialNumber, Model__c,Licenses_Nodes__c,Bandwidth_Nodes__c,EC_Product_Name__c FROM Asset WHERE (NOT Product2.Name like 'EC%') and License_End_Date__c = :LicenseExpirationDate AND ContactId = :ContactId ORDER BY SerialNumber];
                }
                
            }
            else
            {
                if(IsECAsset)
                {
                    return [SELECT SerialNumber, Model__c,Licenses_Nodes__c,Bandwidth_Nodes__c,EC_Product_Name__c FROM Asset WHERE Product2.Name like 'EC%' and AccountId=:AccountId and License_End_Date__c = :LicenseExpirationDate AND ContactId = :ContactId ORDER BY SerialNumber];
                }
                else
                {
                    return [SELECT SerialNumber, Model__c,Licenses_Nodes__c,Bandwidth_Nodes__c,EC_Product_Name__c FROM Asset WHERE (NOT Product2.Name like 'EC%') and AccountId=:AccountId and License_End_Date__c = :LicenseExpirationDate AND ContactId = :ContactId ORDER BY SerialNumber];
                }
                
            }
        }
    }
    
    @isTest
    static void testExpiringAssetListController()
    {
        ExpiringAssetListController controller = new ExpiringAssetListController();
        controller.IsECAsset=false;
        List<Asset> assets = controller.Assets; 
    }
}