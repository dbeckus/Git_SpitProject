/*
* controller for CustomPOCRequest VF page.
*/
global with sharing class CustomPOCRequestController
{       
    private String requestId;
    
    public CustomPOCRequestController()
    {}
    
    public CustomPOCRequestController(ApexPages.StandardController controller)
    {
        IsEdit = false;        
        requestId = controller.getId(); 
        refreshPage=false;
        buildProductItems(requestId);  
        CreateECPOCVirtualProduct(requestId);
    }
    public Boolean refreshPage {get; set;}
    public Boolean IsEdit { get; set; }
    public Boolean ECSP { get; set; }
    public Boolean FirstPOC { get; set; }
    public Boolean HasContact { get; set; }
    public List<SelectOption> VirtualProductOptions
    {
        get
        {
            
            //return getPicklistItems(Request__c.VirtualProduct1__c.getDescribe());
            return GetPOCProduct(true,requestId);
        }
    }
    
    public Boolean DisableVirtualSection
    {
        get;set;
    }
    
    
    public string POCType
    {
        get;set;
    }
    public List<SelectOption> PhysicalProductOptions
    {
        get
        {
            //return getPicklistItems(Request__c.PhysicalProduct1__c.getDescribe());      
            return GetPOCProduct(false,requestId);
        }
    }    
    public List<SelectOption> CountryList 
    {
        get
        {
            return buildAllCountryList();
        }
    }
    
    public Request__c CurrentRequest { get; set; }
    public Decimal VirtualQuantity { get; set; }
    public List<PhysicalProductInfo> PhysicalProducts { get; set; }
    public List<VirtualProductInfo> VirtualProducts { get; set; }
    
    @RemoteAction
    global static List<CountryStateTable__c> getCountryStateList(String country)
    {
        return [select StateCode__c, StateName__c from CountryStateTable__c where Country__c=:country order by StateName__c];
    }        
    
    public PageReference savePage()
    {     
        SavePOCRequest(false);
        return null;
    }
    
    public void AutoSavePOCRequest()
    {
        SavePOCRequest(true);
    }
    public void SavePOCRequest(boolean isAutoSaveForEC)
    {
        
        cleanPOCRequest(CurrentRequest);
        Boolean isValid = validateValues();
        if(isValid)
        {
            
            CurrentRequest.VirtualQuantity1__c = VirtualQuantity == null ? 0 : VirtualQuantity;
            if (!PhysicalProducts.isEmpty()) 
            {
                for (Integer i = 0; i < PhysicalProducts.size() ; i++ ) {
                    if (i == 0) 
                    {
                        CurrentRequest.PhysicalProduct1__c = PhysicalProducts[0].ProductName;
                        CurrentRequest.PhysicalQuantity1__c = PhysicalProducts[0].Qty;
                        CurrentRequest.PhysicalLocation1__c = PhysicalProducts[0].composeLocation(); 
                        CurrentRequest.EndCustomerName1__c = PhysicalProducts[0].EndCustomerName;
                    }
                    else if(i == 1)
                    {
                        CurrentRequest.PhysicalProduct2__c = PhysicalProducts[1].ProductName;
                        CurrentRequest.PhysicalQuantity2__c = PhysicalProducts[1].Qty;
                        CurrentRequest.PhysicalLocation2__c = PhysicalProducts[1].composeLocation();
                        CurrentRequest.EndCustomerName2__c = PhysicalProducts[1].EndCustomerName;
                    }
                    else if (i == 2) 
                    {
                        CurrentRequest.PhysicalProduct3__c = PhysicalProducts[2].ProductName;
                        CurrentRequest.PhysicalQuantity3__c = PhysicalProducts[2].Qty;
                        CurrentRequest.PhysicalLocation3__c = PhysicalProducts[2].composeLocation();
                        CurrentRequest.EndCustomerName3__c = PhysicalProducts[2].EndCustomerName;
                    }
                    else if (i == 3) 
                    {
                        CurrentRequest.PhysicalProduct4__c = PhysicalProducts[3].ProductName;
                        CurrentRequest.PhysicalQuantity4__c = PhysicalProducts[3].Qty;
                        CurrentRequest.PhysicalLocation4__c = PhysicalProducts[3].composeLocation();
                        CurrentRequest.EndCustomerName4__c = PhysicalProducts[3].EndCustomerName;
                    }
                    else if (i == 4) 
                    {
                        CurrentRequest.PhysicalProduct5__c = PhysicalProducts[4].ProductName;
                        CurrentRequest.PhysicalQuantity5__c = PhysicalProducts[4].Qty;
                        CurrentRequest.PhysicalLocation5__c = PhysicalProducts[4].composeLocation();
                        CurrentRequest.EndCustomerName5__c = PhysicalProducts[4].EndCustomerName;
                    }
                    else {
                        //nothing to do
                    }
                }
            }
            if (!VirtualProducts.isEmpty()) 
            {
                for (Integer i = 0; i < VirtualProducts.size() ; i++ ) {
                    if (i == 0) 
                    {
                        CurrentRequest.VirtualProduct1__c = VirtualProducts[0].ProductName;
                        CurrentRequest.VirtualQuantity1__c = VirtualProducts[0].Qty;
                    }
                    else if(i == 1)
                    {
                        CurrentRequest.VirtualProduct2__c = VirtualProducts[1].ProductName;
                        CurrentRequest.VirtualQuantity2__c = VirtualProducts[1].Qty;
                    }
                    else if (i == 2) 
                    {
                        CurrentRequest.VirtualProduct3__c = VirtualProducts[2].ProductName;
                        CurrentRequest.VirtualQuantity3__c = VirtualProducts[2].Qty;
                    }
                    else if (i == 3) 
                    {
                        CurrentRequest.VirtualProduct4__c = VirtualProducts[3].ProductName;
                        CurrentRequest.VirtualQuantity4__c = VirtualProducts[3].Qty;
                    }
                    else if (i == 4) 
                    {
                        CurrentRequest.VirtualProduct5__c = VirtualProducts[4].ProductName;
                        CurrentRequest.VirtualQuantity5__c = VirtualProducts[4].Qty;
                    }
                    else {
                        //nothing to do
                    }
                }                 
            }
            if (PhysicalProducts.isEmpty() && !VirtualProducts.isEmpty()) 
            {
                CurrentRequest.Submission_Condition_Satisfied__c = true;
            }
            
            try
            {
                
                System.debug('Save Request '+ CurrentRequest.First_POC_on_Account__c);
                update CurrentRequest;
                FirstPOC=CurrentRequest.First_POC_on_Account__c;
                CreateECPOCVirtualProduct(CurrentRequest.Id);
                if(!isAutoSaveForEC)
                {
                    IsEdit = false;
                    refreshPage=true;
                }
                
                //return new PageReference('/apex/CustomPOCRequest?id=' + requestId);
                
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                
            }
        }
        
    }
    
    public void editPage()
    {
        IsEdit = true; 
        
    } 
    public PageReference cancelPage()
    {    
        IsEdit = false;
        buildProductItems(requestId);
        return new PageReference('/apex/CustomPOCRequest?id=' + requestId);
    }
    
    public void addPhysicalProduct()
    {
        IsEdit = true;
        if (PhysicalProducts.size() < 5) { 
            PhysicalProductInfo prod = new PhysicalProductInfo();
            prod.Qty = 1;
            prod.SiteLocation.ShippingContact.FirstName = CurrentRequest.POC_Contact__r.Firstname;
            prod.SiteLocation.ShippingContact.LastName = CurrentRequest.POC_Contact__r.Lastname;
            prod.SiteLocation.ShippingContact.Phone = CurrentRequest.POC_Contact__r.Phone;
            prod.SiteLocation.ShippingContact.Company = CurrentRequest.POC_Contact__r.Account.Name;
            prod.Index = PhysicalProducts.size();
            prod.SiteLocation.ShippingAddress.Country = 'United States';
            PhysicalProducts.add(prod);                
        }
        else
        {            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No more than 5 products allowed.'); 
            ApexPages.addMessage(myMsg);        
        }        
    }
    
    public void addVirtualProduct()
    {
        IsEdit = true;
        if (VirtualProducts.size() < 5) {
            VirtualProductInfo prod = new VirtualProductInfo(VirtualProducts.size(),'',1);            
            VirtualProducts.add(prod);                
        }
        else
        {            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,'No more than 5 products allowed.'); 
            ApexPages.addMessage(myMsg);        
        }  
    }
    
    public void removePhysicalProduct()
    {
        List<PhysicalProductInfo> updatedInfos = new List<PhysicalProductInfo>();
        Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        for(PhysicalProductInfo info : PhysicalProducts)
        {
            if (info.Index != index) 
            {
                updatedInfos.add(info);
            }
        }
        PhysicalProducts.clear();
        PhysicalProducts.addAll(updatedInfos);
    }    
    
    public void removeVirtualProduct()
    {
        List<VirtualProductInfo> updatedInfos = new List<VirtualProductInfo>();
        Integer index = Integer.valueOf(ApexPages.currentPage().getParameters().get('index'));
        for(VirtualProductInfo info : VirtualProducts)
        {
            if (info.Index != index) {
                updatedInfos.add(info);
            }
        }
        VirtualProducts.clear();
        VirtualProducts.addAll(updatedInfos);
    }    
    
    private void CreateECPOCVirtualProduct(string requestId)
    {
        //requestId
        Request__c pocRequest=[Select POC_Type__c,First_POC_on_Account__c,Opportunity__r.Account.ECSP__c from Request__c where Id=:requestId];
        POCType=pocRequest.POC_Type__c;
        ECSP=pocRequest.Opportunity__r.Account.ECSP__c;
        FirstPOC=pocRequest.First_POC_on_Account__c;
        if(pocRequest.POC_Type__c=='EdgeConnect')
        {
            
            DisableVirtualSection=true;
            boolean isProductsToBeAdded=ValidateECHasActiveLicensesorOpenPOCS(requestId,'EdgeConnect');
            if(VirtualProducts.size()==0 && !isProductsToBeAdded)
            {
                CurrentRequest.First_POC_on_Account__c=true;
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-BASE-1Y',10));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-PLUS-1Y',10));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-BOOST-1Y',100));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SAAS-1Y',1));
            }
            if(VirtualProducts.size()>0)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'EC-ORCH will be fulfilled automatically.'); 
                ApexPages.addMessage(myMsg);
            }
            
        }
        /* if(pocRequest.POC_Type__c=='Service Provider')
{

DisableVirtualSection=true;
boolean isProductsToBeAdded=ValidateECHasActiveLicensesorOpenPOCS(requestId,'Service Provider');
if(VirtualProducts.size()==0 && !isProductsToBeAdded)
{
CurrentRequest.First_POC_on_Account__c=true;
VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP',1));
}
if(VirtualProducts.size()>0)
{
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'EC-ORCH will be fulfilled automatically.'); 
ApexPages.addMessage(myMsg);
}

}*/
        if(pocRequest.POC_Type__c=='Perpetual'||pocRequest.POC_Type__c=='Perpetual-Orchestrator SP' )
        {
            DisableVirtualSection=true;
            boolean isProductsToBeAdded=ValidateECHasActiveLicensesorOpenPOCS(requestId,pocRequest.POC_Type__c);
            if(VirtualProducts.size()==0 && !isProductsToBeAdded)
            {
                CurrentRequest.First_POC_on_Account__c=true;
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP-50',5));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP-100',5));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP-200',5));
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP-1000',5));
            }
            if(!pocRequest.First_POC_on_Account__c)
            {
                DisableVirtualSection=false;
            } 
            if(pocRequest.POC_Type__c=='Perpetual')
            {
                if(VirtualProducts.size()>0)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'EC-ORCH will be fulfilled automatically.'); 
                    ApexPages.addMessage(myMsg);
                }
            }
            
        }
        if(pocRequest.POC_Type__c=='Metered'||pocRequest.POC_Type__c=='Metered-Orchestrator SP')
        {
            DisableVirtualSection=true;
            boolean isProductsToBeAdded=ValidateECHasActiveLicensesorOpenPOCS(requestId,pocRequest.POC_Type__c);
            if(VirtualProducts.size()==0 && !isProductsToBeAdded)
            {
                CurrentRequest.First_POC_on_Account__c=true;
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(),'EC-SP-MET',1));
            }
            if(!pocRequest.First_POC_on_Account__c)
            {
                DisableVirtualSection=false;
            }
            if(pocRequest.POC_Type__c=='Metered')
            {
                if(VirtualProducts.size()>0)
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'EC-ORCH will be fulfilled automatically.'); 
                    ApexPages.addMessage(myMsg);
                }
            }
            
        }
        
    }
    
    
    private boolean ValidateECHasActiveLicensesorOpenPOCS(string pocRequestId,string pocType)
    {
        Id acctId;
        Map<Id, string> mapProductExists= new Map<Id,string>();
        
        List<Opportunity> lstOpp=[Select Account.Id from Opportunity where Id In (Select Opportunity__c from Request__c where Id=:pocRequestId)];
        if(lstOpp!=null && lstOpp.size()>0 && lstOpp.size()==1)
        {
            acctId=lstOpp[0].Account.Id;
        }
        List<Request__c> lstRequest=[Select Id,VirtualProduct1__c from Request__c where POC_Type__c =:pocType and Opportunity__c in (Select Id from Opportunity where AccountId=:acctId)];
        if(lstRequest!=null && lstRequest.size()>0)
        {
            Set<Id> pocIds= new Set<Id>();
            for(Request__c item: lstRequest)
            {
                pocIds.add(item.Id);
                mapProductExists.put(item.Id,item.VirtualProduct1__c);
            }
            if(pocIds.contains(pocRequestId))
            {
                pocIds.remove(pocRequestId);
            }
            if(!ValidatePOCHasActiveECLicenses(pocIds))
            {
                if(ValidateECOpenPOCS(pocIds))
                {
                    if(mapProductExists.get(pocRequestId)==null || mapProductExists.get(pocRequestId)=='')
                    {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'There is already an open POC Request for this account with EC licenses.'); 
                        ApexPages.addMessage(myMsg);
                    }
                    return true;
                } 
                else
                {return false;} 
            }
            else
            {
                return true;
            }
        }
        
        return false;
    }
    
    
    private boolean ValidatePOCHasActiveECLicenses(Set<id> pocIds)
    {
        
        List<Asset> lstAsset=[Select Id from Asset where POCRequest__c in:pocIds and Product2.Family='Virtual Image' and status='Customer Evaluation'];
        if(lstAsset!=null && lstAsset.size()>0)
        {
            return true;
        }
        return false;
    }
    private boolean ValidateECOpenPOCS(Set<id> pocIds)
    {
        if(pocIds.size()>0)
        {
            List<Request__c> lstReq=[Select Id from Request__c where Id in:pocIds and status__c in('Open','Approved To Ship','Pending Approvals') ];
            if(lstReq!=null && lstReq.size()>0)
            {
                return true;
            }
        }
        return false;
    }
    /*
private boolean ValidateECBaseandHardwareProductNodesMatch()    
{
decimal sumOfHardwareQuantity =0;
decimal sumOfECBaseQuantity =0;

if(PhysicalProducts!=null && PhysicalProducts.size()>0)
{
for (Integer i = 0; i < PhysicalProducts.size() ; i++ ) 
{
sumOfHardwareQuantity =sumOfHardwareQuantity+ PhysicalProducts[i].Qty;
}
if(VirtualProducts!=null && VirtualProducts.size()>0)
{
for (Integer i = 0; i < VirtualProducts.size() ; i++ ) 
{
if(VirtualProducts[i].ProductName == 'EC-BASE-1Y')
{
sumOfECBaseQuantity =sumOfECBaseQuantity+ VirtualProducts[i].Qty;
}
}

}

if(sumOfECBaseQuantity<sumOfHardwareQuantity)
{
ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'EC Base licenses must be equal or exceed number of hardware units requested.'); 
ApexPages.addMessage(myMsg);
return false;    
}
}
return true;
}
*/
    private void buildProductItems(String requestId)
    {
        PhysicalProducts = new List<PhysicalProductInfo>(); 
        VirtualProducts = new List<VirtualProductInfo>();
        List<Request__c> requests = [select Id, Submission_Condition_Satisfied__c, POC_Contact__c, POC_Contact__r.Firstname, POC_Contact__r.Lastname, POC_Contact__r.Email, POC_Contact__r.Phone, POC_Contact__r.Account.Name, GMS_Needed__c,
                                     VirtualProduct1__c, VirtualProduct2__c, VirtualProduct3__c, VirtualProduct4__c, VirtualProduct5__c, 
                                     VirtualQuantity1__c, VirtualQuantity2__c, VirtualQuantity3__c, VirtualQuantity4__c, VirtualQuantity5__c,
                                     PhysicalProduct1__c, PhysicalProduct2__c, PhysicalProduct3__c, PhysicalProduct4__c, PhysicalProduct5__c,
                                     PhysicalQuantity1__c, PhysicalQuantity2__c, PhysicalQuantity3__c, PhysicalQuantity4__c, PhysicalQuantity5__c, 
                                     Ship_To_Location_1__c, PhysicalLocation1__c, PhysicalLocation2__c, PhysicalLocation3__c, PhysicalLocation4__c, PhysicalLocation5__c,
                                     EndCustomerName1__c, EndCustomerName2__c, EndCustomerName3__c, EndCustomerName4__c, EndCustomerName5__c,
                                     Status__c, Actual_Ship_Date__c, Target_End_Date__c,POC_Type__c,First_POC_on_Account__c  from Request__c where Id = :requestId];                                                               
        if(!requests.isEmpty())
        {
            
            CurrentRequest = requests[0];
            System.debug('First_POC_on_Account__c'+CurrentRequest.First_POC_on_Account__c);
            HasContact = CurrentRequest.POC_Contact__c == null ? false : true;            
            VirtualQuantity = CurrentRequest.VirtualQuantity1__c;
            
            //fill physical products.
            if(CurrentRequest.PhysicalProduct1__c != null && CurrentRequest.PhysicalProduct1__c != '')
            {
                PhysicalProducts.add(new PhysicalProductInfo(PhysicalProducts.size(), CurrentRequest.PhysicalProduct1__c, CurrentRequest.PhysicalQuantity1__c, CurrentRequest.PhysicalLocation1__c, CurrentRequest.EndCustomerName1__c));
            }
            if(CurrentRequest.PhysicalProduct2__c != null && CurrentRequest.PhysicalProduct2__c != '')
            {
                PhysicalProducts.add(new PhysicalProductInfo(PhysicalProducts.size(), CurrentRequest.PhysicalProduct2__c, CurrentRequest.PhysicalQuantity2__c, CurrentRequest.PhysicalLocation2__c, CurrentRequest.EndCustomerName2__c));
            }
            if(CurrentRequest.PhysicalProduct3__c != null && CurrentRequest.PhysicalProduct3__c != '')
            {
                PhysicalProducts.add(new PhysicalProductInfo(PhysicalProducts.size(), CurrentRequest.PhysicalProduct3__c, CurrentRequest.PhysicalQuantity3__c, CurrentRequest.PhysicalLocation3__c, CurrentRequest.EndCustomerName3__c));
            }
            if(CurrentRequest.PhysicalProduct4__c != null && CurrentRequest.PhysicalProduct4__c != '')
            {         
                PhysicalProducts.add(new PhysicalProductInfo(PhysicalProducts.size(), CurrentRequest.PhysicalProduct4__c, CurrentRequest.PhysicalQuantity4__c, CurrentRequest.PhysicalLocation4__c, CurrentRequest.EndCustomerName4__c));
            }
            if(CurrentRequest.PhysicalProduct5__c != null && CurrentRequest.PhysicalProduct5__c != '')
            {                              
                PhysicalProducts.add(new PhysicalProductInfo(PhysicalProducts.size(), CurrentRequest.PhysicalProduct5__c, CurrentRequest.PhysicalQuantity5__c, CurrentRequest.PhysicalLocation5__c, CurrentRequest.EndCustomerName5__c));
            }  
            
            //fill virtual product
            if(CurrentRequest.VirtualProduct1__c != null && CurrentRequest.VirtualProduct1__c != '')
            {
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(), CurrentRequest.VirtualProduct1__c, CurrentRequest.VirtualQuantity1__c));
            }
            if(CurrentRequest.VirtualProduct2__c != null && CurrentRequest.VirtualProduct2__c != '')
            {
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(), CurrentRequest.VirtualProduct2__c, CurrentRequest.VirtualQuantity2__c));
            }
            if(CurrentRequest.VirtualProduct3__c != null && CurrentRequest.VirtualProduct3__c != '')
            {
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(), CurrentRequest.VirtualProduct3__c, CurrentRequest.VirtualQuantity3__c));
            }
            if(CurrentRequest.VirtualProduct4__c != null && CurrentRequest.VirtualProduct4__c != '')
            {         
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(), CurrentRequest.VirtualProduct4__c, CurrentRequest.VirtualQuantity4__c));
            }
            if(CurrentRequest.VirtualProduct5__c != null && CurrentRequest.VirtualProduct5__c != '')
            {                              
                VirtualProducts.add(new VirtualProductInfo(VirtualProducts.size(), CurrentRequest.VirtualProduct5__c, CurrentRequest.VirtualQuantity5__c));
            }              
        }      
    }
    
    private List<SelectOption> buildAllCountryList()
    {
        List<SelectOption> allCountryList = new List<SelectOption>();
        allCountryList.add(new SelectOption('United States', 'United States'));
        for(CountryTable__c country : [select CountryName__c, IsEU__c from CountryTable__c where CountryName__c != 'United States' order by CountryName__c])
        {
            allCountryList.add(new SelectOption(String.valueOf(country.IsEU__c), country.CountryName__c));
        }
        return allCountryList;
    }
    
    private static List<SelectOption> getStateList(String country)
    {
        List<SelectOption> stateOptions = new List<SelectOption>();        
        for(CountryStateTable__c stateTable : [select StateCode__c, StateName__c from CountryStateTable__c where Country__c=:country order by StateName__c])        
        {
            stateOptions.add(new SelectOption(stateTable.StateCode__c, stateTable.StateName__c));
        }
        return stateOptions;
    }
    
    private static List<SelectOption> getPicklistItems(Schema.Describefieldresult picklistField)
    {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        List<Schema.PickListEntry> picklistEntries = picklistField.getPickListValues();
        for (Schema.PickListEntry entry : picklistEntries) 
        {
            result.add(new SelectOption(entry.getValue(), entry.getValue()));
        }
        return result;     
    }
    private static List<SelectOption> GetPOCProduct(boolean isVirtual, String requestId)
    {
        List<SelectOption> result = new List<SelectOption>();
        List<Product2> lstProducts = new List<Product2>();
        string productType='EC-SP-Metered';
        string productFamily= isVirtual?'Virtual Image':'Product';
        
        List<Request__c> requests = [select Id, POC_Type__c from Request__c where Id = :requestId];                                                               
        if(!requests.isEmpty())
        {
            Request__c currRequest = requests[0];
            if(productFamily=='Product' &&(currRequest.POC_Type__c == 'Metered'|| currRequest.POC_Type__c == 'Metered-Orchestrator SP'))
            {
                productType='EC-SP-Perpetual';
            }
            if(currRequest.POC_Type__c == 'EdgeConnect')// Fetch only EC products
            { 
                lstProducts= [Select Id,Name from Product2 where isActive=true and IsPocEnabled__c =true and Family=:productFamily and Product_Type__c='EDGECONNECT' order by Name];
            }
            /* else if(currRequest.POC_Type__c == 'Service Provider')// Fetch only EC products
{ 
lstProducts= [Select Id,Name from Product2 where isActive=true and IsPocEnabled__c =true and Family=:productFamily and Product_Type__c='EC-SP' order by Name];
}*/
            else if(currRequest.POC_Type__c == 'Perpetual'|| currRequest.POC_Type__c == 'Perpetual-Orchestrator SP')// Fetch only EC products
            { 
                lstProducts= [Select Id,Name from Product2 where isActive=true and IsPocEnabled__c =true and Family=:productFamily and Product_Type__c='EC-SP-Perpetual' order by Name];
            }
            else if(currRequest.POC_Type__c == 'Metered'|| currRequest.POC_Type__c == 'Metered-Orchestrator SP')// Fetch only EC products
            { 
                lstProducts= [Select Id,Name from Product2 where isActive=true and IsPocEnabled__c =true and Family=:productFamily and Product_Type__c=:productType order by Name];
            }
            else
            { 
                lstProducts= [Select Id,Name from Product2 where isActive=true and IsPocEnabled__c =true and Family=:productFamily and Product_Type__c='NX/VX' order by Product_Category__c,Name];
            }
        }
        
        result.add(new SelectOption('', '--None--'));
        for(Product2 prod : lstProducts) 
        {
            //result.add(new SelectOption(prod.Name.replace('-',' '), prod.Name.replace('-',' ')));
            result.add(new SelectOption(prod.Name,prod.Name));
        }
        
        return result;     
    }
    private boolean validateValues()
    {
        Boolean isValid = true;
        for(PhysicalProductInfo prod : PhysicalProducts)
        {
            if(!prod.validate())
            {
                isValid = false;
            }
        }
        for(VirtualProductInfo prod : VirtualProducts)
        {
            if(!prod.validate())
            {
                isValid = false;
            }
        }
        return isValid;
    }    
    
    private void cleanPOCRequest(Request__c request)
    {
        request.VirtualProduct1__c = null;
        request.VirtualProduct2__c = null;
        request.VirtualProduct3__c = null;
        request.VirtualProduct4__c = null;
        request.VirtualProduct5__c = null;        
        request.PhysicalProduct1__c = null;
        request.PhysicalProduct2__c = null;
        request.PhysicalProduct3__c = null;
        request.PhysicalProduct4__c = null;
        request.PhysicalProduct5__c = null;        
        
        request.VirtualQuantity1__c = 0;
        request.VirtualQuantity2__c = 0;
        request.VirtualQuantity3__c = 0;
        request.VirtualQuantity4__c = 0;
        request.VirtualQuantity5__c = 0;
        request.PhysicalQuantity1__c = 0;
        request.PhysicalQuantity2__c = 0;
        request.PhysicalQuantity3__c = 0;
        request.PhysicalQuantity4__c = 0;
        request.PhysicalQuantity5__c = 0;
        
        request.PhysicalLocation1__c = '';
        request.PhysicalLocation2__c = '';
        request.PhysicalLocation3__c = '';
        request.PhysicalLocation4__c = '';
        request.PhysicalLocation5__c = '';             
    }
    
    public class VirtualProductInfo
    {
        public VirtualProductInfo(Integer index, String name, Decimal qty)
        {
            this.Index = index;
            this.ProductName = name;
            this.Qty = qty;
        }
        
        public Integer Index { get; set; }
        public String ProductName { get; set; }
        public Decimal Qty { get; set; }
        
        public boolean validate()
        {
            boolean isValid = true;
            if(ProductName == '' || ProductName == null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must select a virtual product.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;                
            }
            if(Qty == null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input virtual product Qty.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;                
            }
            return isValid;
        }
    }
    public class PhysicalProductInfo
    {
        public PhysicalProductInfo()
        {            
            SiteLocation = new SiteLocationInfo();
        }
        
        public PhysicalProductInfo(Integer index, String prodName, Decimal qty, String location, String endName)
        {                    
            this.Index = index;
            this.ProductName = prodName;
            this.EndCustomerName = endName;
            this.Qty = qty;
            SiteLocation = new SiteLocationInfo(location);
        }
        
        public Integer Index { get; set; }
        public String ProductName { get; set; }        
        public String EndCustomerName { get; set; }        
        public Decimal Qty { get; set; }
        public SiteLocationInfo SiteLocation { get; set; }
        
        public String composeLocation()
        {   
            String address = SiteLocation.compose();
            while(address.endsWith('\r\n'))
            {
                address = address.subString(0, address.length() - 2);
            }
            return address;        
        }
        
        public Boolean validate()
        {
            Boolean isValid = true;
            if(ProductName == null || ProductName == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must select a physical product.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            if(Qty == null)
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input product quantity.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            
            //return isValid && SiteLocation.validate();  // validate all field.
            return isValid;  //just validate product name and qty.
        }
    }
    
    public class SiteLocationInfo
    {
        public SiteLocationInfo()
        {
            ShippingContact = new ContactInfo();
            DestinationContact = new ContactInfo();
            DestinationContact.HasPhone = false;
            DestinationContact.Phone = '***********';            
            ShippingAddress = new ShippingAddressInfo();            
            DestinationAddress = new DestinationAddressInfo();            
            VAT = new VatInfo();
        }
        
        public SiteLocationInfo(String locationStr)
        {
            this();
            String[] lines = locationStr.split('(\r\n)|\r|\n', 14);
            if (lines.size() == 14 || lines.size() == 11 || lines.size() == 10 || lines.size() == 7) 
            {        
                ShippingAddress.Street = (lines[0] == '*' ? '' : lines[0]);
                ShippingAddress.AdditionalStreet = (lines[1] == '*' ? '' : lines[1]); 
                
                String[] cityStateZipSplit = lines[2].split(',', 2);
                if(cityStateZipSplit.size() == 2)
                {
                    ShippingAddress.City = (cityStateZipSplit[0] == '*' ? '' : cityStateZipSplit[0]);
                    String[] stateZipSplit = cityStateZipSplit[1].trim().split(' ', 2);
                    ShippingAddress.State = stateZipSplit.size() == 2 ? (stateZipSplit[0] == '*' ? '' : stateZipSplit[0]) : stateZipSplit[0];
                    ShippingAddress.Code = stateZipSplit.size() == 2 ? (stateZipSplit[1] == '*' ? '' : stateZipSplit[1]) : stateZipSplit[0];
                    //ShippingAddress.Code = (stateZipSplit.size() == 2) ? stateZipSplit[1] : cityStateZipSplit[1];
                }
                else
                {
                    ShippingAddress.City = lines[2];
                }
                
                ShippingAddress.Country = lines[3];
                ShippingAddress.StateList = CustomPOCRequestController.getStateList(ShippingAddress.Country);
                ShippingContact = new ContactInfo(lines[4]);
                ShippingContact.Phone = lines[5] == '*' ? '' : lines[5];
                ShippingContact.Company = lines[6] == '*' ? '' : lines[6];
                if(lines.size() == 10 || lines.size() == 14)
                {            
                    DestinationAddress.Country = lines[7];
                    DestinationContact = new ContactInfo(lines[8]);
                    DestinationContact.HasPhone = false;            
                    DestinationContact.Phone = '***********';                    
                    DestinationContact.Company = lines[9] == '*' ? '' : lines[9];
                    DestinationAddress.IsFinalDestination = String.isNotEmpty(DestinationAddress.Country);
                }
                if(lines.size() == 11)
                {
                    VAT.VATId = lines[7] == '*' ? '' : lines[7];
                    VAT.VATCompany = lines[8] == '*' ? '' : lines[8];
                    VAT.VATAddress = lines[9] == '*' ? '' : lines[9].replace('||', '\r\n');
                    VAT.VATDisplayAddress = lines[9] == '*' ? '' : lines[9].replace('||','<br/>');
                    VAT.isEU = String.isNotEmpty(VAT.VATId) || String.isNotEmpty(VAT.VATAddress) || String.IsNotEmpty(VAT.VATCompany);                    
                }
                if(lines.size() == 14)
                {
                    VAT.VATId = lines[10] == '*' ? '' : lines[10];
                    VAT.VATCompany = lines[11] == '*' ? '' : lines[11];
                    VAT.VATAddress = lines[12] == '*' ? '' : lines[12].replace('||', '\r\n');
                    VAT.VATDisplayAddress = lines[12] == '*' ? '' : lines[12].replace('||','<br/>');
                    VAT.isEU = String.isNotEmpty(VAT.VATId) || String.isNotEmpty(VAT.VATAddress) || String.IsNotEmpty(VAT.VATCompany) || String.isNotEmpty(lines[13]);
                }
            }
            else
            {
                //wrong format
            }       
        }
        public ShippingAddressInfo ShippingAddress { get; set; }
        public ContactInfo ShippingContact { get; set; }
        public DestinationAddressInfo DestinationAddress { get; set; }
        public ContactInfo DestinationContact { get; set; }
        public VatInfo VAT { get; set; }
        
        public String compose()
        {
            String result = '';
            result += ShippingAddress.compose();
            result += ShippingContact.compose();            
            if(DestinationAddress.IsFinalDestination)
            {
                result += DestinationAddress.compose();
                result += DestinationContact.compose();            
            }
            else
            {
                DestinationContact.clear();                
            }            
            result += VAT.compose();
            return result;
        }
        
        public Boolean validate()
        {
            Boolean destinationValidateResult = DestinationAddress.IsFinalDestination == true ? DestinationAddress.validate() && DestinationContact.validate() : true;
            Boolean vatValidateResult = (VAT.IsEU == true ? VAT.validate() : true);
            return ShippingAddress.validate() && ShippingContact.validate() && destinationValidateResult && vatValidateResult;
        }
    }
    
    public class ContactInfo
    {
        public ContactInfo()
        {
            HasPhone = true;
        }
        
        public ContactInfo(String name)
        {
            this();
            if(String.isNotEmpty(name))
            {
                String[] nameSplit = name.split(' ', 2);
                FirstName = (nameSplit.size() == 2) ? (nameSplit[0] == '*' ? '' : nameSplit[0]) : '';
                LastName =  (nameSplit.size() == 2) ? (nameSplit[1] == '*' ? '' : nameSplit[1]) : nameSplit[0];
            }
        }
        
        public String Company { get; set; }
        public String Firstname { get; set; }
        public String Lastname { get; set; }        
        public String Phone { get; set; } 
        public Boolean HasPhone { get; set; }
        
        public String compose()
        {
            String result = (String.IsNotEmpty(FirstName) ? FirstName : '*') + ' ' + (String.IsNotEmpty(Lastname) ? Lastname : '*') + '\r\n';
            if (HasPhone) {
                result += (String.IsNotEmpty(Phone) ? Phone : '*') + '\r\n';
            }
            result += (String.IsNotEmpty(Company) ? Company : '*') + '\r\n';
            return result;
        }
        
        public Boolean validate()
        {
            Boolean isValid = true;
            if(Lastname == null || Lastname == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input lastname.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }    
            if(Phone == null || Phone == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input phone.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            if(Company == null || Company == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input company name.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            return isValid;
        }
        
        public void clear()
        {
            FirstName = '';
            LastName = '';
            Company = '';
        }
    }
    
    public class ShippingAddressInfo
    {
        public String Country { get; set; }    
        public String Street { get; set; }
        public String AdditionalStreet { get; set; }
        public String City { get; set; }
        public String State { get; set; }        
        public String Code { get; set; }
        public List<SelectOption> StateList { get; set; }
        
        
        public String compose()
        {
            String address = (String.IsNotEmpty(Street) ? Street : '*') + '\r\n';
            address += (String.IsNotEmpty(AdditionalStreet) ? AdditionalStreet : '') + '\r\n';
            address += (String.isNotEmpty(City) ? City : '*') + ', ' + (String.isNotEmpty(State) ? State : '*') + ' ' + (String.isNotEmpty(Code) ? Code : '*') + '\r\n';
            address += (String.isNotEmpty(Country) ? Country : '*') + '\r\n';
            return address;
        }
        
        public Boolean validate()
        {
            Boolean isValid = true;
            if(Street == null || Street == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input shipping street.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            if(City == null || City == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input shipping city.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }
            if(Code == null || Code == '')
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input zip code.'); 
                ApexPages.addMessage(myMsg);
                isValid = false;
            }        
            return isValid;
        }
    }
    
    public class DestinationAddressInfo
    {
        public DestinationAddressInfo()
        {
            IsFinalDestination = false;
            Country = 'United States';
        }
        
        public Boolean IsFinalDestination { get; set; }
        public String Country { get; set; }
        
        public String compose()
        {
            String result = '';
            if (IsFinalDestination) 
            {
                result += (String.IsNotEmpty(Country) ? Country : '*') + '\r\n';
            }
            else
            {
                //result += '\r\n';
            }
            return result;
        }
        
        public Boolean validate()
        {
            Boolean isValid = true;
            if(IsFinalDestination)
            {
                if (!String.IsNotEmpty(Country)) {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input destination country.'); 
                    ApexPages.addMessage(myMsg);
                    isValid = false;                    
                }                                   
            }
            return isValid;
        }
    }
    
    public class VatInfo
    {
        public VatInfo()
        {
            IsEU = false;
        }
        
        public Boolean IsEU { get; set; }
        public String VATId { get; set; }
        public String VATCompany { get; set; }
        public String VATAddress { get; set; }
        public String VATDisplayAddress { get; set; }        
        
        public String compose()
        {
            String result = '';
            if (IsEU) 
            {
                result += (VATId != '' ? VATId : '*') + '\r\n';
                result += (VATCompany != '' ? VATCompany : '*') + '\r\n';
                result += (VATAddress != '' ? VATAddress.replace('\r\n', '||') : '*') + '\r\nVATPLACEHOLDER';
                VATDisplayAddress = VATAddress.replace('\r\n', '<br/>'); //refresh display address.
            }
            return result;
        }
        
        public Boolean validate()
        {
            Boolean isValid = true;
            if (IsEU) 
            {
                if (VATId == '' || VATId == null) 
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input VAT Id.'); 
                    ApexPages.addMessage(myMsg);
                    isValid = false;  
                }
                if (VATCompany == '' || VATCompany == null) 
                {                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input VAT Company.'); 
                    ApexPages.addMessage(myMsg);
                    isValid = false;                     
                }
                if (VATAddress == '' || VATAddress == null) 
                {
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You must input VAT Address.'); 
                    ApexPages.addMessage(myMsg);
                    isValid = false;           
                }                        
            }
            return isValid;
        }
    }
    
    @isTest
    static void testPocRequest()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.PhysicalProduct1__c = 'Acme';
        request.PhysicalProduct2__c = 'Acme';
        request.PhysicalProduct3__c = 'Acme';
        request.PhysicalProduct4__c = 'Acme';
        request.PhysicalProduct5__c = 'Acme';
        request.PhysicalQuantity1__c = 0;
        request.PhysicalQuantity2__c = 0;
        request.PhysicalQuantity3__c = 0;
        request.PhysicalQuantity4__c = 0;
        request.PhysicalQuantity5__c = 0;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'Acme';
        request.VirtualProduct2__c = 'Acme';
        request.VirtualProduct3__c = 'Acme';
        request.VirtualProduct4__c = 'Acme';
        request.VirtualProduct5__c = 'Acme';
        request.VirtualQuantity1__c = 0;
        request.VirtualQuantity2__c = 0;
        request.VirtualQuantity3__c = 0;
        request.VirtualQuantity4__c = 0;
        request.VirtualQuantity5__c = 0;
        
        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        controller.addPhysicalProduct();
        ApexPages.currentPage().getParameters().put('index','1');
        ApexPages.currentPage().getParameters().put('country','United States');
        ApexPages.currentPage().getParameters().put('prodIndex','1');
        List<SelectOption> virtualOptions = controller.VirtualProductOptions;
        List<SelectOption> physicalOptions = controller.PhysicalProductOptions;
        List<SelectOption> countryList = controller.CountryList;
        List<CountryStateTable__c> countryStateTables = CustomPOCRequestController.getCountryStateList('acme');
        controller.removePhysicalProduct();
        controller.cancelPage();
        controller.addVirtualProduct();
        controller.removeVirtualProduct();
        controller.editPage();
    }
    @isTest
    static void testECPocRequestECBaseRatioWithHardware()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        insert request;
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalQuantity1__c = 2;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'EC-BASE-1Y';
        request.VirtualQuantity1__c = 1;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        try
        {
            controller.savePage();
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('EC Base licenses must be equal or exceed number of hardware units requested.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true); 
        }
        
        
        
    }  
    
    @isTest
    static void testECPocRequestECPOC_AutoPopulateVirtualProducts()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        
        insert opportunity;
        Test.startTest();
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        insert request;
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalQuantity1__c = 2;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        
        controller.savePage();
        Test.stopTest();
        Request__c updatedReq=[Select VirtualProduct1__c,VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c,VirtualQuantity4__c,VirtualQuantity5__c from Request__c where Id=:request.Id ];
        System.assertEquals(updatedReq.VirtualProduct1__c, 'EC-BASE-1Y');
        System.assertEquals(updatedReq.VirtualProduct2__c, 'EC-PLUS-1Y');
        System.assertEquals(updatedReq.VirtualProduct3__c, 'EC-BOOST-1Y'); 
        System.assertEquals(updatedReq.VirtualProduct4__c, 'EC-SAAS-1Y');
        System.assertEquals(updatedReq.VirtualQuantity1__c, 10);
        System.assertEquals(updatedReq.VirtualQuantity2__c, 10);
        System.assertEquals(updatedReq.VirtualQuantity3__c, 100); 
        System.assertEquals(updatedReq.VirtualQuantity4__c,1);
        
    }  
    @isTest
    static void testECPocRequestECPOC_AutoPopulateVirtualProducts_Perpetual()
    {
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        
        insert opportunity;
        Test.startTest();
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='Perpetual';
        request.Opportunity__c= opportunity.id;
        insert request;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        
        controller.savePage();
        Test.stopTest();
        Request__c updatedReq=[Select VirtualProduct1__c,VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c,VirtualQuantity4__c,VirtualQuantity5__c from Request__c where Id=:request.Id ];
        System.assertEquals(updatedReq.VirtualProduct1__c, 'EC-SP-50');
        System.assertEquals(updatedReq.VirtualProduct2__c, 'EC-SP-100');
        System.assertEquals(updatedReq.VirtualProduct3__c, 'EC-SP-200'); 
        System.assertEquals(updatedReq.VirtualProduct4__c, 'EC-SP-1000');
        System.assertEquals(updatedReq.VirtualQuantity1__c, 5);
        System.assertEquals(updatedReq.VirtualQuantity2__c, 5);
        System.assertEquals(updatedReq.VirtualQuantity3__c, 5); 
        System.assertEquals(updatedReq.VirtualQuantity4__c,5);
        
    }
    @isTest
    static void testECPocRequestECPOC_AutoPopulateVirtualProducts_Metered()
    {
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Metered',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        
        insert opportunity;
        Test.startTest();
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='Metered';
        request.Opportunity__c= opportunity.id;
        insert request;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        
        controller.savePage();
        Test.stopTest();
        Request__c updatedReq=[Select VirtualProduct1__c,VirtualProduct2__c,VirtualProduct3__c,VirtualProduct4__c,VirtualProduct5__c,VirtualQuantity1__c,VirtualQuantity2__c,VirtualQuantity3__c,VirtualQuantity4__c,VirtualQuantity5__c from Request__c where Id=:request.Id ];
        System.assertEquals(updatedReq.VirtualProduct1__c, 'EC-SP-MET');
        System.assertEquals(updatedReq.VirtualQuantity1__c, 1);
        
        
    } 
    
    @isTest
    static void testValidECProducts()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalQuantity1__c = 2;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'EC-BASE-1Y';
        request.VirtualQuantity1__c = 1;
        
        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        Request__C output= [Select Id,PhysicalProduct1__c,VirtualProduct1__c from Request__c where Id=:request.Id];
        System.assertEquals('EC-XS', output.PhysicalProduct1__c);
        
    }    
    
    
    @isTest
    static void testComposeLocation()
    {        
        PhysicalProductInfo product = new PhysicalProductInfo(0, 'Velocity', 1, 'street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER', '');
        product.SiteLocation.DestinationAddress.IsFinalDestination = true;
        product.SiteLocation.VAT.IsEU = true;
        String result = product.composeLocation();
        System.assertEquals('street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER', result);
        
        product.SiteLocation.DestinationAddress.IsFinalDestination = false;
        product.SiteLocation.VAT.IsEU = false;
        String result2 = product.composeLocation();
        System.assertEquals('street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany', result2);
        
        product.SiteLocation.DestinationAddress.IsFinalDestination = false;    
        product.SiteLocation.VAT.IsEU = true;
        String result3 = product.composeLocation();
        System.assertEquals('street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER', result3);
        
        PhysicalProductInfo product2 = new PhysicalProductInfo(0, 'Velocity', 1, 'street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER', '');
        product2.SiteLocation.DestinationAddress.IsFinalDestination = true;    
        product2.SiteLocation.VAT.IsEU = false;
        String result4 = product2.composeLocation();
        System.assertEquals('street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany', result4);
    }
    
    @isTest
    static void testShippingLocationInfo()
    {
        CustomPOCRequestController.SiteLocationInfo loc = new CustomPOCRequestController.SiteLocationInfo('street1\r\nstreet2\r\ncity, state 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER');
        System.assertEquals('company', loc.ShippingContact.Company);
        loc = new CustomPOCRequestController.SiteLocationInfo('street1\r\nstreet2\r\ncity, 000000\r\ncountry\r\nfirstname lastname\r\n12345678\r\ncompany\r\nfinalCountry\r\nfinalFirstname finalLastname\r\nfinalCompany\r\nvatId\r\nvatCompany\r\nvatAddress\r\nVATPLACEHOLDER');
        System.assertEquals('finalCompany', loc.DestinationContact.Company);
    }
}