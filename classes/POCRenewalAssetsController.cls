public class POCRenewalAssetsController {
    public Request__c POCRequest{get;set;}
    public List<Asset> AssetList{get;set;}
    public License__c License { get; set; }
    public boolean IsFromApex {get;set;}
    
    public POCRenewalAssetsController(ApexPages.StandardController controller)
    {
        
        if(AssetList==null)
        { AssetList= new List<Asset>();}
        License= new License__c();
        
        List<Request__c> requests = [select Id, Opportunity__c, Opportunity__r.AccountId,POC_Type__c, POC_Contact__c, GMS_Needed__c, EvaluationProductHypervisor__c, Evaluation_Product_1__c, Evaluation_Product_2__c, Quantity_Location_1__c, Quantity_Location_2__c, Status__c, Actual_Ship_Date__c, Target_End_Date__c, VirtualProduct1__c, VirtualProduct2__c, VirtualProduct3__c, VirtualProduct4__c, VirtualProduct5__c, VirtualQuantity1__c, VirtualQuantity2__c, VirtualQuantity3__c, VirtualQuantity4__c, VirtualQuantity5__c from Request__c where Id = :controller.getId()];        
        if(!requests.isEmpty())
        {
            POCRequest = requests[0];
            AssetList= RetreiveAssets();
            License.License_Expiration__c = POCRequest.Target_End_Date__c;
            
        }
        IsFromApex=false;
        
    }
    
    
    
    private List<Asset> RetreiveAssets()
    {
        List<Asset> lstAssets=[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Renewal_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c,Renewal_Nodes__c from Asset where POCRequest__c=:POCRequest.Id and Product2.Family='Virtual Image'];
        return lstAssets;
    }
    
    
    public PageReference SaveAssets()
    {
        SavePoint sp= Database.setSavepoint();
        try
        {
            List<Asset> ecOrchAsset= new List<Asset>();
            List<Asset> assets= new List<Asset>();
            if(POCRequest.POC_Type__c=='EdgeConnect')
            {
                
                
                for(Asset item: AssetList)
                {
                    item.Renewal_Date__c= License.License_Expiration__c;
                    if(item.Product2.Name.startsWith('EC-BASE')||item.Product2.Name.startsWith('EC-PLUS'))
                    {
                        item.Renewal_Nodes__c=item.Licenses_Nodes__c;
                    }
                    if(item.Product2.Name.startsWith('EC-BOOST'))
                    {
                        item.Renewal_Nodes__c= item.Bandwidth_Nodes__c;
                    }
                    if(item.Product2.Name=='EC-ORCH')
                    {
                        ecOrchAsset.add(item);
                    }
                    else
                    {assets.add(item);}
                }
                RenewalAssetsHelper.RenewEdgeConnectLicense(assets);
                RenewalAssetsHelper.CreateNewLicenses(ecOrchAsset);
            }
            if(POCRequest.POC_Type__c=='WAN Op')
            {
                for(Asset item: AssetList)
                {
                    item.Renewal_Date__c= License.License_Expiration__c;
                }
                RenewalAssetsHelper.CreateNewLicenses(AssetList);
            }
            // Send Email to POC Request.
            RenewalAssetsHelper.SendEmailsForPOCRequest(POCRequest);
            RenewalAssetsHelper.ClearRenewalDate(assets);
            RenewalAssetsHelper.ClearRenewalDate(ecOrchAsset);
            AssetList= RetreiveAssets();
            if(ApexPages.currentPage() != null)
            {
                if(!isFromApex)
                {
                    ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Succeeded. <script type="text/javascript">top.opener.location="/' + POCRequest.Id + '";window.setTimeout("top.close();", 2000);</script>');
                    ApexPages.addMessage(pageMsg);
                }
                
            }
        }
        catch(Exception ex)
        {
            Database.Rollback(sp);
            ApexPages.addMessages(ex);
            SilverPEakUtils.logException(ex);
        }
        return null;
        
    }
    
    
}