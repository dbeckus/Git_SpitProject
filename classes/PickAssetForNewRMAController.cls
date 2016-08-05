/**
 * Controller for page PickAssetForNewRMA
 */
public with sharing class PickAssetForNewRMAController 
{
    private final String ERROR_NoEntitled = 'Your appliance is not covered under a service agreement or plan. ' + 
        'Please contact your Silver Peak authorized reseller or Account Manager to renew your service plan. ' +
        'If you believe this unit is covered under service or warranty, ' +
        'please open a case to request your RMA and data correction on this unit.';
    
    private final String ERROR_NotFound = 'Not found.';
    
    public PickAssetForNewRMAController()
    {
        ShowAll = false;
        PageNumber = 1;
        PageSize = 50;
    }
    
    public String searchKey { get; set; }
    
    // Properties for pagination.
    public ApexPages.StandardSetController SetCtrl { get; set; }
    public List<Asset> Assets { get { if(SetCtrl != null) return (List<Asset>)SetCtrl.getRecords(); else return null;} }
    public Integer PageNumber { get; set; }
    public Integer RecordSize { get; set; }
    public Integer PageSize { get; set; }
    public Boolean ShowAll { get; set; }
    public Boolean HasPrevious { get { return SetCtrl.getHasPrevious(); } }
    public Boolean HasNext { get { return SetCtrl.getHasNext(); } }
    
    public PageReference searchRecord()
    {
        searchKey = searchKey.replace('-', '');
        searchKey = searchKey.replace('.', '');
        searchKey = searchKey.replace(',', '');
        Asset[] searchedAssets = [select Entitled_for_RMA__c from Asset where SerialNumber = :searchKey and Status='Customer Owned'];
        if(searchedAssets.size() > 0)
        {
            if(searchedAssets[0].Entitled_for_RMA__c != 0)
            {
                return new PageReference('/apex/newrma?id=' + searchedAssets[0].Id);
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_NoEntitled));
                return null;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_NotFound));
            return null;
        }
    }
    
    public PageReference showAllRecord()
    {
        SetCtrl = new ApexPages.StandardSetController([select SerialNumber, Entitled_for_RMA__c, Model__c from Asset where Status='Customer Owned' order by Model__c]);
        SetCtrl.setPageSize(PageSize);
        RecordSize = SetCtrl.getResultSize();
        ShowAll = true;
        return null;
    }
    
    public PageReference previous()
    {
        SetCtrl.previous();
        return null;
    }
    
    public PageReference next()
    {
        SetCtrl.next();
        return null;
    }
    
    public PageReference gotoRMA()
    {
        String assetId = ApexPages.CurrentPage().getParameters().get('aid');
        for(Asset asset : Assets)
        {
            if(asset.Id == assetId)
            {
                if(asset.Entitled_for_RMA__c == 0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_NoEntitled));
                    return null;
                }
                else
                {
                    return new PageReference('/apex/newrma?id=' + assetId);
                }
            }
        }
        return null;
    }
    
    @isTest
    public static void testPickAssetForNewRMAController()
    {
        PickAssetForNewRMAController controller = new PickAssetForNewRMAController();
        controller.showAllRecord();
        controller.previous();
        controller.next();
        controller.searchKey = 'searchKey';
        controller.searchRecord();
        controller.gotoRMA();
    }
}