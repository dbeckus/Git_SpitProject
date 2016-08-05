/*
 * Controller of page GenerateGxLicense
 */
public with sharing class GenerateGmsLicenseController 
{
    private Asset assetRecord;
    
    public GenerateGmsLicenseController(ApexPages.StandardController controller)
    {
        assetRecord = (Asset)controller.getRecord();
        InProgress = false;
        if(assetRecord.Product2.Product_Category__c != 'GMS' && assetRecord.Product2.Model__c != 'GX-V')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'You can only generate GMS license on a GMS asset.'));
        }
        License = new License__c(AssetId__c=assetRecord.Id, SerialNumber__c=assetRecord.SerialNumber, Model__c=assetRecord.Model__c, Start_Date__c=assetRecord.Evaluation_Start_Date__c, License_Expiration__c=assetRecord.Evaluation_End_Date__c, Contact_for_Notification__c=assetRecord.ContactId);
        try
        {
            License.Quantity__c= Integer.valueOf(assetRecord.GMS_Nodes__c);
        }
        catch(Exception ex)
        {
        }
    }

    public License__c License { get; set; }
    public Boolean InProgress { get; set; }
    
    public PageReference save()
    {
        try
        {
            upsert License;
            update new Asset(Id=assetRecord.Id, GMS_Nodes__c=String.valueOf(License.Quantity__c), GMS_Upgrading__c=true);
            VirtualAssetManager.encryptLicense(License.Id);
            InProgress = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'License is being generated...'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    @remoteAction
    public static Boolean hasLicenseGenerated(String licenseId)
    {
        List<License__c> licenses = [select Key__c from License__c where Id=:licenseId limit 1];
        if(licenses.size() > 0)
        {
            return String.isNotBlank(licenses[0].Key__c);
        }
        return null;
    }
}