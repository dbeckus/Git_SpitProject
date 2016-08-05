/**
* controller for NewRMA page
*/
global class NewRMAController
{
    private String id;
    private Contact contact;
    private Case caseInfo;
    private RMA__c RMA;
    private RMA_Item__c RMAItem;
    private String accountId;
    private Boolean portalUser;
    private final String ERROR_NoEntitled = 'Your appliance is not covered under a service agreement or plan. ' + 
        'Please contact your Silver Peak authorized reseller or Account Manager to renew your service plan. ' +
        'If you believe this unit is covered under service or warranty, ' +
        'please open a case to request your RMA and data correction on this unit.';
    
    public NewRMAController()
    {
        caseInfo = new Case();
        contact = new Contact();
        
        Products = new List<ProductInfo> { new ProductInfo('System'), new ProductInfo('HDD', 1), new ProductInfo('SSD', 1), new ProductInfo('Power Supply'), new ProductInfo('NVME',1) };
            
            User user = [select UserType, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId()];
        if(user.UserType == 'CustomerSuccess' || user.UserType == 'PowerCustomerSuccess')
        {
            AccountId = user.Contact.AccountId;
        }
        id = ApexPages.currentPage().getParameters().get('id'); //case ID or account ID or asset ID.
        
        initializeRMA();
        initializeRMAItem();
        
    }
    
    public List<ProductInfo> Products { get; set; }
    public List<ProductInfo> SelectedProducts
    {
        get
        {
            List<ProductInfo> result = new List<ProductInfo>();
            for(ProductInfo prd : Products)
            {
                if(prd.Selected)
                {
                    result.add(prd);
                }
            }
            return result;
        }
    }
    
    public String SelectedState { get; set; }
    public Boolean Disabled { get; set; }
    public RMA__c getRMA()
    { 
        return RMA; 
    }
    
    public void setRMA(RMA__c rma)
    {   
        RMA = rma;
    }
    
    public Boolean IsPortalUser
    {
        get
        {
            if(portalUser == null)
            {
                User user = [select UserType, ContactId, Contact.AccountId from User where Id = :UserInfo.getUserId()];
                portalUser = (user.UserType == 'CustomerSuccess' || user.UserType == 'PowerCustomerSuccess');
            }
            return portalUser;
        }
    }
    
    public Contact getContact()
    {
        return contact;
    }
    
    public void setContact(Contact ct)
    {
        contact = ct;
    }
    
    public RMA_Item__c getRMAItem()
    {
        return RMAItem;
    }
    
    public void setRMAItem(RMA_Item__c ramItem)
    {
        this.RMAItem = ramItem; 
    }
    
    public List<SelectOption> getDeliveryClasses()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.Describefieldresult F = RMA_Item__c.Delivery_Class__c.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        for(Schema.Picklistentry pList : P)
        {
            options.add(new SelectOption(pList.getValue(), pList.getLabel()));
        }
        return options;
    }
    
    public List<SelectOption> getRMATypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        Schema.Describefieldresult F = RMA__c.Type__c.getDescribe();
        List<Schema.Picklistentry> P = F.getPicklistValues();
        for(Schema.Picklistentry pList : P)
        {
            if(!pList.getValue().equals('Recall') && !pList.getValue().equals('Eval Return'))
            {
                options.add(new SelectOption(pList.getValue(), pList.getLabel()));
            }
        }
        return options;
    }
    
    public PageReference save()
    {
        SavePoint sp = Database.setSavePoint();
        Boolean isSystemSelected = false;
        for(ProductInfo p : Products)
        {
            if(p.Selected && p.Name == 'System')
            {
                isSystemSelected = true;
                break;
            }
        }
        
        Asset asset = new Asset();
        List<Asset> assets = [select AccountId, Part_Number__c, Product2Id, Product2.ProductCode, Product2.RMA_Primary_Replacement__c from Asset where Id = :RMAItem.Asset__c];
        if(assets.size() > 0)
        {
            asset = assets[0]; 
        }
        List<ReplaceablePartNumberMatrix__c> replaceableParts = [select HDD_PN__c, SSD_PN__c, PS_PN__c,NVME_PN__c from ReplaceablePartNumberMatrix__c where Product_PN__c=:asset.Product2.ProductCode and Asset_PN__c=:asset.Part_Number__c limit 1];
        ReplaceablePartNumberMatrix__c replaceablePart = (replaceableParts.size() > 0) ? replaceableParts[0] : new ReplaceablePartNumberMatrix__c(HDD_PN__c=null, SSD_PN__c=null, PS_PN__c=null);
        if(checkProductComponents(asset, replaceablePart)) 
        {
            // Creates a case if the returned product is system from portal user.
            if(IsPortalUser && isSystemSelected)
            {
                String newCaseId = createCase();
                RMA.Case__c = newCaseId;
                RMA.Status__c = getPicklistDefaultValue(RMA__c.Status__c.getDescribe());
            }
            
            try
            {
                checkContactInfo(); //checks the existing contact according to Email
                System.debug('rma case '+ RMA.Case__c);
                if(contact!=null && contact.Id == null && RMA.Case__c!=null)
                {
                    
                    Case caseInfo=[Select Id,ContactId from Case where Id=:RMA.Case__c LIMIT 1];
                    if(caseInfo.ContactId!=null)
                    {
                        contact=[select Id, Email, FirstName, LastName from Contact where Id=:caseInfo.ContactId];
                    }
                    
                }
                System.debug('contactId'+ contact.Id);
                RMA.Contact__c = contact.Id;
                RMA.Account__c = asset.AccountId;
                RMA.IsRecycling__c = needRecycle(asset);
                RMA.Contact_Email_Loc_4__c = RMAItem.Contact_Email__c;
                upsert RMA;
            }
            catch(DMLException ex)
            {
                ApexPages.addMessages(ex);
                Database.rollback(sp);
                return null;
            }
            
            try
            {
                List<RMA_Item__c> RMAItems = getRMAItems(asset, replaceablePart);
                if(RMAItems.size() > 0)
                {
                    asset.Installed_At_Location__c =  concateAddress(RMAItems[0].ShipToAddress__c, RMAItems[0].ShipToAddressAdditional__c, RMAItems[0].ShipToCity__c, RMAItems[0].ShipToStateOrProvince__c, RMAItems[0].ShipToPostalCode__c, RMAItems[0].ShipToCountry__c);
                }
                else if(RMAItems.size() == 0)
                {
                    String message = 'Can not create an RMA with no product. Use the back arrow and check a component option to continue.';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));
                    Database.rollback(sp);
                    return null;
                }
                insert RMAItems;
                update asset;
                if(caseInfo.Id != null && caseInfo.AssetId != RMAItem.Asset__c)
                {
                    caseInfo.AssetId = RMAItem.Asset__c;
                    update caseInfo;
                }
                return new ApexPages.Pagereference('/' + RMA.Id);
            }
            catch(DMLException ex)
            {
                Database.rollback(sp);
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    public PageReference next()
    {
        if(Disabled == true)
        {
            return null;
        }
        Boolean productsSelected = false;
        for(ProductInfo p : Products)
        {
            if(p.Selected)
            {
                productsSelected = true;
                break;
            }
        }
        if(!productsSelected)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must choose a product to continue.'));
            return null;
        }
        
        Asset asset = new Asset();
        List<Asset> assets = [select AccountId, Part_Number__c, Product2Id, Product2.Name, Product2.ProductCode, Product2.RMA_Primary_Replacement__c from Asset where Id = :RMAItem.Asset__c];
        if(assets.size() > 0)
        {
            asset = assets[0]; 
        }
        List<ReplaceablePartNumberMatrix__c> replaceableParts = [select HDD_PN__c, SSD_PN__c, PS_PN__c,NVME_PN__c from ReplaceablePartNumberMatrix__c where Product_PN__c=:asset.Product2.ProductCode and Asset_PN__c=:asset.Part_Number__c limit 1];
        ReplaceablePartNumberMatrix__c replaceablePart = (replaceableParts.size() > 0) ? replaceableParts[0] : new ReplaceablePartNumberMatrix__c(HDD_PN__c=null, SSD_PN__c=null, PS_PN__c=null);
        if(!checkProductComponents(asset, replaceablePart))
        {
            return null;
        }
        
        if(!validateSlotNumber())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Slot number is invalid.'));
            return null;
        }
        if(!isEntitledAsset(RMAItem.Asset__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, ERROR_NoEntitled));
        }
        if(RMA.Compromised_Breached__c && String.isBlank(RMA.Reason_for_Compromise_Breach__c))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter reason for Compromised/Breach.'));
            return null;
        }
        List<CountryStateTable__c> states = getStateList(RMAItem.ShipToCountry__c);
        if(states.size() > 0)
        {
            Boolean foundState = false;
            for(CountryStateTable__c state : states)
            {
                if(state.StateCode__c == RMAItem.ShipToStateOrProvince__c)
                {
                    foundState = true;
                    break;
                }
            }
            if(!foundState)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must choose a Ship to State/Province.'));
                return null;
            }
        }
        return Page.NewRmaConfirmation;
    }
    
    private List<RMA_Item__c> getRMAItems(Asset asset, ReplaceablePartNumberMatrix__c replaceablePart)
    {
        List<RMA_Item__c> RMAItems = new List<RMA_Item__c>();
        if(RMA.Type__c == 'Return for Repair')
        {
            RMAItem.Type__c = 'Return - Repair and Return';
        }
        else if(RMA.Type__c == 'Advance Replace')
        {
            RMAItem.Type__c = 'Advance - Ship Unit';
        }
        
        for(ProductInfo p : Products)
        {
            RMA_Item__c item = new RMA_Item__c();
            //common information             
            RMAItem2NewItem(item);
            
            if(p.Selected)
            {
                item.Quantity__c = p.Name.equals('System') ? 1 : p.Qty;
                if(p.Name.equals('System'))
                {
                    if(asset.Product2.RMA_Primary_Replacement__c != null)
                    {
                        item.Product2__c = asset.Product2.RMA_Primary_Replacement__c;
                        item.AltProdPreviouslyOrdered__c = asset.Product2Id;
                    }
                    else
                    {
                        item.Product2__c = asset.Product2Id;
                    }
                }
                else if(p.Name.equals('HDD'))
                {
                    Product2 hddProduct = [select Id, RMA_Primary_Replacement__c from Product2 where ProductCode=:replaceablePart.HDD_PN__c limit 1];
                    if(hddProduct.RMA_Primary_Replacement__c != null)
                    {
                        item.Product2__c = hddProduct.RMA_Primary_Replacement__c;
                        item.AltProdPreviouslyOrdered__c = hddProduct.Id;
                    }
                    else
                    {
                        item.Product2__c = hddProduct.Id;
                    }
                    item.SlotNumber__c = String.valueOf(p.Slot);
                }
                else if(p.Name.equals('SSD'))
                {
                    Product2 ssdProduct = [select Id, RMA_Primary_Replacement__c from Product2 where ProductCode=:replaceablePart.SSD_PN__c limit 1];
                    if(ssdProduct.RMA_Primary_Replacement__c != null)
                    {
                        item.Product2__c = ssdProduct.RMA_Primary_Replacement__c;
                        item.AltProdPreviouslyOrdered__c = ssdProduct.Id;
                    }
                    else
                    {
                        item.Product2__c = ssdProduct.Id;
                    }
                    item.SlotNumber__c = String.valueOf(p.Slot);
                }
                else if(p.Name.equals('Power Supply'))
                {
                    Product2 psProduct = [select Id, RMA_Primary_Replacement__c from Product2 where ProductCode=:replaceablePart.PS_PN__c limit 1];
                    if(psProduct.RMA_Primary_Replacement__c != null)
                    {
                        item.Product2__c = psProduct.RMA_Primary_Replacement__c;
                        item.AltProdPreviouslyOrdered__c = psProduct.Id;
                    }
                    else
                    {
                        item.Product2__c = psProduct.Id;
                    }
                }
                else if(p.Name.equals('NVME'))
                {
                    
                    Product2 psProduct = [select Id, RMA_Primary_Replacement__c from Product2 where ProductCode=:replaceablePart.NVME_PN__c limit 1];
                    if(psProduct.RMA_Primary_Replacement__c != null)
                    {
                        item.Product2__c = psProduct.RMA_Primary_Replacement__c;
                        item.AltProdPreviouslyOrdered__c = psProduct.Id;
                    }
                    else
                    {
                        item.Product2__c = psProduct.Id;
                    }
                }
                RMAItems.add(item);
                break;
            }
        }
        return RMAItems;
    }
    
    private Boolean validateSlotNumber()
    {
        // Take the product and compared with 'Validate Slot' custom setting to verify whether the slot number is valid.
        Asset asset = new Asset();
        List<Asset> assets = [select AccountId, Part_Number__c, Product2Id, Product2.Name, Product2.ProductCode, Product2.RMA_Primary_Replacement__c from Asset where Id = :RMAItem.Asset__c];
        if(assets.size() > 0)
        {
            asset = assets[0]; 
        }
        List<ReplaceablePartNumberMatrix__c> replaceableParts = [select HDD_PN__c, SSD_PN__c, PS_PN__c,NVME_PN__c from ReplaceablePartNumberMatrix__c where Product_PN__c=:asset.Product2.ProductCode and Asset_PN__c=:asset.Part_Number__c limit 1];
        ReplaceablePartNumberMatrix__c replaceablePart = (replaceableParts.size() > 0) ? replaceableParts[0] : new ReplaceablePartNumberMatrix__c(HDD_PN__c=null, SSD_PN__c=null, PS_PN__c=null,NVME_PN__c=null);
        for(ProductInfo p : Products)
        {
            if(p.Selected)
            {
                if(checkProductComponents(asset, replaceablePart))
                {
                    Boolean isValidSlot = true;
                    if(p.Name.equals('HDD'))
                    {
                        isValidSlot = false;
                        if(replaceablePart.HDD_PN__c != null)
                        {
                            isValidSlot = isValidSlotNumber(asset.Product2.Name, 'HDD', p.slot, asset.Part_Number__c);
                        }
                    }
                    else if(p.Name.equals('SSD'))
                    {
                        isValidSlot = false;
                        if(replaceablePart.SSD_PN__c != null)
                        {
                            isValidSlot = isValidSlotNumber(asset.Product2.Name, 'SSD', p.slot, asset.Part_Number__c);
                        }
                    }
                    else if(p.Name.equals('NVME'))
                    {
                        isValidSlot = false;
                        if(replaceablePart.NVME_PN__c != null)
                        {
                            isValidSlot = isValidSlotNumber(asset.Product2.Name, 'NVME', p.slot, asset.Part_Number__c);
                        }
                    }
                    if(!isValidSlot)
                    {
                        return false;
                    }
                }
                else
                {
                    return false;
                }
            }
        }
        return true;
    }
    
    private Boolean isValidSlotNumber(String productName, String productType, Integer slotNumber, String pn)
    {
        String alphabetCharacters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        Boolean isValid = false;
        for(ValidateSlot__c validSlot : ValidateSlot__c.getAll().values())
        {
            if(productName.startsWith(validSlot.Model__c) && pn == validSlot.AssetPN__c)
            {
                if(productName.length() == validSlot.Model__c.length())
                {  
                    if(productType == validSlot.Type__c && slotNumber >= validSlot.Start__c && slotNumber <= validSlot.End__c)
                    {
                        isValid = true;
                    }
                }
                else if(productName.length() > validSlot.Model__c.length())
                {
                    if(!alphabetCharacters.contains(productName.substring(validSlot.Model__c.length(), validSlot.Model__c.length()+1)))
                    {
                        if(productType == validSlot.Type__c && slotNumber >= validSlot.Start__c && slotNumber <= validSlot.End__c)
                        {
                            isValid = true;
                        }
                    }
                }
            }
        }
        return isValid;
    }
    
    public PageReference previous()
    {
        PageReference result = Page.NewRMA;
        result.getParameters().put('id', id);
        return result;
    }
    
    public PageReference saveAndNew()
    {
        if(save() != null)
        {
            PageReference newPage = new ApexPages.Pagereference('/apex/newrma?id=' + id);
            newPage.setRedirect(true);
            return newPage;
        }
        return null;
    }
    
    public PageReference cancel()
    {
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        if(retURL != null && retURL != '')
        {
            return new PageReference(retURL);
        }
        if(IsPortalUser)
        {
            return Page.PickAssetForNewRMA;
        }
        else
        {
            if(id != null && id != '')
            {
                return new ApexPages.Pagereference('/' + id);
            }
            return new ApexPages.Pagereference('/500/o');
        }
    }
    
    private void initializeRMA()
    {
        RMA = new RMA__c(Type__c = 'Advance Replace', RecordTypeId = getRecordTypeId('RMA', 'RMA__c'));
        RMA.Requested_By__c = getPicklistDefaultValue(RMA__c.Requested_By__c.getDescribe());
        RMA.Next_Recipient__c = getPicklistDefaultValue(RMA__c.Next_Recipient__c.getDescribe());
        RMA.Status__c = IsPortalUser ? 'Dispatched' : getPicklistDefaultValue(RMA__c.Status__c.getDescribe());
        
        if(Id instanceof ID)
        {
            if(id.startsWith('001'))  //is Account
            {
                accountId = id;
            }
            else if(id.startsWith('500')) // is Case
            {
                caseInfo = [select AssetId, Asset.AccountId, ContactId from Case where Id = :id];
                RMA.Case__c = id;
                accountId = caseInfo.Asset.AccountId;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Id not found.'));
        }
        
        RMA.Account__c = accountId;
        if(RMA.Account__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must select an Account before creating new RMA.' ));
        }
    }
    
    private void initializeRMAItem()
    {
        if(IsPortalUser && !isEntitledForRMA(id))
        {
            Disabled = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ERROR_NoEntitled));
        }
        else
        {
            RMAItem = new RMA_Item__c();
            RMAItem.Asset__c = IsPortalUser ? id : caseInfo.AssetId; 
            RMAItem.RecordTypeId = getRecordTypeId('RMA Return', 'RMA_Item__c');
            RMAItem.Status__c = 'Initiated';
            if(RMA.Account__c != null)
            {
                RMAItem.ShipToCompany__c = [select Id, Name from Account where Id = :RMA.Account__c limit 1].Name;
            }
        }
    }   
    
    @testvisible
    private Boolean isEntitledForRMA(Id assetId)
    {
        List<Asset> assets = [select Id, Entitled_for_RMA__c from Asset where Id=:assetId limit 1];
        if(assets.size() > 0)
        {
            return assets[0].Entitled_for_RMA__c == 1;
        }
        return true;
    }
    
    private Boolean needRecycle(Asset asset)
    {
        Boolean isRecyclingModel = false;
        Product2 prd = [select Id, Model__c from Product2 where Id=:asset.Product2Id limit 1];
        if(prd.Model__c!=null)
        {
            if(prd.Model__c == 'GX-1000' || prd.Model__c.endsWith('500') || prd.Model__c.endsWith('504') || prd.Model__c.endsWith('600') || (prd.Model__c == 'NX-1700' && String.isEmpty(asset.Part_Number__c)) || (prd.Model__c == 'NX-1700' && asset.Part_Number__c=='200613'))
            {
                isRecyclingModel = true;
            }
        }
        for(ProductInfo p : Products)
        {
            if(p.Selected && p.Name.equals('System') && isRecyclingModel == true)
            {
                return true;
            }
        }
        return false;
    }
    
    @testvisible
    private Id getRecordTypeId(String name, String objName)
    {
        List<RecordType> recordType = [Select Id from RecordType where Name = :name and IsActive = true and SObjectType = :objname];
        if(recordType.size() > 0)
        {
            return recordType[0].Id;
        } 
        return null;
    }
    
    private String getPicklistDefaultValue(Schema.Describefieldresult F)
    {
        List<Schema.Picklistentry> P = F.getPicklistValues();
        for(Schema.Picklistentry pList : P)
        {
            if(pList.isDefaultValue())
            {
                return pList.getValue();
            }
        }
        return null;
    }
    
    private void RMAItem2NewItem(RMA_Item__c item)
    {
        item.RMA__c = RMA.Id;
        item.Delivery_Class__c = RMAItem.Delivery_Class__c;
        item.RecordTypeId = RMAItem.RecordTypeId;
        item.Status__c = RMAItem.Status__c;
        item.Type__c  = RMAItem.Type__c;
        item.Asset__c = RMAItem.Asset__c;
        item.Ship_To_Contact__c = contact.Id;
        item.ShipToCompany__c = RMAItem.ShipToCompany__c;
        item.Contact_Email__c = RMAItem.Contact_Email__c;
        item.Contact_Phone__c = RMAItem.Contact_Phone__c;
        item.ShipToAddress__c = RMAItem.ShipToAddress__c;
        item.ShipToAddressAdditional__c = RMAItem.ShipToAddressAdditional__c;
        item.ShipToCity__c = RMAItem.ShipToCity__c;
        item.ShipToCountry__c = RMAItem.ShipToCountry__c;
        item.ShipToPostalCode__c = RMAItem.ShipToPostalCode__c;
        item.ShipToStateOrProvince__c = RMAItem.ShipToStateOrProvince__c;
        item.Ship_to_address__c = concateAddress(item.ShipToAddress__c, item.ShipToAddressAdditional__c, item.ShipToCity__c, item.ShipToStateOrProvince__c, item.ShipToPostalCode__c, item.ShipToCountry__c, contact.FirstName, contact.LastName, item.Contact_Phone__c);
    }
    
    @testvisible
    private String createCase()
    {
        Group queue = [select Id from Group where Name = 'Tech Support Queue' limit 1];
        try
        {
            Case newCase = new Case(OwnerId = queue.Id, AccountId = accountId, AssetId = RMAItem.Asset__c, ContactId = contact.Id, RecordTypeId = getRecordTypeId('Incoming Email', 'Case'), Subject = 'RMA Requested', Priority = 'P3 - Normal', Status = 'Qualifying', Type = 'Incoming Email');
            insert newCase;
            return newCase.Id;
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    private void shipInfo2MailingInfo()
    {
        contact.FirstName = RMA.ContactFirstName__c;
        contact.LastName = Rma.ContactLastName__c;
        contact.Email = RMAItem.Contact_Email__c;
        contact.Phone = RMAItem.Contact_Phone__c;
        contact.MailingStreet = (RMAItem.ShipToAddressAdditional__c != null) ? RMAItem.ShipToAddress__c + '\r\n' + RMAItem.ShipToAddressAdditional__c : RMAItem.ShipToAddress__c;
        contact.MailingCity = RMAItem.ShipToCity__c;
        contact.MailingCountry = RMAItem.ShipToCountry__c;
        contact.MailingPostalCode = RMAItem.ShipToPostalCode__c;
        contact.MailingState = RMAItem.ShipToStateOrProvince__c;
    }
    
    private void checkContactInfo()
    {
        //checks the existing contact according to the Email address
        List<Contact> existingContacts = new List<Contact>();
        if(contact.Id != null)
        { 
            existingContacts = [select Id, Email, FirstName, LastName from Contact where Id = :contact.Id and Email = :RMAItem.Contact_Email__c];
        }
        else
        {
            existingContacts = [select Id, Email, FirstName, LastName from Contact where AccountId = :id and Email = :RMAItem.Contact_Email__c limit 1];
            if(existingContacts.size() == 0)
            {
                existingContacts = [select Id, Email, FirstName, LastName from Contact where Email = :RMAItem.Contact_Email__c limit 1];
            }
        }
        
        if(existingContacts.size() > 0)
        {
            //temp value, not update the existing contact
            contact = existingContacts[0];
            contact.FirstName = RMA.ContactFirstName__c;
            contact.LastName = RMA.ContactLastName__c;
        }
        else
        {
            shipInfo2MailingInfo();
            contact.AccountId = RMA.Account__c;
            try
            {
                //upsert contact;
            }
            catch(DMLException ex)
            {
                ApexPages.addMessages(ex);
            }
        }
    }
    
    public static String concateAddress(String street1, String street2, String city, String state, String zip, String country)
    {
        String address = (street1 != null) ? (street1 + '\r\n') : '';
        address += (street2 != null) ? (street2 + '\r\n') : '';
        address += (city != null ? (city + ', ') : '') + (state != null ? (state + ' ') : '') + (zip != null ? zip : '') + '\r\n';
        address += country != null ? country : '';
        address = address.replaceAll('(\r\n)+', '\r\n').trim();
        if(address.endsWith('\r\n'))
        {
            address = address.subString(0, address.length() - 2);
        }
        return address;
    }
    
    public static String concateAddress(String street1, String street2, String city, String state, String zip, String country, String firstName, String lastName, String phone)
    {
        String address = (street1 != null) ? (street1 + '\r\n') : '';
        address += (street2 != null) ? (street2 + '\r\n') : '';
        address += (city != null ? (city + '\r\n') : '');
        address += (zip != null ? (zip + ' ') : '') + (state != null ? state : '') + '\r\n';
        address += country != null ? (country + '\r\n') : '';
        address += (firstName != null ? (firstName + ' ') : '') + ((lastName != null) ? (lastName + ' ') : '') + ((phone != null) ? phone : '');
        address = address.replaceAll('(\r\n)+', '\r\n').trim();
        if(address.endsWith('\r\n'))
        {
            address = address.subString(0, address.length() - 2);
        }
        return address;
    }
    
    private static Boolean isEntitledAsset(Id assetId)
    {
        Asset[] assets = [select Entitled_For_RMA__c from Asset where Id=:assetId limit 1];
        if(assets.size() > 0 && assets[0].Entitled_For_RMA__c == 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }
    
    @RemoteAction
    global static List<CountryStateTable__c> getStateList(String country)
    {
        if(country == 'US' || country == 'USA')
        {
            country = 'United States';
        }
        return [select StateCode__c, StateName__c from CountryStateTable__c where Country__c=:country order by StateName__c];
    }
    
    @RemoteAction
    global static Contact loadContactFromCase(Id caseId)
    {
        List<Case> cases = [select Id, ContactId from Case where Id=:caseId limit 1];
        if(cases.size() > 0)
        {
            List<Contact> contacts = [select Id, FirstName, LastName, Email, Phone, MailingStreet, MailingState, MailingPostalCode, MailingCountry, MailingCity from Contact where Id = :cases[0].ContactId limit 1];
            if(contacts.size() > 0)
            {
                return contacts[0];
            }
        }
        return null;
    }
    
    webservice static String[] parseAssetAddress(String assetName)
    {
        if(assetName != null)
        {
            List<Asset> assets = [select Id, Installed_At_Location__c from Asset where Name=:assetName limit 1];
            if(assets.size() > 0)
            {
                return parseAddress(assets[0].Installed_At_Location__c);
            }
        }
        return new String[] {'', '', '', '', '', 'USA'};
            }
    
    /**
* parses a single string to street line1, street line2, city, state, zip and country
* the parameter should be of format:
*  street line 1
*  street line 2
*  city, state zip
*  country
* result is an array contains the following part: [0]: street1, [1]: street2, [2]: city, [3]: state, [4]: zip, [5]: country
*/
    @testvisible
    private static String[] parseAddress(String address)
    {
        String street1 = '', street2 = '', city = '', state = '', zip = '', country = 'USA';
        if(address == null)
        {
            address = '';
        }
        String[] lines = address.split('(\r\n)|\r|\n', 4);
        //if the address fits well with 4 lines.
        if(lines.size() == 4)
        {
            street1 = lines[0];    
            street2 = lines[1];
            String[] cityStateZip = parseCityStateZip(lines[2]);
            city = cityStateZip[0];
            state = cityStateZip[1];
            zip = cityStateZip[2];
            country = lines[3];
        }
        else if(lines.size() == 3) //if there are 3 lines in the address
        {
            street1 = lines[0];
            if(lines[1].indexOf(',') >= 0)
            {
                String[] cityStateZip = parseCityStateZip(lines[1]);
                city = cityStateZip[0];
                state = cityStateZip[1];
                zip = cityStateZip[2];
                country = lines[2];
            }
            else
            {
                street2 = lines[1];
                if(lines[2].indexOf(',') >= 0)
                {
                    String[] cityStateZip = parseCityStateZip(lines[2]);
                    city = cityStateZip[0];
                    state = cityStateZip[1];
                    zip = cityStateZip[2];
                }
                else
                {
                    country = lines[2];
                }
            }
        }
        else if(lines.size() == 2)
        {
            if(lines[0].indexOf(',') >= 0)
            {
                String[] cityStateZip = parseCityStateZip(lines[0]);
                city = cityStateZip[0];
                state = cityStateZip[1];
                zip = cityStateZip[2];
                country = lines[1];
            }
            else
            {
                street1 = lines[0];
                if(lines[1].indexOf(',') >= 0)
                {
                    String[] cityStateZip = parseCityStateZip(lines[1]);
                    city = cityStateZip[0];
                    state = cityStateZip[1];
                    zip = cityStateZip[2];
                }
                else
                {
                    street2 = lines[1];
                }
            }
        }
        else //lines.size() == 1
        {
            if(lines[0].indexOf(',') >= 0)
            {
                String[] cityStateZip = parseCityStateZip(lines[0]);
                city = cityStateZip[0];
                state = cityStateZip[1];
                zip = cityStateZip[2];
            }
            else
            {
                street1 = lines[0];
            }
        }
        return new String[] { street1, street2, city, state, zip, country};
            }
    
    /**
* called by the method parseAddress
* parses string to represent city, state and zip
* "city, state zip"
*/
    private static String[] parseCityStateZip(String cityStateZip)
    {
        String city = '', state = '', zip = '';
        if(cityStateZip != null)
        {
            cityStateZip = cityStateZip.trim();
            if(cityStateZip.indexOf(',') >= 0)
            {
                city = cityStateZip.substring(0, cityStateZip.indexOf(','));
                String stateZip = cityStateZip.substring(cityStateZip.indexOf(',') + 1);
                stateZip = stateZip.trim();
                if(stateZip.indexOf(' ') >= 0)
                {
                    state = stateZip.substring(0, stateZip.indexOf(' '));
                    zip = stateZip.substring(stateZip.indexOf(' ') + 1);
                }
                else
                {
                    state = stateZip;
                }
            }
            else
            {
                city = cityStateZip;
            }
        }
        return new String[] { city, state, zip };
            }
    
    private Boolean checkProductComponents(Asset asset, ReplaceablePartNumberMatrix__c replaceablePart)
    {
        if(RMA.Account__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account: You must enter a value' ));
            return false;
        }
        if(RMAItem.Asset__c == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Asset: You must enter a value' ));
            return false;
        }
        if(asset.Product2Id == null)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The asset you selected doesn\'t contain product' ));
            return false;
        }
        for(ProductInfo p : Products)
        {
            if(p.Selected)
            {
                if(p.Name.equals('HDD') && replaceablePart.HDD_PN__c == null)
                {
                    if([select count() from Product2 where ProductCode=:replaceablePart.HDD_PN__c and IsActive=true limit 1] == 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The asset you selected doesn\'t contain HDD component' ));
                        return false;
                    }
                }
                else if(p.Name.equals('SSD') && replaceablePart.SSD_PN__c == null)
                {
                    if([select count() from Product2 where ProductCode=:replaceablePart.SSD_PN__c and IsActive=true limit 1] == 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The asset you selected doesn\'t contain SSD component' ));
                        return false;
                    }
                }
                else if(p.Name.equals('Power Supply') && replaceablePart.PS_PN__c == null)
                {
                    if([select count() from Product2 where ProductCode=:replaceablePart.PS_PN__c and IsActive=true limit 1] == 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The asset you selected doesn\'t contain Power Supply component' ));
                        return false;
                    }
                }
                else if(p.Name.equals('NVME') && replaceablePart.NVME_PN__c == null)
                {
                    System.debug('replaceablePart.NVME_PN__c '+replaceablePart.NVME_PN__c);
                    if([select count() from Product2 where ProductCode=:replaceablePart.NVME_PN__c and IsActive=true limit 1] == 0)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The asset you selected doesn\'t contain NVME component' ));
                        return false;
                    }
                }
            }
        }
        return true;
    }
    
    public class ProductInfo
    {
        public ProductInfo(String name)
        {
            this.Name = name;
        }
        
        public ProductInfo(String name, Decimal qty)
        {
            this.Name = name;
            this.Qty = qty;
        }
        
        public String Name { get; set; }
        public Boolean Selected { get; set; }
        public Decimal Qty { get; set; }
        public Integer Slot { get; set; }
    }
}