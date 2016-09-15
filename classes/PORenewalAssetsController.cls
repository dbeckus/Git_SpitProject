public class PORenewalAssetsController {
    public Purchase_Order__c PORequest{get;set;}
    public Purchase_Order__c CustomerContact{get;set;}
    public List<Asset> AssetList{get;set;}
    public License__c License { get; set; }
    public Asset RenewalAsset { get; set; }
    public boolean IsFromApex {get;set;}
    public String AssetTypeSelection{get; set;}
    public PORenewalAssetsController(ApexPages.StandardController controller)
    {
        
        if(AssetList==null)
        { AssetList= new List<Asset>();}
        
         if(RenewalAsset==null)
        { RenewalAsset= new Asset();}
        License= new License__c();
        CustomerContact = new Purchase_Order__c();
        List<Purchase_Order__c> requests = [select Id, Opportunity__c, Opportunity__r.AccountId,Email_Contact__c from Purchase_Order__c where Id = :controller.getId()];        
        if(!requests.isEmpty())
        {
            AssetTypeSelection='1';
            PORequest = requests[0];
            AssetList= RetreiveAssets(false);
            
        }
        IsFromApex=false;
        
        
    }
    public PageReference ResetFilter()
    {
        if(AssetTypeSelection=='1')
        {
           
            AssetList= RetreiveAssets(false);
        }
        else
        {
            
            AssetList= RetreiveAssets(true);
        }
        return null;
        
    }
    public List<Asset> RetreiveAssets(boolean isEdgeConnect)
    {
        List<Asset> lstAssets=new List<Asset>();
        if(isEdgeConnect)
        {
            lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,Renewal_Nodes__c ,License_Expiration__c,Renewal_Start_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription') and Product2.Family='Virtual Image' and Product2.Name like'EC%' and (NOT Product2.Name='EC-ORCH')];
            for(Asset item: lstAssets)
            {
                string prodName=item.Product2.Name;
                System.debug('Renewal Nodes'+item.Renewal_Nodes__c);
                if(item.Renewal_Nodes__c==null || item.Renewal_Nodes__c==0)
                {
                    item.Renewal_Nodes__c=0;
                    if(prodName.startsWith('EC-BASE') || prodName.startsWith('EC-PLUS'))
                    {
                        item.Renewal_Nodes__c=item.Licenses_Nodes__c;
                    }
                    if(prodName.startsWith('EC-BOOST'))
                    {
                        item.Renewal_Nodes__c=item.Bandwidth_Nodes__c;
                    }
                }
                if(item.Renewal_Start_Date__c==null)
                {
                    item.Renewal_Start_Date__c=Date.today();
                }
                
            }
        }
        else
        {
            lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,License_Expiration__c,Renewal_Nodes__c,Renewal_Start_Date__c  from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription') and Product2.Family='Virtual Image'  and  (NOT Product2.Name like'EC%')];
            for(Asset item: lstAssets)
            {
                item.Renewal_Start_Date__c=Date.today();
            }
        }
        
        
        return lstAssets;
    }
    
    
    public PageReference SaveAssets()
    {
        boolean isSuccessful=false;
        
        List<Asset> assets= new List<Asset>();
        List<Asset> lstAssetToUpdateToday= new List<Asset>();
        List<Asset> lstAssetToUpdateLater= new List<Asset>();
        //List<Asset> ecOrchAsset= new List<Asset>();
        for(Asset item: AssetList)
        {
            if(item.Is_Selected_For_Renewal__c)
            {
                assets.add(item);
            }
        }
        if(ValidateAssets(assets))
        {
            for(Asset item: assets)
            {
                decimal originalNodes=0;
                string prodName=item.Product2.Name;
                item.Renewal_Start_Date__c=RenewalAsset.Renewal_Start_Date__c;
                item.Renewal_Date__c=RenewalAsset.Renewal_Date__c;
                if(prodName.startsWith('EC-BASE') || prodName.startsWith('EC-PLUS'))
                {
                    originalNodes =item.Licenses_Nodes__c;
                }
                if(prodName.startsWith('EC-BOOST'))
                {
                    originalNodes =item.Bandwidth_Nodes__c;
                }
                if(item.Renewal_Nodes__c==originalNodes || AssetTypeSelection=='1' )
                {
                    lstAssetToUpdateToday.add(item);
                }
                else
                {
                    lstAssetToUpdateLater.add(item);
                }
            }
            if(AssetTypeSelection=='2')
            {
                
                if(assets.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        if(lstAssetToUpdateToday.size()>0)
                        {
                            RenewalAssetsHelper.CheckUnCheckAssets(lstAssetToUpdateToday, true);
                            RenewalAssetsHelper.RenewEdgeConnectLicense(lstAssetToUpdateToday);
                            RenewalAssetsHelper.UpdateAssetStatus(lstAssetToUpdateToday, AssetTypeSelection);
                        }
                        if(lstAssetToUpdateLater.size()>0)
                        {
                            RenewalAssetsHelper.RenewEdgeConnectLicense(lstAssetToUpdateLater);
                            RenewalAssetsHelper.UpdateAssetStatus(lstAssetToUpdateLater, AssetTypeSelection);
                            update lstAssetToUpdateLater;
                        }
                        isSuccessful=true;
                    }
                    catch(Exception ex)
                    {
                        Database.Rollback(sp);
                        ApexPages.addMessages(ex);
                        SilverPEakUtils.logException(ex);
                    }
                    
                    if(isSuccessful)
                    {
                        RenewalAssetsHelper.SendEmailsForPurchaseOrder(true, PORequest,CustomerContact.Email_Contact__c);    
                    }
                    if(lstAssetToUpdateToday.size()>0)
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(lstAssetToUpdateToday, false);
                        RenewalAssetsHelper.ClearRenewalDate(lstAssetToUpdateToday);
                    }
                    if(lstAssetToUpdateLater.size()>0)
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(lstAssetToUpdateLater, false);
                    }
                    
                    
                    
                }
            }
            if(AssetTypeSelection=='1')
            {
                if(lstAssetToUpdateToday.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(lstAssetToUpdateToday, true);
                        RenewalAssetsHelper.CreateNewLicenses(lstAssetToUpdateToday);
                        RenewalAssetsHelper.UpdateAssetStatus(lstAssetToUpdateToday, AssetTypeSelection);
                        isSuccessful=true;
                    }
                    catch(Exception ex)
                    {
                        Database.Rollback(sp);
                        ApexPages.addMessages(ex);
                        SilverPEakUtils.logException(ex);
                    }
                    finally
                    {
                        if(isSuccessful)
                        {
                            RenewalAssetsHelper.SendEmailsForPurchaseOrder(false, PORequest,CustomerContact.Email_Contact__c);    
                        }
                        if(lstAssetToUpdateToday.size()>0)
                        {
                            RenewalAssetsHelper.CheckUnCheckAssets(lstAssetToUpdateToday, false);
                            RenewalAssetsHelper.ClearRenewalDate(lstAssetToUpdateToday);
                        }
                    }      
                    
                }
            }
            
            if(ApexPages.currentPage() != null)
            {
                if(!isFromApex)
                {
                    ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Succeeded. <script type="text/javascript">top.opener.location="/' + PORequest.Id + '";window.setTimeout("top.close();", 2000);</script>');
                    ApexPages.addMessage(pageMsg);
                }
                
            }
        }
        return null;
    }
    
    private  boolean ValidateAssets(List<Asset> lstAssets)
    {
        Set<string> lstDateIssue= new Set<string>();
        Set<string> lstNodesIssue= new Set<string>(); 
        if(lstAssets.size()==0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select records.'));
            return false;
        }
        if(lstAssets.size()>0)
        {
            if(AssetTypeSelection=='2')
            {
                // Check the renewal start dates and end dates are not blank
                // Check the renewal end dates is not less than start Date.
                // 
                if(RenewalAsset.Renewal_Start_Date__c== null || RenewalAsset.Renewal_Date__c== null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Renewal Dates are empty.\n'));
                    return false;
                }
                if(RenewalAsset.Renewal_Start_Date__c!= null && RenewalAsset.Renewal_Date__c!= null)
                {
                    if(RenewalAsset.Renewal_Date__c< RenewalAsset.Renewal_Start_Date__c)
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'End date is less than start date.\n'));
                        return false;
                    }
                }
                for(Asset item:lstAssets)
                {
                    
                    if(item.Renewal_Nodes__c==null)
                    {
                        lstNodesIssue.add(item.Name);
                    }
                }
                
                if(lstNodesIssue.size()>0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Updated Nodes cannot be empty for the selected Assets.\n'+ lstNodesIssue));
                    
                }
                if(lstNodesIssue.size()>0)
                {
                    return false;
                }
            }
            if(AssetTypeSelection=='1')
            {
                // Check the renewal start dates and end dates are not blank
                // Check the renewal end dates is not less than start Date.
                for(Asset item:lstAssets)
                {
                    if(item.Renewal_Date__c== null)
                    {
                        lstDateIssue.add(item.Name);
                    }
                }
                if(lstDateIssue.size()>0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Renewal End Date cannot be blank.\n'+ lstDateIssue));
                    
                }
                if(lstDateIssue.size()>0 || lstNodesIssue.size()>0)
                {
                    return false;
                }
            }
        }
        return true;
        
    }
    
}