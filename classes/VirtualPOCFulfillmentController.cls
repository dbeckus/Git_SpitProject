/*
* Controller of page VirtualPOCFullfillment
*/
public class VirtualPOCFulfillmentController
{
    private static final Integer DEFAULT_LICENSE_DURATION_DAYS = 30;
    private final String VIRTUAL_PRODUCT_NAME = 'GMS-10';
    private Request__c pocRequest;
    private List<SelectOption> productOptionsCollection;
    
    public VirtualPOCFulfillmentController(ApexPages.StandardController controller)
    {
        System.debug('controller.getId()'+ controller.getId());
        List<Request__c> requests = [select Id, Opportunity__c,Opportunity__r.Account.Partner_Type__c,Opportunity__r.Account.ECSP__c, Is_Unity_Cloud_Orchestrator__c,Opportunity__r.AccountId,POC_Type__c, POC_Contact__c, GMS_Needed__c, EvaluationProductHypervisor__c, Evaluation_Product_1__c, Evaluation_Product_2__c, Quantity_Location_1__c, Quantity_Location_2__c, Status__c, Actual_Ship_Date__c, Target_End_Date__c, VirtualProduct1__c, VirtualProduct2__c, VirtualProduct3__c, VirtualProduct4__c, VirtualProduct5__c, VirtualQuantity1__c, VirtualQuantity2__c, VirtualQuantity3__c, VirtualQuantity4__c, VirtualQuantity5__c from Request__c where Id = :controller.getId()];        
        if(!requests.isEmpty())
        {
            pocRequest = requests[0];
            if(pocRequest.Opportunity__r.Account.ECSP__c)
            {
                LicenseDurationDays=90;
            }
            else
            {
                LicenseDurationDays = DEFAULT_LICENSE_DURATION_DAYS;  
            }
            
            initVirtualAssetInfo();
        }
        isFromApex = false;
    }
    
    public List<VirtualAssetInfo> VirtualAssets { get; set; }
    public VirtualAssetManager VAManager { get; set; }
    public Integer LicenseDurationDays { get; set; }
    public Boolean isFromApex { get; set; }
    
    public List<SelectOption> ProductOptions
    {
        get
        {
            if(productOptionsCollection == null)
            {
                productOptionsCollection = new List<SelectOption>();
                for (Product2 prd : [select Id, Name from Product2 where Family = 'Virtual Image' order by Name]) 
                {
                    productOptionsCollection.add(new SelectOption(prd.Id, prd.Name));
                }
            }
            return productOptionsCollection;
        }
    }
    
    public PageReference addAsset()
    {
        VirtualAssets.add(new VirtualAssetInfo(null, '', 1, VirtualAssets.size()));
        return null;
    }
    
