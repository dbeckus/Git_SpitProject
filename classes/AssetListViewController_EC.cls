public with sharing class AssetListViewController_EC extends AssetListViewBase
{
    private Double PAGE_SIZE = 50.0; //The number of records on each page.
    private String sortField = '';
    public List<AccountInfo> ECAccountKeyList{get;set;}
    public AssetListViewController_EC()
    {
        PageNumber = 0;
        PageCount = 0;
        ListView = 'EdgeConnect_Subscriptions';
        initSort();
        SearchAsset = '';
        ServiceProvider = AssetUtilities.isServiceProvider();
        loadAssets();
        /*ECAccountKeyList= new List<AccountInfo>();
        if(AccountKeyList!=null && AccountKeyList.size()>0)
        {
            
            for(AccountInfo acInfo: AccountKeyList)
            {
                string prodName=acInfo.ProductName;
                if(prodName!=null && prodName.startsWith('EC'))
                {
                    ECAccountKeyList.add(acInfo);
                }
            }
        }
        if(ECAccountKeyList!=null && ECAccountKeyList.size()==0)
        {
            User usrInfo = [Select Id,ContactId from User where Id=:UserInfo.getUserId()];
            if(usrInfo!=null)
            { 
                if(usrInfo.ContactId!=null)
                {
                    Contact con= [Select Account.Name from Contact where Id=:usrInfo.ContactId];
                    if(con!=null)
                    {  
                        ECAccountKeyList.add(new AccountInfo(con.Account.Name,'',''));
                    }
                }
            }
            
        }*/
    }
    
    public Integer PageNumber { get; private set; }
    public Integer PageCount { get; private set; }
    public String SearchAsset { get; set; }
    public String SortFunction { get; set; }
    public String FieldName { get; set; } 
    public String ListView { get; set; }
    public Boolean ServiceProvider { get;  set; }
    public List<AssetInfo> AssetsInCurrentPage { get; set; }
    
    public Boolean HasNext
    {
        get
        {
            return  PageNumber < PageCount - 1;
        }
    }
    
    public void initSort()
    {
        FieldName = 'Product2.Name';
        SortFunction = 'sortAsc';
        sortField = SortFunction + FieldName;
    }
    
    public PageReference saveAsset()
    {
        try
        {
            List<Asset> updateAssets = new List<Asset>();
            InternalAssetUpdator updator = new InternalAssetUpdator();
            for(AssetInfo asset : AssetsInCurrentPage)
            {
                if(asset.AssetRecord != null)
                {
                    updator.addAsset(asset.AssetRecord.Id, asset.CustomerNotes);
                }
            }
            updator.save();
            searchAssets();
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference previous()
    {
        PageNumber = Math.max(PageNumber - 1, 0);
        loadAssets();
        return null;
    }
    
    
    public PageReference next()
    {
        PageNumber++;
        loadAssets();
        return null;
    }
    
    public PageReference searchAssets()
    {
        loadAssets();
        PageNumber = 0;
        return null;
    }
    
    public PageReference sortTable()
    {
        FieldName = Apexpages.currentPage().getParameters().get('fieldName');
        SortFunction = (sortField == 'sortAsc' + FieldName) ? 'sortDesc' : 'sortAsc';
        sortField = SortFunction + FieldName;
        searchAssets();
        return null;
    }
    
    public PageReference sendListToCurrentUser()
    {
        try
        {
            sendAssetsToCurrentUser(getAssetsCSV());
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        ListView = 'LicenseKeys';
        return null;
    }
    
    
    private void loadAssets()
    {
        AssetsInCurrentPage = new List<AssetInfo>();
        try
        {
            List<Asset> allAssets = doQuery();
            PageCount = Math.ceil(allAssets.size() * 1.0 / PAGE_SIZE).intValue();
            for(Integer i = PageNumber * PAGE_SIZE.intValue(); i < allAssets.size() && i < (PageNumber+1) * PAGE_SIZE; i++)
            {
                AssetsInCurrentPage.add(new AssetInfo(allAssets[i]));
            }
        } 
        catch(Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to query asset. ' + ex.getMessage()));
        }
    }
    
    private List<Asset> doQuery()
    {
        if(String.isNotBlank(SearchAsset) && SearchAsset.length() >= 2)
        {
            String query = buildSearch();
            List<Asset> allRecords = Database.query(query);
            return allRecords;
        }
        else
        {
            String query = buildQuery();
            List<Asset> allRecords = Database.query(query);
            return allRecords;
        }
    }
    
    private String buildQuery()
    {
        String query = '';
        
        query = 'select ';
        List<String> fields = getFieldList('', ServiceProvider);
        query += String.join(fields, ',');
        query.removeEnd(',');
        query += ' from Asset';
        query += ' where Product2.Name like \'EC%\' and SBQQ__QuoteLine__c = null ';
        
        String sortFirstField = FieldName.split(';')[0];
        String sortAnotherField  = FieldName.split(';').size() > 1 ? FieldName.split(';')[1] : '';
        query += ' order by ' + sortFirstField;
        query += SortFunction == 'sortAsc' ? ' asc nulls first' : ' desc nulls last';
        if(String.isNotEmpty(sortAnotherField))
        {
            query += ', ' + sortAnotherField;
            query += SortFunction == 'sortAsc' ? ' asc nulls first' : ' desc nulls last';
        }
        query += ' limit 10000';
        System.debug(query);
        return query;
    }
    
    private String buildSearch()
    {
        String escapedKeyword = String.escapeSingleQuotes(SearchAsset == null ? '' : SearchAsset);
        String maskKeyword = '%' + escapedKeyword.replaceAll('\\*', '_') + '%';
        
        String query = '';
        
        query = 'select ';
        List<String> fields = getFieldList('', ServiceProvider);
        query += String.join(fields, ',');
        query.removeEnd(',');
        query += ' from Asset';
        query += ' where Product2.Name like \'EC%\' and (SerialNumber=\'' + escapedKeyword + '\' or Model__c like \'' + maskKeyword + '\' or Product2.Name like \'' + maskKeyword + '\' or Customer_Notes__c like \'' + maskKeyword + '\')';
        
        String sortFirstField = FieldName.split(';')[0];
        String sortAnotherField  = FieldName.split(';').size() > 1 ? FieldName.split(';')[1] : '';
        query += ' order by ' + sortFirstField;
        query += SortFunction == 'sortAsc' ? ' asc nulls first' : ' desc nulls last';
        if(String.isNotEmpty(sortAnotherField))
        {
            query += ', ' + sortAnotherField;
            query += SortFunction == 'sortAsc' ? ' asc nulls first' : ' desc nulls last';
        }
        query += ' limit 10000';
        System.debug(query);
        return query;
    }
    
    private PageReference sendAssetsToCurrentUser(String assetCSV)
    {
        User currentUser = [select Email from User where Id = :UserInfo.getUserId()];
        String targetEmail = currentUser.Email;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Silver Peak Customer Portal:Your Asset List');
        mail.setPlainTextBody('Use attached spreadsheet to view and update the customer notes. Reply with the updated spreadsheet to batch update.\r\n\r\n');
        mail.setToAddresses(new String[] {targetEmail});
        
        OrgWideEmailAddress orgId=[select id, Address,DisplayName from OrgWideEmailAddress where DisplayName='Silver Peak Notifications' LIMIT 1];
        mail.setOrgWideEmailAddressId(orgId.Id);
        mail.setReplyTo(getEmailServiceAddress());
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('Assets.csv');
        efa.setBody(Blob.valueOf(assetCSV));
        efa.setContentType('application/csv');
        mail.setFileAttachments(new List<Messaging.Emailfileattachment>{efa});
        try
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'An email has been sent to your email address [' + targetEmail + ']'));
            return new PageReference('/apex/AssetListView');
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    private String getEmailServiceAddress()
    {
        String address = '';
        if(SilverPeakUtils.IsProduction())
        {
            address='spdataloader@5feojp8e8w1xl9fm32xtndfpp.3-byveaq.na3.apex.salesforce.com';
        }
        else
        {
            List<EmailServicesAddress> emailServices = [select LocalPart, EmailDomainName from EmailServicesAddress where IsActive=true and Function.FunctionName = 'Asset List Editor'];
            if(emailServices.size() > 0)
            {
                address = emailServices[0].LocalPart + '@' + emailServices[0].EmailDomainName;
            }
        }
        return address;
    }
    
    private String getAssetsCSV()
    {
        String csvBody = '';
        String csvHeader = 'Id,Product Name,Serial Number,';
        csvHeader += 'License Date,';
        csvHeader += 'Ship Date,';
        csvHeader += 'Warranty End Date,';
        csvHeader += 'Customer Notes\r';
        
        transient List<Asset> allAssetsToExport = doQuery();
        if(allAssetsToExport.size() > 0)
        {
            for(Asset item : allAssetsToExport)
            {
                csvBody += escapeCsvCell(item.Id) + ',';
                csvBody += escapeCsvCell(item.Product2.Name) + ',';
                csvBody += escapeCsvCell(item.SerialNumber) + ',';
                csvBody += escapeCsvCell(item.License_End_Date__c) + ',';
                csvBody += escapeCsvCell(item.Ship_Date__c) + ',';
                csvBody += escapeCsvCell(item.Warranty_End_Date__c) + ',';
                csvBody += escapeCsvCell(item.Customer_Notes__c);
                csvBody += '\r';
            }
        }
        return csvHeader + csvBody;
    }
    
    private List<String> getFieldList(String listView, Boolean isServiceProvider)
    {
        List<String> result = new List<String> {'Id', 'SerialNumber', 'Product2.Name', 'Product2.Model__c', 'License_End_Date__c', 'Customer_Notes__c','Status','Warranty_End_Date__c','Ship_Date__c','Bandwidth_Nodes__c','Licenses_Nodes__c','Account.Name','Renewal_Text__c'};
            return result;
    }
    
    private String escapeCsvCell(String value)
    {
        if(String.isBlank(value))
        {
            return '""';
        }
        else if(value.contains(',') ||value.contains('"'))
        {
            value = value.replaceAll('"', '""');
            return '"' + value + '"';
        }
        else
        {
            return value;
        }
    }
    private String escapeCsvCell(Date dateValue)
    {
        if(dateValue == null)
        {
            return '""';
        }
        else
        {
            return Datetime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0)).format('M/dd/yyyy');
        }
    }
    
    private Date parseDate(String dateValue)
    {
        if(String.isNotBlank(dateValue))
        {
            try
            {
                if(dateValue.indexOf('-') > 0)
                {
                    String[] parts = dateValue.split('-');
                    return Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
                }
                else if(dateValue.indexOf('/') > 0)
                {
                    String[] parts = dateValue.split('/');
                    return Date.newInstance(Integer.valueOf(parts[2]), Integer.valueOf(parts[0]), Integer.valueOf(parts[1]));
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Incorrect date format [MM/dd/yyyy]'));
            }
        }
        return null;
    }
    
    class AssetInfo
    {
        private String originalAsset;
        public Asset AssetRecord { get; set; }
        public String ProductName { get; private set; }
        public String CustomerNotes { get; set; }
        
        public AssetInfo(Asset asset)
        {
            this.AssetRecord = asset;
            this.ProductName = asset.Product2.Name;
            this.CustomerNotes = asset.Customer_Notes__c;
            
        }
    }
    
    public without sharing class InternalAssetUpdator
    {
        private List<Asset> assets = new List<Asset>();
        
        public void addAsset(Id assetId, String customerNotes)
        {
            assets.add(new Asset(Id=assetId, Customer_Notes__c=customerNotes));
        }
        
        public void addAsset(Id assetId, String customerNotes, Date deploymentDate, String endCustomer, String reference)
        {
            assets.add(new Asset(Id=assetId, Customer_Notes__c=customerNotes, Deployment_Date__c = deploymentDate, End_Customer__c = endCustomer, Reference__c = reference));
        }
        
        public void save()
        {
            if(assets.size() > 0)
            {
                update assets;
            }
        }
    }
}