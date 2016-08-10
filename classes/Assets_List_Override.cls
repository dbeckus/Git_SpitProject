public class Assets_List_Override
{
    /*private ApexPages.StandardSetController controller;
    public Integer step { get; set; }
    public String licenseEndDate { get; set; }
    public Boolean saveAndNew { get; set; }
    private asset_mac__c am;
    public License__c license {get; set;}
    private String prefix = 'page:form:pageBlock:assetInformation:';
    private Asset record;
    
    public Assets_List_Override(ApexPages.StandardSetController controller) 
    {
        system.debug('Assets_List_Override');
        step = 1;
        this.controller = controller;
        record = (Asset)controller.getRecord();
        record.Quantity=1;
        System.debug('asset=' + record);
        Map<String,String> params = ApexPages.currentPage().getParameters();

        // Fill in any known fields
        fillIn(params, record, 'account_lkid', 'AccountId');
        fillIn(params, record, 'contactId_lkid', 'ContactId');
        fillIn(params, record, 'products:product', 'Product2Id');
        fillIn(params, record, 'statuses:status', 'Status');
        
        if (params.containsKey('id') && params.get('id') != '') 
        {
            if (params.get('id').startsWith('001')) 
            {
                record.AccountId=params.get('id');
            } 
            else if (params.get('id').startsWith('01t')) 
            {
                record.Product2Id=params.get('id');
            } 
            else if (params.get('id').startsWith('02i')) 
            {
                system.debug('id was an asset');
            }
        }
        
        license = new License__c();
        license.Start_Date__c=Date.today();
        if (params.containsKey(prefix+'statuses:status') && params.get(prefix+'statuses:status') == 'Customer Owned') 
        {
            license.Duration__c=0;
        } else 
        {
            license.Duration__c=90;  
        }
        license.Quantity__c=1;
        // The license end date is only for when the license is not perpetual (duration!=0)
        licenseEndDate=license.Start_Date__c.addDays(90).format();   
        record.Ship_Date__c = license.Start_Date__c;
        record.Evaluation_Start_Date__c = license.Start_Date__c;
        record.Evaluation_End_Date__c = license.Start_Date__c.addDays(90);
    }
    
    private void fillIn(Map<String,String> params, Asset a, String pname, String dbname) 
    {
        if (params.containsKey(prefix + pname) && params.get(prefix + pname) != '') 
        {
            a.put(dbname, params.get(prefix+pname));
        }
    } // fillIn

    public List<SelectOption> getProducts() 
    {
        system.debug('getProducts');
        List<SelectOption> options = new List<SelectOption>();
        for (List<Product2> plist : [SELECT id,name FROM Product2 
                WHERE family='Virtual Image']) {
            for (Product2 p : plist) {
                options.add(new SelectOption(p.id,p.Name));
            }
        }
        return options;
    }
    
    public PageReference nameRankSerial() {
        system.debug('nameRankSerial');
        // See if we've already generated a key, which we would have in error case
        if (license.Key__c != null && license.Key__c.trim() != '') 
        {
            system.debug('License Key already exists, and is '+license.Key__c);
        } else {
            List<Asset_mac__c> aml = [SELECT id,name,Used__c,AssetId__c from Asset_mac__c WHERE Used__c=false LIMIT 1 FOR UPDATE];
            if (aml.isEmpty()) {
                system.debug('No unused license found. Creating a new one');
                am = new Asset_mac__c();
            } else {
                am=aml.get(0);
                system.debug('found unused license '+am.name);
            }
            am.Used__c=true;
            try {
                upsert am;
            }
            catch(DmlException ex) {
                system.debug('license upsert failed');
                ApexPages.addMessages(ex);
                return null; // don't switch to step 2 if upsert failed
            }
            SObject s = Database.query('SELECT Name from Asset_mac__c WHERE id=\''+am.id+'\'');
            String mac=(String)s.get('Name');
            system.debug('mac='+mac);
            record.Name='001BBC'+toHex(Integer.valueof(mac));
            system.debug('mac assigned: '+record.Name);
        } // key didn't exist
        
        // Either we had a license key, or we created one. Goto step 2
        record.SerialNumber=record.Name;
        step = 2;
        return null;
    }

    public PageReference save() 
    {
        record = (Asset)controller.getRecord();
        try 
        {
            String assetId = record.Id;
            
            if(assetId == '000000000000000')
            {
                //cloning here is to fix a bug in summer'11: the id is default to '000000000000000'
                record = record.clone(false);
            }
            upsert record;
        }
        catch(DmlException ex) 
        {
            system.debug('Asset upsert failed');
            ApexPages.addMessages(ex);
            step = 1; // Go back to step 1
            return null;
        }
        // It worked
        
        // update license
        license.AssetId__c = record.id;
        system.debug('license='+license);
        try 
        {
            insert license;
        }
        catch(DmlException ex) 
        {
            system.debug('license insert failed');
            ApexPages.addMessages(ex);
            step = 1; // Go back to step 1
            return null;
        }
        
        // Put id into Asset_mac__c
        am.AssetId__c = record.id;
        try 
        {
            update am;
        }
        catch(DmlException ex) 
        {
            system.debug('asset_mac__c update failed');
        }
                
        // Go to new page
        PageReference returl;
        // If save & New, do it again.
        if (saveAndNew) 
        {
            system.debug('saveAndNew');
            returl = ApexPages.currentPage();
        } else 
        {
            system.debug('using StandardController.view: '+returl);
            returl = new ApexPages.StandardController(record).view();

        }
        step = 1;
        returl.setRedirect(true);
        return returl;
    }
    
    private String toHex(Integer x) 
    {
        system.debug('toHex: '+x);
        String s='';
        String hex='0123456789ABCDEF';
        for(Integer i=0;i<=5;i++) 
        {
            Integer m = Math.mod(x,16);
            s=hex.substring(m,m+1)+s;
            x/=16;
        }
        system.debug('toHex returns '+s);
        return s;
    }*/ 
}