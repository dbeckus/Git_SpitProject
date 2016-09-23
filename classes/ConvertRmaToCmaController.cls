/*
* Controller for page ConvertRmaToCma
*/
public without sharing class ConvertRmaToCmaController
{
    private String assetId;
    private String virtualProductId;
     private String gmsNodes;
    private Map<String, String> nxToVxMap;
    private User currentUser;

    public ConvertRmaToCmaController()
    {
        assetId = ApexPages.CurrentPage().getParameters().get('id');
        IsConverted = false;
        currentUser = [select ContactId, Contact.AccountId, Contact.Account.Name from User where Id = :UserInfo.getUserId() and IsActive = true];
        mapCMA();
        buildData();
    }

    public Asset NxAsset { get; set; }
    public String VxModel { get; set; }
    public Boolean IsConverted { get; set; }
    public String CmaId { get; set; }

    public PageReference convert()
    {
        if(createCma())
        {
            PageReference page = new PageReference('/apex/CmaConvertConfirm?id='+CmaId);
            page.setRedirect(true);
            return page;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Convert Error!'));
            return null;
        }
    }

    private void mapCMA()
    {
        nxToVxMap = new Map<String, String>();
        for(CmaProductMapping__c cma : [select Name, NX__c, VX__c from CmaProductMapping__c])
        {
            nxToVxMap.put(cma.NX__c, cma.VX__c);
        }
    }

    private void buildData()
    {
        NxAsset = [select Id, Model__c, SerialNumber, Ship_Date__c, CreatedDate, ContactId, AccountId, Account.Name, Product2Id,
                        Contract_Number__c,GMS_Nodes__c, Contract_Type__c, Contract_End__c from Asset where Id = :assetId];
        if(NxAsset != null && String.IsNotEmpty(NxAsset.Model__c))
        {
            VxModel = nxToVXMap.get(NxAsset.Model__c);
            gmsNodes=nxAsset.GMS_Nodes__c;
            List<Product2> products = [select Id from Product2 where Name = :VxModel];
            if(products.size() > 0)
            {
                virtualProductId = products[0].Id;
            }
        }
    }

    private Boolean createCma()
    {
        Boolean result = false;
        SavePoint sp = Database.setSavePoint();
        try
        {
            // Opens an RMA of CMA record type
            String cmaRecordTypeId = SilverPeakUtils.getRecordTypeId('CMA', 'RMA__c');
            String accountId = getAccountId(NxAsset);
            RMA__c cma = new RMA__c(RecordTypeId = cmaRecordTypeId, Account__c = accountId, Contact__c = currentUser.ContactId, Status__c = 'Initiated', Type__c = 'Convert to Virtual');
            insert cma;
            CmaId = cma.Id;

            List<RMA_Item__c> rmaItems = new List<RMA_Item__c>();
            String rmaItemRecordTypeId = SilverPeakUtils.getRecordTypeId('RMA Return', 'RMA_Item__c');
            String accountName = currentUser.Contact.AccountId != null ? currentUser.Contact.Account.Name : NxAsset.Account.Name;
            //Puts the NX on CMA
            RMA_Item__c rmaItem = new RMA_Item__c(RMA__c = cma.Id, RecordTypeId = rmaItemRecordTypeId, Asset__c = NxAsset.Id, Product2__c = NxAsset.Product2Id, Status__c = 'Pending Return -Conversion',
                                                    Type__c = 'Convert to Virtual', ShipToCompany__c = accountName, Ship_To_Contact__c = currentUser.ContactId);
            rmaItems.add(rmaItem);

            // Executes the creation of the VX with perpetual license
            Asset vxAsset = createVirtualAsset(NxAsset);

            // Adds the new VX to the CMA record as well
            RMA_Item__c cmaItem = new RMA_Item__c(RMA__c = cma.Id, RecordTypeId = rmaItemRecordTypeId, Asset__c = vxAsset.Id, Product2__c = virtualProductId, Status__c = 'Shipped',
                                                    Type__c = 'Convert to Virtual', ShipToCompany__c = accountName, Ship_To_Contact__c = currentUser.ContactId);
            rmaItems.add(cmaItem);
            insert rmaItems;

            Asset createdVxAsset = [select SerialNumber, Contract_Type__c, Contract_End__c, Model__c from Asset where Id = :vxAsset.Id];
            update new Asset(Id = NxAsset.Id, Contract_Number__c = null); //sends email CmaRequestProcessedResult
            System.debug('createdVxAsset: ' + createdVxAsset.Model__c);
            if(isRecycling(NxAsset))
            {
                update new RMA__c(Id = cma.Id, IsRecycling__c = true); // sends email NXApplianceRecyclingInstructions
            }
          
            result = true;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            Apexpages.addMessages(ex);
            result = false;
        }
        return result;
    }

    private Asset createVirtualAsset(Asset asset)
    {
        Asset vxAsset = new Asset();
        vxAsset.Evaluation_Start_Date__c = Date.today();
        try
        {
            Asset_mac__c assetMac = SilverPeakUtils.getAssetMac();
            assetMac.Used__c = true;
            upsert assetMac;

            String mac = [select Name from Asset_Mac__c where Id = :assetMac.Id limit 1].Name;
            vxAsset.Name = '001BBC' + SilverPeakUtils.toHex(Integer.valueof(mac));
            vxAsset.SerialNumber = vxAsset.Name;
            vxAsset.Status = 'Customer Owned';
            vxAsset.Quantity = 1;
            vxAsset.Ship_Date__c = Date.today();
            vxAsset.ContactId = currentUser.ContactId;
            String accountId = getAccountId(asset);
            vxAsset.AccountId = accountId;
            vxAsset.Contract_Number__c = asset.Contract_Number__c;
            vxAsset.product2Id = virtualProductId;
            vxAsset.TriggerAutoFulfillEmail__c=true;
            vxAsset.GMS_Nodes__c=gmsNodes;
            insert vxAsset;

            assetMac.AssetId__c = vxAsset.Id;
            update assetMac;
            createLicense(vxAsset);
            return vxAsset;
        }
        catch(DmlException ex)
        {
            Apexpages.addMessages(ex);
            return null;
        }
    }

    private void createLicense(Asset asset)
    {
        License__c license = new License__c();
        license.Quantity__c = 1;
        license.AssetId__c = asset.Id;
        license.Contact_for_Notification__c = asset.ContactId;
        license.Start_Date__c = asset.Evaluation_Start_Date__c;
        String licenseAsModel = '';
        if(String.isNotEmpty(virtualProductId))
        {
            List<Product2> products = [select LicenseAsModel__c, Model__c from Product2 where Id = :virtualProductId limit 1];
            if(products.size() > 0)
            {
                licenseAsModel = String.isEmpty(products[0].LicenseAsModel__c) ? products[0].Model__c : products[0].LicenseAsModel__c;
            }
        }
        if(!string.isBlank(gmsNodes))
        {
            license.Quantity__c=decimal.valueOf(gmsNodes);
        }
        license.Model__c = licenseAsModel;
        license.SerialNumber__c = asset.Name;
        license.License_Expiration__c = null;
        insert license;
        VirtualAssetManager.encryptLicenses(new List<String> { license.Id });
    }

    // NX Recycle Criteria
    private Boolean isRecycling(Asset asset)
    {
        Boolean result = false;
        Set<String> nxRecyleCountries = new Set<String>{ 'China', 'India', 'Russia', 'Brasil'};
        List<RMA_Item__c> rmaItem = [select ShipToCountry__c from RMA_Item__c where Asset__c = :asset.Id];
        if(asset.Ship_Date__c != null && rmaItem.size() > 0)
        {
            if((asset.CreatedDate.addYears(3) > Date.today()) || asset.Model__c == 'NX-1700' || nxRecyleCountries.contains(rmaItem[0].ShipToCountry__c))
            {
                result = true;
            }
        }
        return result;
    }

    private String getAccountId(Asset asset)
    {
        return currentUser.Contact.AccountId == null ? asset.AccountId : currentUser.Contact.AccountId;
    }
}