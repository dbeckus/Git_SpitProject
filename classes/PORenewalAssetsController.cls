public class PORenewalAssetsController {
    public Purchase_Order__c PORequest{get;set;}
    public Purchase_Order__c CustomerContact{get;set;}
    public List<Asset> AssetList{get;set;}
    public License__c License { get; set; }
    public Asset SupportAsset { get; set; }
    public Asset RenewalAsset { get; set; }
    public boolean IsFromApex {get;set;}
    public String AssetTypeSelection{get; set;}
    public PORenewalAssetsController(ApexPages.StandardController controller)
    {
        
        if(AssetList==null)
        { AssetList= new List<Asset>();}
        
        if(RenewalAsset==null)
        { RenewalAsset= new Asset();}
         if(SupportAsset==null)
        { SupportAsset= new Asset();}
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
        else if(AssetTypeSelection=='2')
        {
            AssetList= RetreiveAssets(true);
        }
        else if(AssetTypeSelection=='3')
        {
            AssetList= RetreiveAssets(false);
        }
        return null;
        
    }
    public List<Asset> RetreiveAssets(boolean isEdgeConnect)
    {
        List<Asset> lstAssets=new List<Asset>();
        if(isEdgeConnect)
        {
            lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,Renewal_Nodes__c ,License_Expiration__c,Renewal_Start_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription','Conditional PO') and Product2.Family='Virtual Image' and Product2.Product_Type__c='EDGECONNECT'];
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
            if(AssetTypeSelection=='1')
            {
                lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,License_Expiration__c,Renewal_Nodes__c,Renewal_Start_Date__c  from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Subscription Active', 'Customer Subscription Expired','Customer Subscription') and Product2.Family='Virtual Image'  and  (NOT Product2.Name like'EC%')];
                for(Asset item: lstAssets)
                {
                    item.Renewal_Start_Date__c=Date.today();
                }
            }
            if(AssetTypeSelection=='3')
            {
                lstAssets =[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c,Service_Support_End_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,License_Expiration__c,Renewal_Nodes__c,Renewal_Start_Date__c  from Asset where AccountId =:PORequest.Opportunity__r.AccountId and  Status in('Customer Owned') and Product2.Product_Type__c in('EC-SP-Perpetual','EC-SP-TERM')];
                for(Asset item: lstAssets)
                {
                    item.Renewal_Start_Date__c=Date.today();
                }
            }
            
        }
        
        
        return lstAssets;
    }
    
    
    public PageReference SaveAssets()
    {
        boolean isSuccessful=false;
        
        List<Asset> assets= new List<Asset>();
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
                if(AssetTypeSelection=='2')
                {
                    item.Renewal_Start_Date__c=RenewalAsset.Renewal_Start_Date__c;
                    item.Renewal_Date__c=RenewalAsset.Renewal_Date__c;
                }
                System.debug('item.Renewal_Nodes__c'+item.Renewal_Nodes__c);
                if(item.Status=='Customer Subscription Expired')
                {
                    if(AssetTypeSelection=='1')
                    {
                        item.Status='Customer Subscription';
                    }
                    else if(AssetTypeSelection=='2')
                    {
                        item.Status='Customer Subscription Active';
                    }
                    else if(AssetTypeSelection=='3')
                    {
                        item.Status='Customer Owned';
                    }
                    
                }
            }
            if(AssetTypeSelection=='2')
            {
                if(assets.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        if(assets.size()>0)
                        {
                            RenewalAssetsHelper.CheckUnCheckAssets(assets, true);
                            RenewalAssetsHelper.SendEmailsForPurchaseOrder(true, PORequest,CustomerContact.Email_Contact__c); 
                            RenewalAssetsHelper.RenewEdgeConnectLicense(assets);
                        }
                       
                    }
                    catch(Exception ex)
                    {
                        Database.Rollback(sp);
                        ApexPages.addMessages(ex);
                        SilverPEakUtils.logException(ex);
                    }
                    if(assets.size()>0)
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(assets, false);
                        RenewalAssetsHelper.ClearRenewalDate(assets);
                    }
                }
            }
            if(AssetTypeSelection=='1')
            {
                if(assets.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(assets, true);
                        RenewalAssetsHelper.SendEmailsForPurchaseOrder(false, PORequest,CustomerContact.Email_Contact__c); 
                        RenewalAssetsHelper.CreateNewLicenses(assets);
                    }
                    catch(Exception ex)
                    {
                        Database.Rollback(sp);
                        ApexPages.addMessages(ex);
                        SilverPEakUtils.logException(ex);
                    }
                    finally
                    {
                       
                        if(assets.size()>0)
                        {
                            RenewalAssetsHelper.CheckUnCheckAssets(assets, false);
                            RenewalAssetsHelper.ClearRenewalDate(assets);
                        }
                    }      
                    
                }
            }
             if(AssetTypeSelection=='3')
            {
                if(assets.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        update assets;
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
                            RenewalAssetsHelper.SendEmailsForServiceProviderPO(PORequest,CustomerContact.Email_Contact__c);    
                        }
                        if(assets.size()>0)
                        {
                            RenewalAssetsHelper.CheckUnCheckAssets(assets, false);
                           
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