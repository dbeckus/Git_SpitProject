/*
 * Controlle of component NewCaseWithAsset
 */
public with sharing class NewCaseWithAssetController 
{
    public String   SerialNo        { get; set; }
    public Boolean  ShowAssets      { get; private set; }
    public Integer  AssetsPageNo    { get; private set; }
    public Integer  AssetsPageCount { get; private set; }
    public Integer  AssetsPageSize  { get; private set; }
    public String   AssetId         { get; private set; }

    public List<Asset> MyAssets
    {
        get
        {
            return [select Id, Name, SerialNumber, Model__c from Asset where Status = 'Customer Owned' order by Model__c limit 1000];
        }
    }

    public NewCaseWithAssetController()
    {
        AssetsPageNo = 0;
        AssetsPageSize = 50;
        Integer rmaCount = [select count() from Asset where Status = 'Customer Owned' limit 1000];
        AssetsPageCount = rmaCount / AssetsPageSize;
    }

    public PageReference searchAsset()
    {
        Asset asset = findAsset(SerialNo);
        if(asset != null)
        {
            AssetId = asset.Id;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No asset found'));
        }
        return null;
    }
    
    public PageReference showAssets()
    {
        ShowAssets = true;
        return null;
    }

    private Asset findAsset(String assetName)
    {
        assetName = trimName(assetName);
        List<Asset> assets = [select Id, Name from Asset where Name = :assetName];
        if(assets.size() > 0)
        {
            return assets[0];
        }
        else
        {
            return null;
        }
    }
    
    private String trimName(String assetName)
    {
        return assetName.replaceAll('-', '');
    }
    
    public PageReference nextPage()
    {
        AssetsPageNo++;
        if(AssetsPageNo <=0)
        {
            AssetsPageNo = 0;
        }
        return null;
    }
    
    public PageReference previousPage()
    {
        AssetsPageNo--;
        if(AssetsPageNo >= AssetsPageCount)
        {
            AssetsPageNo = AssetsPageCount -1;
        }
        return null;
    }
    
    @isTest
    static void test()
    {
        NewCaseWithAssetController controller = new NewCaseWithAssetController();
        List<Asset> assets = controller.MyAssets;
        controller.SerialNo = 'acme';
        controller.searchAsset();
        controller.showAssets();
        controller.nextPage();
        controller.previousPage();
    }
}