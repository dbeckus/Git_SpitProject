/*
* A helper class for virtual asset
* Includes methods to generate license keys
*/
public class VirtualAssetManager
{
    public VirtualAssetManager()
    {
        VirtualAssets = new List<VirtualAsset>();
        isFromApex = false;
    }
    
    public List<VirtualAsset> VirtualAssets { get; set; }
    public Boolean isFromApex { get; set; }
    
    public Boolean nameRankSerial()
    {
        
        Boolean succeeded = false;
        assignProductModel();
        Integer assetMacsCount = 0;
        for(VirtualAsset va : VirtualAssets)
        {
           
            assetMacsCount += va.NumberOfLicenses;
        }
        if(assetMacsCount > 0)
        {
            //Gets unused asset macs from database for the virtual assets without license key.
            List<Asset_Mac__c> assetMacs =  [select Id, Name, Used__c, AssetId__c from Asset_Mac__c where Used__c = false limit :assetMacsCount for update];
            for(Asset_Mac__c assetMac : assetMacs)
            {
                assetMac.Used__c = true;
            }
            //If the unused asset macs from database are not enough, creates new ones.
            if(assetMacs.size() < assetMacsCount)
            {
                for(Integer i = assetMacs.size(); i < assetMacsCount; i++)
                {
                    assetMacs.add(new Asset_Mac__c(Used__c = true));
                }
            }
            try
            {
                upsert assetMacs;
                Set<Id> assetMacIds = new Set<Id>();
                for(Asset_Mac__c assetMac : assetMacs)
                {
                    assetMacIds.add(assetMac.Id);
                }
                assetMacs = [select Id, Name, Used__c, AssetId__c from Asset_Mac__c where Id in :assetMacIds];
                Integer i = 0;
                for(VirtualAsset va : VirtualAssets)
                {
                   
                    for(Integer j = 0; j < va.NumberOfLicenses; j++)
                    {
                        Asset_Mac__c mac = assetMacs[i++];
                        String sn = '001BBC' + toHex(Integer.valueOf(mac.Name));
                        va.Licenses.add(new VirtualAssetLicense(new License__c(SerialNumber__c=sn, Model__c=va.ProductModel), mac));
                      
                        if(j == 0)
                        {
                            va.Asset.Name = sn;
                           
                        }
                    }
                }
                succeeded = true;
            }
            catch(DmlException ex)
            {
                succeeded = false;
                if(!isFromApex)
                {
                    ApexPages.addMessages(ex);
                }
                else
                {
                    throw ex;
                }
            }
        }
        return succeeded;
    }
    public Boolean updateECAssets()
    {
        Boolean succeeded = false;
        Savepoint sp = Database.setSavePoint();
        List<Asset> assets = new List<Asset>();
        
        Map<Id,date>mapAssetEvalDate= new Map<Id,date>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            assets.add(virtualAsset.Asset);
            mapAssetEvalDate.put(virtualAsset.Asset.Id,virtualAsset.Asset.Evaluation_End_Date__c);
        }
        List<Asset> lstAsset=  [Select Id, (Select Id,Name,License_Expiration__c from licenses__r ) from Asset where Id in :mapAssetEvalDate.keySet()];
        List<License__c> lstLicenses= new List<License__c>();
        for(Asset item: lstAsset)
        {
            
            List<License__c> licenseItem = item.Licenses__r;
            
            if(licenseItem!=null && licenseItem.size()>0)
            {
                
                License__c license=licenseItem[0];
                license.License_Expiration__c= mapAssetEvalDate.containsKey(item.Id)?mapAssetEvalDate.get(item.Id):license.License_Expiration__c;
                lstLicenses.add(license);                
                
            }
        }
        try
        {
            update assets;
            succeeded=true;
            // Retreive License information for the asset
            if(lstLicenses.size()>0)
            {
                System.debug(lstLicenses.size()+ 'number of records License');
                update lstLicenses;
            }
            succeeded=true;
            
        }
        catch(DmlException ex)
        {
            System.debug(ex);
            if(!isFromApex)
            {
                
                ApexPages.addMessages(ex);
            }
            Database.rollback(sp);
            SilverPeakutils.logException(ex);
        }
        return succeeded;
    }
    
    
    public Boolean updatesAssets()
    {
        Boolean succeeded = false;
        Savepoint sp = Database.setSavePoint();
        
        List<Asset> assets = new List<Asset>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            virtualAsset.Asset.SerialNumber = virtualAsset.Asset.Name;
            virtualAsset.Asset.Ship_Date__c = virtualAsset.Asset.Evaluation_Start_Date__c;
            virtualAsset.Asset.Quantity = 1;
            
            
            if (virtualAsset.Asset.GMS_Nodes__c == '1') {
                virtualAsset.Asset.GMS_Nodes__c = '10'; 
            }
            
            // the statement above is cleared for non-GMS assets by using a Workflow rule "ClearGMSNodes"
            assets.add(virtualAsset.Asset);
        }
        
        try
        {
            upsert assets;
        }
        catch(DmlException ex)
        {
            if(!isFromApex)
            {
                ApexPages.addMessages(ex);
            }
            Database.rollback(sp);
            SilverPeakutils.logException(ex);
        }
        Set<Id> gmsAssets = new Set<Id>();
        for(Asset gmsAsset : [select Id from Asset where Id in :assets and (Product2.Model__c='GX-V' Or Product2.Product_Category__c = 'GMS')])
        {
            gmsAssets.add(gmsAsset.Id);
        }
        List<Asset_Mac__c> assetMacs = new List<Asset_Mac__c>();
        List<License__c> licenses = new List<License__c>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            for(VirtualAssetLicense license : virtualAsset.Licenses)
            {
                license.AssetMac.AssetId__c = virtualAsset.Asset.Id;
                license.License.AssetId__c = virtualAsset.Asset.Id;
                license.License.Start_Date__c = virtualAsset.Asset.Evaluation_Start_Date__c;
                license.License.License_Expiration__c = virtualAsset.Asset.Evaluation_End_Date__c;
                try
                {
                    license.License.Quantity__c = gmsAssets.contains(license.License.AssetId__c) ? Integer.valueOf(virtualAsset.Asset.GMS_Nodes__c) : 1;
                }
                catch(Exception ex)
                {
                    license.License.Quantity__c = 1;
                }
                assetMacs.add(license.AssetMac);
                licenses.add(license.License);
            }
        }
        try
        {
            upsert assetMacs;
            upsert licenses;
            succeeded = true;
        }
        catch(DmlException ex)
        {
            if(!isFromApex)
            {
                ApexPages.addMessages(ex);
            }
            Database.rollback(sp);
            SilverPeakutils.logException(ex);
        }
        return succeeded;
    }
    
    public void willEncryptLicenses()
    {
        List<Id> licenseIds = new List<Id>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            string prodModel= virtualAsset.ProductModel;
         
            if(prodModel!=null && !prodModel.startsWith('UNITY CLOUD') && !prodModel.startsWith('ECBASE') && !prodModel.startsWith('ECPLUS') && !prodModel.startsWith('ECBOOST')&& !prodModel.startsWith('ECSAAS') && !prodModel.startsWith('ECSP'))
            {
                for(VirtualAssetLicense license : virtualAsset.Licenses)
                {
                    licenseIds.add(license.License.Id);
                }
            }
        }
        encryptLicenses(licenseIds);
    }
    
    public void AssignContractToPOCAssets(Id contractId)
    {
        List<Asset> lstAsset= new List<Asset>();
        Id orchId=null;
        List<Product2> lstProd= [Select Id from Product2 where Name='EC-ORCH'];
        if(lstProd!=null && lstProd.size()>0)
        {
            orchId=lstProd[0].id;
        }
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            if(orchId!=null && virtualAsset.Asset.Product2Id!=orchId)
            {
                 lstAsset.add(new Asset(Id=virtualAsset.Asset.Id,Contract_Number__c=contractId));
            }
           
        }
        if(lstAsset.size()>0)
        {
            update lstAsset;
        }
    }
    
    public  List<Id> RetreiveLicenseIdsForAutomation()
    {
        List<Id> licenseIds = new List<Id>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            for(VirtualAssetLicense license : virtualAsset.Licenses)
            {
                licenseIds.add(license.License.Id);
            }
        }
        return licenseIds;
    }
    public static void encryptLicense(Id licenseId)
    {
        VirtualAssetManager.encryptLicenses(new List<Id> { licenseId });
    }
    
    public static void encryptLicenses(List<Id> licenseIds)
    {
        Set<Id> gmsLicenseIds = new Set<Id>();
        for(License__c gmsLicense : [select Id from License__c where Id in :licenseIds and (AssetId__r.Product2.Model__c='GX-V' OR AssetId__r.Product2.Product_Category__c = 'GMS')])
        {
            gmsLicenseIds.add(gmsLicense.Id);
        }
        if(gmsLicenseIds.size() > 0)
        {
            LicenseEncryptionJob job = new LicenseEncryptionJob();
            job.LicenseIds = new List<Id>(gmsLicenseIds);
            System.enqueueJob(job);
        }
        
        Set<Id> virtualLicenseIds = new Set<Id>();
        for(License__c virtualLicense : [select Id from License__c where Id in :licenseIds and AssetId__r.Product2.Model__c!='GX-V' And AssetId__r.Product2.Product_Category__c !='GMS'])
        {
            virtualLicenseIds.add(virtualLicense.Id);
        }
        if(virtualLicenseIds.size() > 0)
        {
            LicenseEncryptionJob job = new LicenseEncryptionJob();
            job.LicenseIds = new List<Id>(virtualLicenseIds);
            System.enqueueJob(job);
        }
    }
    
    public static void encryptLicenses_Batch(List<Id> licenseIds)
    {
        
        Set<Id> generateLicenseIds = new Set<Id>();
        for(License__c item : [select Id from License__c where Id in :licenseIds])
        {
            generateLicenseIds.add(item.Id);
        }
        if(generateLicenseIds.size() > 0)
        {
            LicenseEncryptionJob job = new LicenseEncryptionJob();
            job.LicenseIds = new List<Id>(generateLicenseIds);
            System.enqueueJob(job);
        }
    }
    private void assignProductModel()
    {
        Set<String> productIds = new Set<String>();
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            productIds.add(virtualAsset.Asset.Product2Id);
        }
        Map<Id, String> id2Model = new Map<Id, String>();
        Map<Id, Integer> id2Count = new Map<Id, Integer>();
        for(Product2 product : [select Id, Name, Model__c, LicenseAsModel__c, NumberOfLicenses__c from Product2 where Id in :productIds])
        {
            String model = product.LicenseAsModel__c;
            if(model == null || model.trim() == '')
            {
                model = (product.Model__c != null && product.Model__c != '') ? product.Model__c : product.Name;
            }
            model = model.replaceAll('-', '');
           
            id2Model.put(product.Id, model);
            id2Count.put(product.Id, (product.NumberOfLicenses__c == null) ? 1 : product.NumberOfLicenses__c.intValue());
        }
        for(VirtualAsset virtualAsset : VirtualAssets)
        {
            virtualAsset.ProductModel = id2Model.get(virtualAsset.Asset.Product2Id);
            virtualAsset.NumberOfLicenses = id2Count.get(virtualAsset.Asset.Product2Id);
            virtualAsset.NumberOfLicenses = (virtualAsset.NumberOfLicenses == null) ? 1 : virtualAsset.NumberOfLicenses;
        }
    }
    
    private String toHex(Integer x) 
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
    
    public class VirtualAsset
    {
        public VirtualAsset()
        {
            Licenses = new List<VirtualAssetLicense>();
        }
        
        public Asset Asset { get; set; }
        public List<VirtualAssetLicense> Licenses { get; set; }
        public String ProductModel { get; set; }
        public Integer NumberOfLicenses { get; set; }
    }
    
    public class VirtualAssetLicense
    {
        public VirtualAssetLicense(License__c license, Asset_Mac__c mac)
        {
            this.License = license;
            this.AssetMac = mac;
        }
        
        public Asset_Mac__c AssetMac { get; set; }
        public License__c License { get; set; }
    }
}