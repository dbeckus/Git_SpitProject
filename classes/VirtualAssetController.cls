/*
 * Controller of page NewVirtualAsset and RenewLicense
 */
public class VirtualAssetController
{
    private ApexPages.StandardController controller;
    private Asset_mac__c am;
    private Asset assetRecord;
    private Map<String, String> params;
    
    public VirtualAssetController(ApexPages.StandardController controller) 
    {
        step = 1;
        saveAndNew = false;
        this.controller = controller;
        AssetRecord = (Asset)controller.getRecord();
        AssetRecord.Quantity = 1;
        params = ApexPages.currentPage().getParameters();
        
        if(params.containsKey('accountId'))
        {
            AssetRecord.AccountId = params.get('accountId');
        }
        if(params.containsKey('requestId'))
        {
            AssetRecord.POCRequest__c = params.get('requestId');
            List<Request__c> requests = [select Id, Opportunity__c, Opportunity__r.AccountId, POC_Contact__c from Request__c where Id=:AssetRecord.POCRequest__c limit 1];
            if(requests.size() > 0)
            {
                AssetRecord.ContactId = requests[0].POC_Contact__c;
                if(requests[0].Opportunity__c != null)
                {
                    AssetRecord.AccountId = requests[0].Opportunity__r.AccountId;
                }
            }
        }
        if(params.containsKey('contactId'))
        {
            AssetRecord.ContactId = params.get('contactId');
        }
        license = new License__c(Start_Date__c=Date.today(), Quantity__c=1);
    }
    
    public String LicenseDuration { get; set; }
    public License__c license {get; set;}
    public Integer step { get; set; }
    public Boolean saveAndNew { get; set; }
    
    public List<SelectOption> getProducts() 
    {
        List<SelectOption> options = new List<SelectOption>();
        for (Product2 prod : [SELECT Id, Name, Model__c FROM Product2 WHERE Family='Virtual Image']) 
        {
            options.add(new SelectOption(prod.Id, prod.Name));
        }
        return options;
    }
    
    public String getProductModel()
    {
        List<Product2> prods = [SELECT Id, Name, Model__c FROM Product2 WHERE Id=:assetRecord.Product2Id limit 1];
        if(prods.size() > 0)
        {
            String model = (prods[0].Model__c != null && prods[0].Model__c != '') ? prods[0].Model__c : prods[0].Name;
            return model.replaceAll('-', '');
        }
        else
        {
            return '';
        }
    }
    
    //gets the License_ENd_Date field on asset, used in the RenewalLicense popup page.
    public String ExistingEndDate
    {
        get
        {
            if(AssetRecord.License_End_Date__c == null)
            {
                return Date.today().format();
            }
            else
            {
                return AssetRecord.License_End_Date__c.format();
            }
        }
    }
    
    public String ExistingProductName
    {
        get
        {
            if(AssetRecord.Product2 != null)
            {
                return (AssetRecord.Product2.Model__c != null &&AssetRecord.Product2.Model__c != '') ? AssetRecord.Product2.Model__c : AssetRecord.Product2.Name;
            }
            return '';
        }
    }
    
    public PageReference nameRankSerial() 
    {
        // See if we've already generated a key, which we would have in error case
        if (license.Key__c != null && license.Key__c.trim() != '') 
        {
            system.debug('License Key already exists, and is '+license.Key__c);
        } 
        else 
        {
            am = getAMac();
            am.Used__c = true;
            try 
            {
                upsert am;
            }
            catch(DmlException ex) 
            {
                system.debug('license upsert failed');
                ApexPages.addMessages(ex);
                return null; // don't switch to step 2 if upsert failed
            }
            am = getAMac(am.Id);
            String mac = am.Name;
            AssetRecord.Name = '001BBC' + toHex(Integer.valueof(mac));
        }
        
        // Either we had a license key, or we created one. Goto step 2
        AssetRecord.SerialNumber = AssetRecord.Name;
        step = 2;
        return null;
    }
    
