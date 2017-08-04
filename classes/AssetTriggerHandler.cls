public class AssetTriggerHandler implements ITriggerHandler {
    Id silverpeakSystemsId='00130000007mEjX';// production Id
    Set<Id> lstHWCPAccount {get;set;} //Provision Decommission Account
    Set<Id> lstSWCPAccount {get;set;} //Provision Decommission Account
    Set<Id> lstTACAccount {get;set;}//ActiveAssetCount
    Map<Id,Account> lstCustomerDateAccount {get;set;} // Customer Date Account
    
    
    public AssetTriggerHandler()
    {
        if(!SilverPeakUtils.IsProduction())
        {
            List<Account> spAccount=[select Id from Account where Name='Silver Peak Systems'];
            System.debug('SilverPeakId'+ spAccount );
            if(spAccount!=null)
            {
                silverpeakSystemsId=spAccount[0].Id;
            }
        }
        lstHWCPAccount= new Set<Id>();
        lstSWCPAccount= new Set<Id>();
        lstTACAccount= new Set<Id>();
        lstCustomerDateAccount= new Map<Id,Account>();
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        Map<Id,Account> cloudPortalAccs= new Map<Id,Account>();
        List<Asset> lstAsset= new List<Asset>();
        if(newItems!=null && newItems.size()>0)
        {
            List<Asset> lstNewAssets=(List<Asset>)newItems;
            for(Asset newAsset:lstNewAssets)
            {
                if(newAsset.End_of_Maintenance__c== null)
                {
                    lstAsset.add(newAsset);
                }
                //provision asset
                System.debug('silverpeakSystemsId'+silverpeakSystemsId);
                if(newAsset.AccountId!=silverpeakSystemsId && (newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Product')
                {
                    if(newAsset.status !='Silver Peak Inventory' && newAsset.status !='Write-Off'&& newAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                    { 
                        newAsset.Cloud_Portal_Sync_Status__c='Pending';
                        newAsset.Sync_With_Cloud_Portal__c=true;
                        if(!lstHWCPAccount.contains(newAsset.AccountId))
                        {
                            lstHWCPAccount.add(newAsset.AccountId);
                        }
                    }
                }
            }
            UpdateEOMDate(lstAsset);
            MakeFinalUpdateToAccount();
        }
        
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        List<Asset> lstAsset= new List<Asset>();
        Map<Id,Account> cloudPortalAccs= new Map<Id,Account>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id assetId:newItems.keyset())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                Asset oldAsset=(Asset)oldItems.get(assetId);
                if(oldAsset.Ship_Date__c!=newAsset.Ship_Date__c)
                {
                    lstAsset.add(newAsset);
                }
                //decommission asset
                if(newAsset.AccountId == silverpeakSystemsId && oldAsset.AccountId != newAsset.AccountId)
                {
                    if(oldAsset.AccountId!=null)
                    {
                        if(!lstHWCPAccount.contains(oldAsset.AccountId))
                        {
                            lstHWCPAccount.add(oldAsset.AccountId);
                        }
                    }
                } 
                //provision an existing asset to another account
                if(oldAsset.AccountId != newAsset.AccountId && oldAsset.AccountId == silverpeakSystemsId && oldAsset.Status =='Silver Peak Inventory')
                {
                    if(newAsset.AccountId!=null && (newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual'|| newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Product')
                    {
                        if(newAsset.status !='Silver Peak Inventory' && newAsset.status !='Write-Off'&& newAsset.status !='Obsolete RMA Unit–Supp Transferred–WO')
                        { 
                            newAsset.Cloud_Portal_Sync_Status__c='Pending';
                            newAsset.Sync_With_Cloud_Portal__c=true;
                            if(!lstHWCPAccount.contains(newAsset.AccountId))
                            {
                                lstHWCPAccount.add(newAsset.AccountId);
                            }
                        }
                    }
                }
            }
            UpdateEOMDate(lstAsset);
            MakeFinalUpdateToAccount();
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
        if(oldItems.size()>0)
        {
            for(Id assetId:oldItems.keySet())
            {
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
        Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
        Set<Id> setAccIds=new Set<Id>();
        Set<Id> setECAcctIds= new Set<Id>();
        Set<Id> setWanOpAcctIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset newAsset= (Asset)newItems.get(assetId);
                if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Product_Family__c=='Product' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Owned'))
                {
                    hardwareECAssetIds.put(newAsset.Id,newAsset);
                    setAccIds.add(newAsset.AccountId);
                }
                if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Model__c.startsWith('EC-BASE' ) && newAsset.Product_Family__c=='Virtual Image' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Subscription Active'))
                {
                    softwareECBaseAssetIds.put(newAsset.Id,newAsset);
                    setAccIds.add(newAsset.AccountId);
                }
                if(newAsset.AccountId!=null && newAsset.Status!='Customer Evaluation' && !newAsset.Trigger_Asset_Count_Status_on_Account__c)
                {
                    if(!lstTACAccount.contains(newAsset.AccountId))
                    {
                        lstTACAccount.add(newAsset.AccountId);
                    }
                }
                if(newAsset.AccountId!=null && newAsset.Status!='Customer Evaluation' && newAsset.Ship_Date__c!=null)
                {
                    if(((newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual' || newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Virtual Image' ) || newAsset.Product_Quote_Type__c=='NX/VX' )
                    { 
                        if(newAsset.Product_Quote_Type__c=='NX/VX' && (newAsset.Wan_Op_Customer_Date__c ==null ||  (newAsset.Wan_Op_Customer_Date__c!=null && newAsset.Ship_Date__c < newAsset.Wan_Op_Customer_Date__c)))
                            setWanOpAcctIds.add(newAsset.AccountId);
                        else if((newAsset.EC_Customer_Date__c ==null ||  (newAsset.EC_Customer_Date__c!=null && newAsset.Ship_Date__c < newAsset.EC_Customer_Date__c)))
                            setECAcctIds.add(newAsset.AccountId); 
                    }
                }
            }
            lstCustomerDateAccount=AssetHelper.CalculateCustomerDate(setECAcctIds, setWanOpAcctIds);
            AddActiveECBaseLicense(hardwareECAssetIds,softwareECBaseAssetIds,setAccIds);
            MakeFinalUpdateToAccount();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        Map<Id,Asset> hardwareECAssetIds= new  Map<Id,Asset>();
        Map<Id,Asset> softwareECBaseAssetIds= new  Map<Id,Asset>();
        Set<Id> setAccIds=new Set<Id>();
        Set<Id> setECAcctIds= new Set<Id>();
        Set<Id> setWanOpAcctIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                Asset oldAsset=(Asset)oldItems.get(assetId);
                if(oldAsset.AccountId!=newAsset.AccountId || oldAsset.Status!=newAsset.Status)
                {
                    if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Product_Family__c=='Product' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Owned'))
                    {
                        hardwareECAssetIds.put(newAsset.Id,newAsset);
                        setAccIds.add(newAsset.AccountId);
                    }
                    
                    if(newAsset.Product_Quote_Type__c=='EDGECONNECT' && newAsset.Model__c.startsWith('EC-BASE' )&& newAsset.Product_Family__c=='Virtual Image' && (newAsset.Status=='Customer Evaluation' || newAsset.Status=='Customer Subscription Active'))
                    {
                        softwareECBaseAssetIds.put(newAsset.Id,newAsset);
                        setAccIds.add(newAsset.AccountId);
                    }
                    if(newAsset.Status!='Customer Evaluation' )
                    {
                        if(oldAsset.Contract_Number__c != newAsset.Contract_Number__c || oldAsset.Status != newAsset.Status)
                        {
                            if(newAsset.AccountId != null && !lstTACAccount.contains(newAsset.AccountId))
                            {
                                lstTACAccount.add(newAsset.AccountId);
                            }
                           
                        }
                        if(oldAsset.AccountId!=newAsset.AccountId )
                        {
                            if( newAsset.AccountId != null && !lstTACAccount.contains(newAsset.AccountId))
                            {
                                lstTACAccount.add(newAsset.AccountId);
                            }
                            if( oldAsset.AccountId != null && !lstTACAccount.contains(oldAsset.AccountId))
                            {
                                lstTACAccount.add(oldAsset.AccountId);
                            }
                        }
                        if(oldAsset.Ship_Date__c!=newAsset.Ship_Date__c)
                        {
                            if(((newAsset.Product_Quote_Type__c=='EDGECONNECT'|| newAsset.Product_Quote_Type__c=='EC-SP-Perpetual' || newAsset.Product_Quote_Type__c=='EC-SP-Metered') && newAsset.Product_Family__c=='Virtual Image' ) || newAsset.Product_Quote_Type__c=='NX/VX' )
                            {
                                if(newAsset.Product_Quote_Type__c=='NX/VX' && (newAsset.Wan_Op_Customer_Date__c ==null ||  (newAsset.Wan_Op_Customer_Date__c!=null && newAsset.Ship_Date__c < newAsset.Wan_Op_Customer_Date__c)))
                                    setWanOpAcctIds.add(newAsset.AccountId);
                                else if((newAsset.EC_Customer_Date__c ==null ||  (newAsset.EC_Customer_Date__c!=null && newAsset.Ship_Date__c < newAsset.EC_Customer_Date__c)))
                                    setECAcctIds.add(newAsset.AccountId); 
                            }
                        } 
                    } 
                } 
                
            }
            lstCustomerDateAccount=AssetHelper.CalculateCustomerDate(setECAcctIds, setWanOpAcctIds);
            AddActiveECBaseLicense(hardwareECAssetIds,softwareECBaseAssetIds,setAccIds);
            MakeFinalUpdateToAccount();
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        Map<Id,Account> lstCPAcctIds= new Map<Id,Account>();
        for(Id assetId : oldItems.keySet())
        {
            Asset oldAsset=(Asset)oldItems.get(assetId);
            if(oldAsset.Status=='Customer Evaluation' && oldAsset.Model__c.startsWith('EC') && oldAsset.Product_Family__c=='Virtual Image')
            {
                if(!lstSWCPAccount.contains(oldAsset.AccountId))
                {
                    lstSWCPAccount.add(oldAsset.Id);
                }
            }  
            if(oldAsset.AccountId!=null && oldAsset.Status!='Customer Evaluation' && !oldAsset.Trigger_Asset_Count_Status_on_Account__c)
            {
                if(!lstTACAccount.contains(oldAsset.AccountId))
                {
                    lstTACAccount.add(oldAsset.AccountId);
                }
            }
        }
        MakeFinalUpdateToAccount();
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
     
        if(newItems!=null)
        {
            for(Id assetId : newItems.keySet())
            {
                Asset newAsset=(Asset)newItems.get(assetId);
                if(newAsset.AccountId!=null && newAsset.Status!='Customer Evaluation' && !newAsset.Trigger_Asset_Count_Status_on_Account__c)
                {
                     if(!lstTACAccount.contains(newAsset.AccountId))
                    {
                        lstTACAccount.add(newAsset.AccountId);
                    }
                }
            }
        }
       MakeFinalUpdateToAccount(); 
    }
    
    private void MakeFinalUpdateToAccount()
    {
        Set<Id> acctIds= new Set<Id>();
        acctIds.addAll(lstHWCPAccount);
        acctIds.addAll(lstSWCPAccount);
        acctIds.addAll(lstTACAccount);
        List<Account> lstAccountToUpdate = new List<Account>();
        if(acctIds.size()>0)
        {
            for(Id accountId :acctIds)
            {
                Account accountInfo=new Account(Id=accountId);
                if(lstHWCPAccount!=null && lstHWCPAccount.contains(accountId))
                {
                    accountInfo.Sync_with_Cloud_Portal__c=true;
                }
                if(lstSWCPAccount!=null && lstSWCPAccount.contains(accountId))
                {
                    accountInfo.Sync_Virtual_Assets_with_CP__c=true;
                }   
                if(lstTACAccount!=null && lstTACAccount.contains(accountId))
                {
                    accountInfo.Trigger_Active_Asset_Count__c=true;
                }   
                if(lstCustomerDateAccount!=null && lstCustomerDateAccount.containsKey(accountId))
                {
                    Account accData= lstCustomerDateAccount.get(accountId);
                    accountInfo.EC_Customer_Date__c=accData.EC_Customer_Date__c;
                    accountInfo.WAN_OP_Customer_Date__c=accData.WAN_OP_Customer_Date__c;
                }
                lstAccountToUpdate.add(accountInfo);
            }
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
    
    //Private methods
    private void AddActiveECBaseLicense(Map<Id,Asset> hardwareECAssetIds,Map<Id,Asset> softwareECBaseAssetIds, Set<Id> setAccIds)
    {
        Map<string,Id> firstECBaseLicense= new  Map<string,Id>();
        List<Asset> lstHardwareAssetToUpdate=new List<Asset>();
        if(hardwareECAssetIds.size()>0)
        {
            List<Asset> lstBaseLicenses=[Select Id,AccountId,Status from Asset where AccountId in:setAccIds and Product2.Family='Virtual Image' and Status in('Customer Subscription Active','Customer Evaluation') and Product2.Name like 'EC-BASE-%' and Product2.Product_Type__c ='EDGECONNECT'];
            if(lstBaseLicenses!=null && lstBaseLicenses.size()>0)
            {
                for(Asset item: lstBaseLicenses)
                {
                    firstECBaseLicense.put(item.AccountId+'|'+item.Status,item.Id);
                }
            }
            for(Id assetId :hardwareECAssetIds.keySet())
            {
                Asset assetData=hardwareECAssetIds.get(assetId);
                string status=assetData.Status=='Customer Evaluation'?'Customer Evaluation':'Customer Subscription Active';
                if(firstECBaseLicense.containsKey(assetData.AccountId+'|'+status))
                {
                    Id baseLicense= firstECBaseLicense.get(assetData.AccountId+'|'+status);
                    Asset hardwareAssetToUpdate = new Asset(Id=assetId,Active_EC_Base_License__c=baseLicense);
                    lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                }
            }
        }
        if(softwareECBaseAssetIds.size()>0)
        {
            for(Id assetId : softwareECBaseAssetIds.keySet())
            {
                Asset assetData=softwareECBaseAssetIds.get(assetId);
                string status='Customer Owned';
                if(assetData.Status=='Customer Evaluation')
                    status='Customer Evaluation';
                Set<Id> ids = (new Map<Id, Asset>([Select Id from Asset where AccountId=:assetData.AccountId and Product2.Family='Product' and Status=:status and Product2.Product_Type__c like 'EDGECONNECT' order by CreatedDate desc])).keySet();
                if(ids!=null && ids.size()>0)
                {
                    for(Id hardWareId : ids)
                    {
                        Asset hardwareAssetToUpdate = new Asset(Id=hardWareId,Active_EC_Base_License__c=assetId);
                        lstHardwareAssetToUpdate.add(hardwareAssetToUpdate);
                    }
                    
                }
            }
        }
        if(lstHardwareAssetToUpdate.size()>0)
        {
            update lstHardwareAssetToUpdate;
        }
    }
    private void UpdateEOMDate(List<Asset> lstAssets)
    {
        if(lstAssets!=null && lstAssets.size()>0)
        {
            List<EOMDate__c> EOMDates = [select Model__c, EOMDate__c, ShipDate__c from EOMDate__c];
            for(Asset asset : lstAssets)
            {
                Date minEomDate = Date.newInstance(3000, 01, 01);
                List<EOMDate__c> assetEOMs = new List<EOMDate__c>();
                for(EOMDate__c eom : EOMDates)
                {
                    if(asset.Model__c == eom.Model__c && asset.Ship_Date__c < eom.ShipDate__c)
                    {
                        if(minEomDate > eom.EOMDate__c)
                        {
                            minEomDate = eom.EOMDate__c;
                        }
                    }
                }
                asset.End_of_Maintenance__c = (minEomDate == Date.newInstance(3000, 01, 01) ? null : minEomDate);
            }
        }
    }
}