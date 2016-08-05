/*
* Controller for page PickAssetForNewCma
*/
public with sharing class PickAssetForNewCmaController
{
    private Set<String> models;

    public PickAssetForNewCmaController()
    {
        ShowAll = false;
        PageNumber = 1;
        PageSize = 50;
        IsShowErrorMessage = false;
        getNxModel();
        buildData();
    }

    public Boolean IsShowErrorMessage { get; set; }
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
        Asset[] searchedAssets = [select Id from Asset where SerialNumber = :searchKey and Status='Customer Owned' and Contract_Status__c = 'Activated' and Model__c in :models and Contract_End__c >= :Date.today()];
        if(searchedAssets.size() > 0)
        {
            return new PageReference('/apex/ConvertRmaToCma?id=' + searchedAssets[0].Id);
        }
        else
        {
            IsShowErrorMessage = true;
            return null;
        }
    }

    public PageReference cancel()
    {
        return new PageReference('/home/home.jsp');
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

    public PageReference goToCma()
    {
        String assetId = ApexPages.CurrentPage().getParameters().get('aid');
        return new PageReference('/apex/ConvertRmaToCma?id=' + assetId);
    }

    private void getNxModel()
    {
        models = new Set<String>();
        for(CmaProductMapping__c cma : [select Name, NX__c from CmaProductMapping__c])
        {
            models.add(cma.NX__c);
        }
    }

    private void buildData()
    {
        Asset[] allCmaAssets = [select Id, SerialNumber, Model__c from Asset where Status='Customer Owned' and Contract_End__c >= :Date.today()
                                    and Contract_Status__c = 'Activated' and Model__c in :models order by Model__c];
        if(allCmaAssets.size() > 0)
        {
            SetCtrl = new ApexPages.StandardSetController(allCmaAssets);
            SetCtrl.setPageSize(PageSize);
            RecordSize = SetCtrl.getResultSize();
            ShowAll = true;
        }
        else
        {
            IsShowErrorMessage = true;
        }
    }
}