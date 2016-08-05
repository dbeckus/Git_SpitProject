/*
* Controller of NewVirtualAsset page
*/
public class NewVirtualAssetController
{
    private Map<String, String> params;
    
    public NewVirtualAssetController(ApexPages.StandardController controller) 
    {
        Asset = new Asset();
        Asset.Evaluation_Start_Date__c = Date.today();
        
        params = ApexPages.currentPage().getParameters();
        if(params.containsKey('accountId'))
        {
            Asset.AccountId = params.get('accountId');
        }
        if(params.containsKey('requestId'))
        {
            String requestId = params.get('requestId');
            List<Request__c> requests = [select Id, Opportunity__c, Opportunity__r.AccountId, POC_Contact__c from Request__c where Id = :requestId limit 1];
            if(requests.size() > 0)
            {
                Asset.POCRequest__c = requests[0].Id;
                Asset.ContactId = requests[0].POC_Contact__c;
                if(requests[0].Opportunity__c != null)
                {
                    Asset.AccountId = requests[0].Opportunity__r.AccountId;
                }
            }
        }
        if(params.containsKey('contactId'))
        {
            Asset.ContactId = params.get('contactId');
        }
        
        SaveAndNew = false;
    }
    
    public Asset Asset { get; set; }
    public Boolean SaveAndNew { get; set; }
    
    public List<SelectOption> Products
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            for (Product2 product : [select Id, Name from Product2 where Family = 'Virtual Image' order by Name]) 
            {
                options.add(new SelectOption(product.Id, product.Name));
            }
            return options;
        }
    }
    
    public PageReference save()
    {
        Product2 selectedProduct = [select Id, Name, LicenseAsModel__c, NumberOfLicenses__c from Product2 where Id=:Asset.Product2Id limit 1];
        Integer licenseCount = (selectedProduct.NumberOfLicenses__c == null) ? 1 : selectedProduct.NumberOfLicenses__c.intValue();
        List<Id> licenses = new List<Id>();
        Savepoint sp = Database.setSavepoint();
        Boolean saveSucceeded = true;
        for(Integer i = 0; i < licenseCount; i++)
        {
            License__c resultLicense = saveAsset();
            if(resultLicense == null)
            {
                Database.rollback(sp);
                saveSucceeded = false;
                break;
            }
            licenses.add(resultLicense.Id);
        }
        
        if(saveSucceeded)
        {
            VirtualAssetManager.encryptLicenses(licenses);
            PageReference retURL;
            String saveURL = ApexPages.currentPage().getParameters().get('saveUrl');
            if(saveURL != '' && saveURL != null)
            {
                retURL = new PageReference(saveURL);
            }
            else
            {
                retURL = new ApexPages.StandardController(Asset).view();
            }
            retURL.setRedirect(true);
            return retURL;
        }
        else
        {
            return null;
        }
    }
    
    public PageReference saveAndNew()
    {
        PageReference saveResult = save();
        if(saveResult != null)
        {
            PageReference retURL = Page.NewVirtualAsset;
            for(String paramKey : params.keySet())
            {
                String paramValue = params.get(paramKey);
                retURL.getParameters().put(paramKey, paramValue);
            }
            retURL.getParameters().put('contactId', Asset.ContactId); //contact id also needs to be reserved
            retURL.setRedirect(true);
            return retURL;
        }
        else
        {
            return null;
        }
    }
    
    private License__c saveAsset()
    {
        Asset_mac__c assetMac = getAMac();
        assetMac.Used__c = true;
        try 
        {
            upsert assetMac;
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
            return null;
        }
        String mac = [select Id, Name, Used__c, AssetId__c from Asset_Mac__c where Id = :assetMac.Id limit 1].Name;
        
        Asset.Name = '001BBC' + toHex(Integer.valueof(mac));
        Asset.SerialNumber = Asset.Name;
        Asset.Quantity = 1;
        List<Product2> lstECorchProd=[Select Id,Name from Product2 where Id=:Asset.Product2Id and Name='EC-ORCH'];
        if(lstECorchProd!=null && lstECorchProd.size()>0)
        {
            Asset.GMS_Nodes__c = '100000';
        }
        Asset.Ship_Date__c = Date.today();
        
        System.debug('Asset'+Asset);
        try
        {
            upsert Asset;
        }
        catch(DmlException ex)
        {
            Apexpages.addMessages(ex);
            return null;
        }
        
        assetMac.AssetId__c = Asset.Id;
        try
        {
            update assetMac;
        }
        catch(DmlException ex)
        {
            Apexpages.addMessages(ex);
            return null;
        }
        
        License__c license = new License__c();
        if(lstECorchProd!=null && lstECorchProd.size()>0)
        {
            license.Quantity__c = 100000;
        }
        else
        {
            license.Quantity__c = 1;
        }
        
        license.AssetId__c = Asset.Id;
        license.Contact_for_Notification__c = Asset.ContactId;
        license.Start_Date__c = Asset.Evaluation_Start_Date__c;
        license.License_Expiration__c = Asset.Evaluation_End_Date__c;
        license.Model__c = [select LicenseAsModel__c from Product2 where Id=:Asset.Product2Id limit 1].LicenseAsModel__c;
        license.SerialNumber__c = Asset.Name;
        try
        {
            insert license;
            return license;
        }
        catch(DmlException ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    private static String toHex(Integer x) 
    {
        String s = '';
        String hex = '0123456789ABCDEF';
        for(Integer i = 0; i <= 5; i++) 
        {
            Integer m = Math.mod(x,16);
            s = hex.substring(m, m + 1) + s;
            x /= 16;
        }
        return s;
    }
    
    private static Asset_Mac__c getAMac()
    {
        List<Asset_mac__c> macs = [select Id, Name, Used__c, AssetId__c from Asset_mac__c where Used__c = false limit 1 for update];
        if(macs.size() > 0)
        {
            return macs[0];
        }
        else
        {
            return new Asset_Mac__c();
        }
    }
}