/**
* Controller of VF page OpenRMA.
*/

public class OpenRMAController
{
    private String accountId;
    private String retURL;
    private Set<String> assetIds;
    public string AssetStatus {get;set;}
    public OpenRMAController(ApexPages.StandardSetController controller)
    {
        accountId = ApexPages.currentPage().getParameters().get('parent');
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        String assetIdsStr = ApexPages.currentPage().getParameters().get('sa');
        assetIds = NewRMAHelper.splitAssetIds(assetIdsStr);
        AssetStatus='Pending Return – Eval';
       
    }
    
    public String ContactId { get; set; }
    
    public List<AssetWrapper> Assets
    {
        get
        {
            List<AssetWrapper> lstAssetWrapper=new List<AssetWrapper>();
            if(Assets == null)
            {
                System.debug('assetIds'+assetIds);
                List<Asset> lstAssets = [select Id, Name, Product2Id, Product2.ProductCode, Product2.Name, Ship_Date__c, Status, Evaluation_End_Date__c, Warranty_End_Date__c, Contract_Number__c, Contract_Type__c, Contract_End__c from Asset where AccountID=:accountId and Product2.Family='Product' ];
                if(lstAssets!=null && lstAssets.size()>0)
                {
                    for(Asset item:lstAssets)
                    {
                        string assetId=String.valueOf(item.id);
                        if(assetIds.contains(assetId.substring(0,15)))
                        {
                            System.debug('true');
                            lstAssetWrapper.add(new AssetWrapper(true,item));
                        }
                        else
                        {
                            lstAssetWrapper.add(new AssetWrapper(false,item));
                        }
                        
                    }
                    
                }
            }
            return lstAssetWrapper;
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
            Set<String> selectedAssetIds= new Set<String>();
            if(Assets!=null && Assets.size()>0)
            {
                for(AssetWrapper item: Assets)
                {
                    if(item.IsSelected)
                    {
                        selectedAssetIds.add(item.AssetData.Id);
                    }
                    
                }
            }
            
            System.debug('AssetStatus'+AssetStatus);
            //Boolean isSucceeded = NewRMAHelper.createRmaWithAssetStatus(selectedAssetIds, ContactId, AssetStatus);
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
    
    public class AssetWrapper 
    {
        public Boolean IsSelected {get;set;}
        public Asset AssetData{get;set;}
        
        public AssetWrapper(boolean isCheck, Asset assetInfo)
        {
            IsSelected=isCheck;
            AssetData=assetInfo;
        }
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