    public PageReference removeAsset()
    {
        if(VirtualAssets.size() > 1)
        {
            String rmIndex = ApexPages.currentPage().getParameters().get('rmIndex');
            Integer index = Integer.valueOf(rmIndex);
            VirtualAssets.remove(index);
            for(Integer i = index + 1; i < VirtualAssets.size(); i++)
            {
                VirtualAssets[i].Index--;
            }
        }
        else
        {
            if(!isFromApex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'At least one asset is required.'));
            }
        }
        return null;
    }
    
    public PageReference save()
    {
       
        initVAManager();
        VAManager.nameRankSerial();
        if(saveAssets())
        {
            System.debug('Test Inside');
            Id contractId=CreateContractforServiceProviderPOC();
            VAManager.willEncryptLicenses();
            if(contractId!=null)
            {
                VAManager.AssignContractToPOCAssets(contractId);
            }
            SendFulfillmentEmailForEdgeConnect();
            SendFulfillmentEmailForServiceProviders();
            
            if(contractId!=null)
            {
                pocRequest.Contract_Number__c=contractId;
            }
            pocRequest.Trigger_POC_Email__c=true;
            update pocRequest;
            if(ApexPages.currentPage() != null)
            {
                if(!isFromApex)
                {
                    ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Succeeded. <script type="text/javascript">top.opener.location="/' + pocRequest.Id + '";window.setTimeout("top.close();", 2000);</script>');
                    ApexPages.addMessage(pageMsg);
                }
            }
        }
        return null;
    }
    // This method is called by AutomateVirtualPOCBatch
    public  List<Id> AutomaticFulfillmentVirtualPOC()
    {
        initVAManager();
        VAManager.nameRankSerial();
        
        if(saveAssets())
        {
            pocRequest.Trigger_POC_Email__c=true;
            update pocRequest;
            List<Id> licenseIds=VAManager.RetreiveLicenseIdsForAutomation();
            return licenseIds;
        }
        
        return null;
        
    }
    
    
    //helper methods for the trigger LeadToPOCAutomation to create POC
    public static Request__c createPOC(Id contactId, Lead lead, String model, String hypervisor, Opportunity opp)
    {
        Map<String, String> hypervisorMap = new Map<String, String> { 'S' => 'VMWare', 'V' => 'Microsoft Hyper V', 'X' => 'Citrix Xen', 'K' => 'KVM' };
            Request__c req = new Request__c();
        req.Opportunity__c = opp.Id;
        req.OwnerId = opp.OwnerId;
        req.Status__c = 'Open';
        req.Requested_Delivery_Date__c = Date.today();
        req.Estimated_Ship_Date__c = Date.today();
        req.Actual_Ship_Date__c = Date.today();
        req.POC_Contact__c = contactId;
        
        req.Evaluation_Product_1__c = model; 
        if(String.isNotBlank(hypervisor))
        {
            req.EvaluationProductHypervisor__c = hypervisorMap.get(hypervisor.toUpperCase());
        }
        
        Product2 product = getProduct(req.Evaluation_Product_1__c);
        Integer expirationDays = DEFAULT_LICENSE_DURATION_DAYS;
        if(product != null && product.NumberOfLicenses__c != null && product.NumberOfLicenses__c > 1)
        {
            //bundled products has 1 asset by default, others have 2
            req.Quantity_Location_1__c = 1;            
        }
        else
        {
            req.Quantity_Location_1__c = 2;        
        }
        if(req.Evaluation_Product_1__c == 'VX-AMI')
        {
            //VX-AMI product's qty should default to 1
            req.Quantity_Location_1__c = 1;
        }
        if(req.Evaluation_Product_1__c == 'GX-V')
        {
            //GX-V product's qty should default to 1
            expirationDays = 30;
            req.Quantity_Location_1__c = 1;
            req.Target_End_Date__c = Date.today().addDays(expirationDays);
        }
        
        req.Type__c = 'Evaluation';
        //req.Auto_Fulfill__c =  true;
        
        if(lead.Marketplace_Code__c != null && lead.Marketplace_Code__c != '' )
        {
            MarketplaceCode__c markplaceCode = MarketplaceCode__c.getInstance(lead.Marketplace_Code__c);
            if(markplaceCode != null)
            {
                try
                {
                    expirationDays = Integer.valueOf(markplaceCode.Length__c);
                }
                catch(Exception ex)
                {
                }
            }
        }
        req.Target_End_Date__c = Date.today().addDays(expirationDays);
        insert req;
        return req;
    }
    
    private Boolean saveAssets()
    {
        if(VAManager.updatesAssets())
        {
            pocRequest.Actual_Ship_Date__c = Date.today();
            pocRequest.Target_End_Date__c = Date.today().addDays(LicenseDurationDays);
            pocRequest.Status__c = 'Shipped';
            try
            {
                update pocRequest;
                return true;
            }
            catch(DmlException ex)
            {
                SilverPeakUtils.logException(ex);
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
        return false;
    }
    
    private void initVirtualAssetInfo()
    {
        VirtualAssets = new List<VirtualAssetInfo>();
        addProduct(pocRequest.Evaluation_Product_1__c, pocRequest.Quantity_Location_1__c);
        addProduct(pocRequest.Evaluation_Product_2__c, pocRequest.Quantity_Location_2__c);
        addProduct(pocRequest.VirtualProduct1__c, pocRequest.VirtualQuantity1__c);
        addProduct(pocRequest.VirtualProduct2__c, pocRequest.VirtualQuantity2__c);
        addProduct(pocRequest.VirtualProduct3__c, pocRequest.VirtualQuantity3__c);
        addProduct(pocRequest.VirtualProduct4__c, pocRequest.VirtualQuantity4__c);
        addProduct(pocRequest.VirtualProduct5__c, pocRequest.VirtualQuantity5__c);
        if(pocRequest.GMS_Needed__c == 'Virtual')
        {
            addProduct(VIRTUAL_PRODUCT_NAME, 1);
        }
       	if(pocRequest.Is_Unity_Cloud_Orchestrator__c)
        {
          addProduct('EC-ORCH-AAS-50-1Y', 1);
        }
        if(VirtualAssets.isEmpty())
        {
            addProduct(VIRTUAL_PRODUCT_NAME, 1);
        }
        
    }
    
    private void initVAManager()
    {
        VAManager = new VirtualAssetManager();
        for(VirtualAssetInfo va : VirtualAssets)
        {
            for(Integer i = 0; i < va.Quantity; i++)
            {
                Asset asset = new Asset(Product2Id = va.ProductId, Licenses_Nodes__c=va.LicensesNodes,Bandwidth_Nodes__c=va.BandwidthNodes, Quantity = 1, AccountId = pocRequest.Opportunity__r.AccountId, ContactId = pocRequest.POC_Contact__c, POCRequest__c = pocRequest.Id, Hosted_GMS__c = va.HostedGMS, GMS_Nodes__c = va.GMSNodes, Status = 'Customer Evaluation', Evaluation_Start_Date__c = Date.today(), Evaluation_End_Date__c = Date.today().addDays(LicenseDurationDays), Hypervisor__c=pocRequest.EvaluationProductHypervisor__c);
                if(va.ProductName == ('VX-AMI') )
                {
                    asset.Download_Source__c = 'VX-AMI';
                }
                if(IsECOrchestratorProduct(va.ProductId))
                {
                    asset.GMS_Nodes__c = '100000';
                }
                //License__c license = new License__c(Quantity__c = 1, Start_Date__c = Date.today(), License_Expiration__c = Date.today().addDays(LicenseDurationDays));
                VirtualAssetManager.VirtualAsset newVA = new VirtualAssetManager.VirtualAsset();
                newVA.Asset = asset;
                //newVA.License = license;
                VAManager.VirtualAssets.add(newVA);
            }
        }
    }
    private static boolean IsECOrchestratorProduct(Id productId)
    {
        List<Product2> lstProducts=  [select Name from Product2 where Id=:productId];
        if(lstProducts!=null && lstProducts.size()>0)
        {
            if(lstProducts[0].Name =='EC-ORCH')
                return true;
            else
                return false;
        }
        return false;
    }
    private void addProduct(String productName, Decimal qty)
    {
        System.debug('qty'+qty);
        if(productName != null)
        {
            if(qty == null)
            {
                qty = 1;
            }
            Product2 prd = getProduct(productName);
            if(prd != null)
            {
                VirtualAssets.add(new VirtualAssetInfo(prd.Id, productName, qty, VirtualAssets.size()));
            }
        }
    }
    
    private void SendFulfillmentEmailForEdgeConnect()
    {
        
        if(pocRequest!=null && pocRequest.POC_Type__c=='EdgeConnect')
        {
            List<EmailTemplate> template = [select Id from EmailTemplate where Name=:'EdgeConnect POC Virtual Fulfillment Email' limit 1];
            if(template.size() > 0)
            {
                List<String> ccs = getPOCRecipients(pocRequest.Id);
                ccs.add('notifications@silver-peak.com');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template[0].Id);
                email.setTargetObjectId(pocRequest.POC_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(pocRequest.Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email template cannot be found. Please contact system admin.'));
                
            }
            
        }
        
    }
    private void SendFulfillmentEmailForServiceProviders()
    {
        List<EmailTemplate> template =null;
        if(pocRequest.Opportunity__r.Account.ECSP__c)
        {
            if(pocRequest!=null && (pocRequest.POC_Type__c=='Perpetual'|| pocRequest.POC_Type__c=='Perpetual-Orchestrator SP'||pocRequest.POC_Type__c=='Term Based' ))
            {
                template = [select Id from EmailTemplate where Name=:'POC Perpetual Virtual Fulfillment Email' limit 1];
            }
            else if(pocRequest!=null && (pocRequest.POC_Type__c=='Metered'|| pocRequest.POC_Type__c=='Metered-Orchestrator SP'))
            {
                template = [select Id from EmailTemplate where Name=:'POC Metered Virtual Fulfillment Email' limit 1];
            }    
            if(template!=null && template.size() > 0)
            {
                List<String> ccs = getPOCRecipients(pocRequest.Id);
                ccs.add('notifications@silver-peak.com');
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTemplateId(template[0].Id);
                email.setTargetObjectId(pocRequest.POC_Contact__c);
                email.setCcAddresses(ccs);
                email.setWhatId(pocRequest.Id);
                email.setsaveAsActivity(false);
                Id orgWideEmail = SilverPeakUtils.getOrganizationWideEmailId('notifications@silver-peak.com');
                if(orgWideEmail != null)
                {
                    email.setOrgWideEmailAddressId(orgWideEmail);
                }
                Messaging.sendEmail(new List<Messaging.Email> {email}, true);
                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email template cannot be found. Please contact system admin.'));
                
            }
        }
        
    }
    
    private Id CreateContractforServiceProviderPOC()
    {
        if(pocRequest.Opportunity__r.Account.ECSP__c)
        {
            
            Contract conNumber= new Contract();
            conNumber.AccountId=pocRequest.Opportunity__r.AccountId;
            conNumber.Contract_Type__c='Evaluation';
            conNumber.Status='Draft';
            conNumber.StartDate=pocRequest.Actual_Ship_Date__c;
            conNumber.EndDate=pocRequest.Target_End_Date__c;
            insert conNumber;
            conNumber.Status='Activated';
            update conNumber;
            if(conNumber.Id!=null)
            {
                return conNumber.Id;
            }
        }
        return null;
    }
    
    private List<String> getAccountTeam(Id accId)
    {
        List<AccountTeamMember> members = [select Id, User.EMail from AccountTeamMember where AccountId=:accId and User.isActive=true];
        List<String> emails = new List<String>();
        for(AccountTeamMember atm : members)
        {
            emails.add(atm.User.Email);
        }
        return emails;
    }
    private List<String> getPOCRecipients(Id pocId)
    {
        List<Request__c> members = [select Id, SE__r.Email,SE_Manager__r.Email,RSM_Manager__r.Email,RSM__r.Email,CC_List_1__c,CC_List_2__c,CC_List_3__c,CC_List_4__c,CC_List_5__c from Request__c where Id=:pocId];
        List<String> emails = new List<String>();
        if(members!=null && members.size()>0)
        {
            if(members[0].SE__r.Email!=null)
            {
                emails.add(members[0].SE__r.Email);
            }
            if(members[0].SE_Manager__r.Email!=null)
            {
                emails.add(members[0].SE_Manager__r.Email);
            }
            if(members[0].RSM_Manager__r.Email!=null)
            {
                emails.add(members[0].RSM_Manager__r.Email);
            }
            if(members[0].RSM__r.Email!=null)
            {
                emails.add(members[0].RSM__r.Email);
            }
            if(members[0].CC_List_1__c!=null)
            {
                emails.add(members[0].CC_List_1__c);
            }
            if(members[0].CC_List_2__c!=null)
            {
                emails.add(members[0].CC_List_1__c);
            }
            if(members[0].CC_List_3__c!=null)
            {
                emails.add(members[0].CC_List_3__c);
            }
            if(members[0].CC_List_4__c!=null)
            {
                emails.add(members[0].CC_List_4__c);
            }
            if(members[0].CC_List_5__c!=null)
            {
                emails.add(members[0].CC_List_5__c);
            }
        }
        
        return emails;
    }
    //gets product with the specified name, if non found, match by model, if more than 1 found, return the one with shortest product code (subscription product has longer code)
    private static Product2 getProduct(String productName)
    {
        System.debug('productName'+productName);
        if(productName == 'VX-AMI')
        {
            return getProduct('VX-7000');
        }
        
        if(!productName.startsWith('EC'))
        {
            productName = productName.replaceAll('X ', 'X-');
        }
        Product2 productWithSameModel = null;
        for(Product2 product : [select Id, Name, Model__c, ProductCode, NumberOfLicenses__c from Product2 where Family = 'Virtual Image' and (Name=:productName or Model__c=:productName)])
        {
            if(product.Name == productName)
            {
                System.debug('product.Name'+product.Name);
                return product;
            }
            else if(product.Model__c == productName)
            {
                if(productWithSameModel == null || productWithSameModel.ProductCode.length() > product.ProductCode.length() || (productWithSameModel.ProductCode.length() == product.ProductCode.length() && productWithSameModel.Name.length() > product.Name.length()))
                {
                    productWithSameModel = product;
                }
            }
        }
        System.debug('productWithSameModel'+productWithSameModel);
        return productWithSameModel;
    }
    
    public class VirtualAssetInfo
    {
        public VirtualAssetInfo(String prdId, String prdName, Decimal qty, Integer index)
        {
            this.ProductId = prdId;
            this.ProductName = prdName;
            this.LicensesNodes = 0;
            this.BandwidthNodes = 0;
            this.HostedGMS = false;
            this.GMSNodes = '10';
            this.Index = index;
            if(prdName.startsWith('EC-') && !prdName.startsWith('EC-SP-') )
            {
                this.Quantity = 1;
            }
            else
            {
                this.Quantity = Integer.valueOf(qty);
            }
            
            if(prdName.startsWith('EC-BASE')|| prdName.startsWith('EC-PLUS'))
            {
                this.LicensesNodes = Integer.valueOf(qty);
            }
            
            if(prdName.startsWith('EC-BOOST'))
            {
                this.BandwidthNodes = Integer.valueOf(qty);
            }
            
        }
        
        public String ProductId { get; set; }
        public String ProductName { get; set; }
        public Integer Quantity { get; set; }
        public Boolean HostedGMS { get; set; }
        public String GMSNodes { get; set; }
        public Integer Index { get; set; }
        public integer LicensesNodes { get; set; } 
        public integer BandwidthNodes { get; set; }
    }
}