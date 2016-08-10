/*
 *  The controller of Renewal License page.
 */
 public class RenewalLicenseController
 {
    private Asset asset;
    
    public RenewalLicenseController(ApexPages.StandardController controller) 
    {
        asset = (Asset)controller.getRecord();
        License = new License__c();
        License.Start_Date__c = Date.today();
        List<License__c> existingLicenses = [select Id, License_Expiration__c from License__c where AssetId__c=:asset.Id order by License_Expiration__c desc nulls last limit 1];
        if(existingLicenses.size() > 0)
        {
            LastEndDate = (existingLicenses[0].License_Expiration__c == null) ? Date.today() : existingLicenses[0].License_Expiration__c;
        }
        else
        {
            LastEndDate = Date.today();
        }
        LicenseIdJSON = 'null';
    }
    
    public Boolean InProgress { get; set; }
    public String LicenseIdJSON { get; set; }
    public License__c License { get; set; }
    public Date LastEndDate { get; set; }
    
    public PageReference renewLicense()
    {
        License.AssetId__c = asset.Id;
        License.Contact_for_Notification__c = asset.ContactId;
        if(asset.Product2.Product_Category__c != 'GMS')
        {
            License.Quantity__c = 1;
        }
        License.RenewalKeyGenerated__c = true;
        
        Integer numberOfLicenses = (asset.Product2.NumberOfLicenses__c == null) ? 1 : asset.Product2.NumberOfLicenses__c.intValue();
        List<License__c> concretLicenses = new List<License__c>();
        List<License__c> existingLicenses = [select Id, Model__c, SerialNumber__c from License__c where AssetId__c=:asset.Id order by CreatedDate desc limit :numberOfLicenses];
        for(License__c existingLicense : existingLicenses)
        {
            License__c newLicense = License.clone(false, false, false, false);
            newLicense.Model__c = existingLicense.Model__c;
            newLicense.SerialNumber__c = existingLicense.SerialNumber__c;
            concretLicenses.add(newLicense);
        }
        
        try
        {
            insert concretLicenses;
            List<Id> licenseIds = new List<Id>();
            for(License__c license : concretLicenses)
            {
                licenseIds.add(license.Id);
            }
            VirtualAssetManager.encryptLicenses(licenseIds);
            InProgress = true;
            LicenseIdJSON = JSON.serialize(licenseIds);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'License is being generated...'));
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    @remoteAction
    public static Boolean hasLicenseGenerated(List<String> licenseId)
    {
        Integer pendingLicenses = [select count() from License__c where Id in :licenseId and Key__c = null];
        return pendingLicenses == 0;
    }
}