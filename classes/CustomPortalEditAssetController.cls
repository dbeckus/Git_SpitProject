/*
 * The controller of VF page CustomPortalEditAsset.
 */

public class CustomPortalEditAssetController
{
    private Asset asset;
    
    public CustomPortalEditAssetController(ApexPages.StandardController controller)
    {
        asset = (Asset)controller.getRecord();
        IsSucceeded = false;
    }
    
    public Boolean IsSucceeded { get; private set; }
    
    public String CustomerNotes
    {
        get
        {
            return asset.Customer_Notes__c;
        }
        set
        {
            CustomerNotes = value;
            asset.Customer_Notes__c = value;
        }
    }
    
    public void saveRecord()
    {
        try
        {
            update asset;
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Successfully saved.');
            ApexPages.addMessage(pageMsg);
            IsSucceeded = true;
        }
        catch(DmlException ex)
        {
            ApexPages.addMessages(ex);
        }
    }
    
    @isTest
    static void testCustomPortalEditAssetController()
    {
        Asset testAsset = TestUtilities.createTestDataForCustomPortalEditAssetController();
        ApexPages.StandardController sc = new ApexPages.StandardController(testAsset);
        CustomPortalEditAssetController controller = new CustomPortalEditAssetController(sc);
        
        controller.CustomerNotes = 'test';
        controller.saveRecord();
        
        system.assertEquals('test', controller.CustomerNotes);
        testAsset = [select Id, Customer_Notes__c from Asset where Id = :testAsset.Id];
        system.assertEquals('test', testAsset.Customer_Notes__c);
        
        controller.CustomerNotes = '123456789,123456789,123456789,123456789,123456789,';
        controller.CustomerNotes += '123456789,123456789,123456789,123456789,123456789,123456789,';
        controller.saveRecord();
    }
}