    public PageReference save() 
    {
        Savepoint sp = Database.setSavepoint();
        
        AssetRecord = (Asset)controller.getRecord();
        AssetRecord.Ship_Date__c = license.Start_Date__c;
        Integer durationDays = getNumberOfDays(license.Start_Date__c, LicenseDuration);
        if(durationDays > 0)
        {
            license.License_Expiration__c = license.Start_Date__c.addDays(durationDays);
        }
        else
        {
            //perpetual
       //     license.License_Expiration__c = Date.newInstance(2029,12,31);
            license.License_Expiration__c = null; // Date.newInstance(2029,12,31);			
        }
        AssetRecord.Evaluation_Start_Date__c = license.Start_Date__c;
        if(durationDays > 0)
        {
            AssetRecord.Evaluation_End_Date__c = license.License_Expiration__c;
        }
        try 
        {
            String assetId = AssetRecord.Id;
            
            if(assetId == '000000000000000')
            {
                //cloning here is to fix a bug in summer'11: the id is default to '000000000000000'
                AssetRecord = AssetRecord.clone(false);
            }
            upsert AssetRecord;
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
            step = 1; // Go back to step 1
            return null;
        }
        
        // update license
        license.AssetId__c = AssetRecord.Id;
        system.debug('license='+license);
        try 
        {
            upsert license;
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
            step = 1; // Go back to step 1
            Database.rollback(sp);
            return null;
        }
        
        // Put id into Asset_mac__c
        am.AssetId__c = AssetRecord.Id;
        try 
        {
            update am;
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
            Database.rollback(sp);
        }
                
        // Go to new page
        PageReference returl;
        // If save & New, do it again.
        if (saveAndNew) 
        {
            returl = Page.NewVirtualAsset;
            for(String paramKey : params.keySet())
            {
                String paramValue = params.get(paramKey);
                returl.getParameters().put(paramKey, paramValue);
            }
            returl.getParameters().put('contactId', AssetRecord.ContactId); //contact id also needs to be reserved
        } 
        else 
        {
            String saveUrl = ApexPages.currentPage().getParameters().get('saveUrl');
            if(saveUrl != '' && saveUrl != null)
            {
                returl = new PageReference(saveUrl);
            }
            else
            {
                returl = new ApexPages.StandardController(AssetRecord).view();
            }
        }
        step = 1;
        returl.setRedirect(true);
        return returl;
    }
    
    public PageReference renewLicense()
    {
        Date assetExpireDate = (AssetRecord.License_End_Date__c == null) ? Date.today() : AssetRecord.License_End_Date__c;
        license.Start_date__c = Date.today();
        license.AssetId__c = assetRecord.Id;
        license.Contact_for_Notification__c = assetRecord.ContactId;
        license.RenewalKeyGenerated__c = true;
        Integer durationDays = getNumberOfDays(assetExpireDate, LicenseDuration);
        if(durationDays > 0)
        {
            license.License_Expiration__c = assetExpireDate.addDays(durationDays);
        }
        else
        {
            //perpetual
         //   license.License_Expiration__c = Date.newInstance(2029,12,31);
            license.License_Expiration__c = null; //Date.newInstance(2029,12,31);			
        }
        try 
        {
            upsert license;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'License Renewed. <script>setTimeout("top.close()", 3000)</script>'));
        }
        catch(DmlException ex) 
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    private String toHex(Integer x) 
    {
        system.debug('toHex: '+x);
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
    
    private Integer getNumberOfDays(Date startDate, String duration)
    {
        if(duration.contains('d'))
        {
            return Integer.valueOf(duration.substring(0, duration.length() - 1));
        }
        else if(duration.contains('y'))
        {
            Integer years = Integer.valueOf(duration.substring(0, duration.length() - 1));
            Date endDate = startDate.addYears(years);
            return startDate.daysBetween(endDate);
        }
        return 0;
    }
      
    private Asset_Mac__c getAMac()
    {
        List<Asset_mac__c> mac = [select Id, Name, Used__c, AssetId__c from Asset_mac__c WHERE Used__c=false LIMIT 1 FOR UPDATE];
        if(mac.size() > 0)
        {
            return mac [0];
        }
        else
        {
            return new Asset_Mac__c();
        }
    }
    
    private Asset_Mac__c getAMac(Id macId)
    {
        Asset_Mac__c mac = [select Id, Name, Used__c, AssetId__c from Asset_Mac__c where Id=:macId limit 1];
        return mac;
    }
    
    @isTest
    static void testVirtualAssetController()
    {
        Account account = new Account(Name='acme');
        insert account;
        Contact contact = new Contact(LastName='acme', AccountId=account.Id);
        insert contact;
        PageReference page = new PageReference('/apex/NewVirtualAsset?accountId=' + account.Id);
        Test.setCurrentPage(page);
        
        Asset asset = new Asset();
        ApexPages.StandardController stController = new ApexPages.StandardController(asset);
        VirtualAssetController controller = new VirtualAssetController(stController);
        String endDate = controller.ExistingEndDate;
        String prdName = controller.ExistingProductName;
        
        System.assert(controller.getProducts().size() > 0);
        asset.Product2Id = controller.getProducts()[0].getValue();
        String productModel = controller.getProductModel();
        asset.Status = 'Customer Subscription';
        asset.ContactId = contact.Id;
        controller.LicenseDuration = '30d';
        controller.license.Start_Date__c = Date.today();
        controller.nameRankSerial();
        
        controller.license.Key__c = 'test';
        controller.save();
        
        controller.License = new License__c();
        controller.LicenseDuration = '1y';
        controller.License.Key__c = 'test';
        controller.renewLicense();
    }
}