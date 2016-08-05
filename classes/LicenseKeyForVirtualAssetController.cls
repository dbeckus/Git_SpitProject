/* 
 * Controller for component LiccenseKeyForVirtualAsset
 */
public class LicenseKeyForVirtualAssetController
{
    public Integer LicenseIndex { get; set; }
    public Id AssetId { get; set; }
    public String LicenseKey
    {
        get
        {
            List<License__c> licenses = [select Id, Key__c from License__c where AssetId__c=:AssetId order by CreatedDate limit 1 offset :LicenseIndex];
            if(licenses.size() > 0)
            {
                return licenses[0].Key__c;
            }
            return '';
        }
    }
    
    @isTest
    static void testLicenseKeyForVirtualAssetController()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Asset asset = new Asset(Name='acme', AccountId=acc.Id);
        insert asset;
        License__c l1 = new License__c(AssetId__c=asset.Id, Key__c='1');
        License__c l2 = new License__c(AssetId__c=asset.Id, Key__c='2');
        insert l1;
        insert l2;
        
        LicenseKeyForVirtualAssetController controller = new LicenseKeyForVirtualAssetController();
        controller.AssetId = asset.Id;
        controller.LicenseIndex = 1;
        System.assertEquals('2', controller.LicenseKey);
    }
}