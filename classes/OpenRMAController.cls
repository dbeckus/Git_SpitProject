/**
 * Controller of VF page OpenRMA.
 */

public class OpenRMAController
{
    private String accountId;
    private String retURL;
    private Set<String> assetIds;
    
    public OpenRMAController(ApexPages.StandardSetController controller)
    {
        accountId = ApexPages.currentPage().getParameters().get('parent');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        String assetIdsStr = ApexPages.currentPage().getParameters().get('sa');
        assetIds = NewRMAHelper.splitAssetIds(assetIdsStr);
    }
    
    public String ContactId { get; set; }
    
    public List<Asset> Assets
    {
        get
        {
            if(Assets == null)
            {
                Assets = [select Id, Name, Product2Id, Product2.ProductCode, Product2.Name, Ship_Date__c, Status, Evaluation_End_Date__c, Warranty_End_Date__c, Contract_Number__c, Contract_Type__c, Contract_End__c from Asset where AccountID=:accountId and Product2.Family='Product' ];
            }
            return Assets;
        }
        private set;
    }
    
    public List<Contact> Contacts
    {
        get
        {
            if(Contacts == null)
            {
                Contacts = [select Id, Name, Email from Contact where AccountId = :accountId order by Name];
            }
            return Contacts;
        }
        private set;
    }
    
    public PageReference openRMA()
    {
        try
        {
            Boolean isSucceeded = NewRMAHelper.createRmaWithAssetStatus(assetIds, ContactId, 'Pending Return – CPO');
            return new PageReference(retURL);
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public PageReference cancel()
    {
        return new PageReference(retURL);
    }
    
    @isTest
    static void testOpenRMAController()
    {
        List<Asset> assets = NewRMAHelper.createTestAssets();
        Asset asset1 = assets[0];
        Asset asset2 = assets[1];
        String assetIds = String.valueOf(asset1.Id).subString(0,15) + ',' + String.valueOf(asset2.Id).subString(0,15);
        
        String url = '/apex/OpenRMA?parent=' + asset1.AccountId + '&retURL=%2F' + asset1.AccountId + '&sa=' + assetIds;
        PageReference pageRef = new PageReference(url);
        Test.setCurrentPage(pageRef);
        ApexPages.standardSetController setController = new ApexPages.standardSetController(assets);
        OpenRMAController controller = new OpenRMAController(setController);
        
        system.assertEquals(2, controller.Assets.size());
        system.assertEquals(1, controller.Contacts.size());
        controller.ContactId = controller.Contacts[0].Id;
        controller.openRMA();
        controller.cancel();
    }
}