/*
 * Controller for page PickAssetForNewCase
 * for portal users only, they need to choose an asset to continue creating a new case.
 */
public with sharing class PickAssetForNewCaseController 
{
    public PickAssetForNewCaseController()
    {
        CurrentPage = 0;
        PageSize = 50;
        Integer rmaCount = [select count() from Asset where Status='Customer Owned' limit 1000];
        PageCount = rmaCount / PageSize;
    }
    
    public String SerialNo { get; set; }
    public Boolean ShowTable { get; set; }
    public Integer CurrentPage { get; set; }
    public Integer PageCount { get; set; }
    public Integer PageSize { get; set; }
    public List<Asset> MyAssets
    {
        get
        {
            return [select Id, Name, SerialNumber, Model__c from Asset where Status='Customer Owned' order by Model__c limit 1000];
        }
    }
    
    public PageReference redirect()
    {
        PageReference result = null;
        User currentUser = [select Id, Name, UserType from User where Id=:UserInfo.getUserId() limit 1];
        if(currentUser.UserType == 'Standard')
        {
            result = new PageReference('/setup/ui/recordtypeselect.jsp');
            result.getParameters().put('ent', 'Case');
            result.getParameters().put('retURL', '/500/o');
            result.getParameters().put('save_new_url', '/500/e?retURL=%2F500%2Fo');
        }
        return result;
    }
    
    public PageReference go()
    {
        Asset asset = findAsset(SerialNo);
        if(asset != null)
        {
            PageReference result = new PageReference('/500/e');
            result.getParameters().put('retURL', '/apex/PickAssetForNewCase');
            result.getParameters().put('Asset_lkid', asset.Id);
            result.getParameters().put('Asset', asset.Name);
            result.getParameters().put('nooverride', '1');
            for(String key : ApexPages.currentPage().getParameters().keySet())
            {
                if(key != 'save_new' && key != 'retURL')
                {
                    String value = ApexPages.currentPage().getParameters().get(key);
                    result.getParameters().put(key, value);
                }
            }
            return result;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No asset found'));
            return null;
        }
    }
    
    public PageReference show()
    {
        ShowTable = true;
        return null;
    }
    
    public PageReference nextPage()
    {
        CurrentPage++;
        if(CurrentPage <=0)
        {
            CurrentPage = 0;
        }
        return null;
    }
    
    public PageReference previousPage()
    {
        CurrentPage--;
        if(CurrentPage >= PageCount)
        {
            CurrentPage = PageCount -1;
        }
        return null;
    }
    
    private Asset findAsset(String assetName)
    {
        assetName = trimName(assetName);
        List<Asset> assets = [select Id, Name from Asset where Name=:assetName];
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
    
    @isTest
    static void testPickAssetForNewCaseController()
    {
        PickAssetForNewCaseController controller = new PickAssetForNewCaseController();
        List<Asset> assets = [select Id, Name from Asset limit 1];
        controller.SerialNo = assets[0].Name;
        PageReference result = controller.go();
        System.assert(result != null);
        controller.show();
        System.assert(controller.ShowTable);
        System.assert(controller.MyAssets != null);
        controller.nextPage();
        controller.previousPage();
        controller.redirect();
    }
}