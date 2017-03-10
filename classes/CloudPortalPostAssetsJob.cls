public class CloudPortalPostAssetsJob implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts 
{
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Name,Cloud_Portal_Account_Id__c from Account where Sync_Virtual_Assets_with_CP__c=true]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
        List<Asset> lstAsset= null;
        boolean isSuccessCallout=false;
        
        List<Account> lstAccountToUpdate= new List<Account>();
        List<Asset> lstFinalAssets= new List<Asset>();
        List<Account> lstFinalSyncAccountUpdate= new List<Account>();
        List<Account> lstAccounts =(List<Account>)scope;
        if(lstAccounts!=null && lstAccounts.size()>0)
        {
            for(Account accId:lstAccounts)
            {
                try
                {
                    string cloudPortalId='';
                    Account accUpdated= new Account();
                    lstAsset=new List<Asset>();
                    lstAsset=[Select Id,Sync_With_Cloud_Portal__c,Cloud_Portal_Sync_Status__c from Asset where AccountId=:accId.Id and Sync_With_Cloud_Portal__c=true and Cloud_Portal_Sync_Status__c='Pending' and Product2.Family='Virtual Image'];
                    
                    if(accId.Cloud_Portal_Account_Id__c!=null)
                    {
                        cloudPortalId=accId.Cloud_Portal_Account_Id__c;
                    }
                    else
                    {
                        accUpdated=CloudPortalAccountHelper.GetOrCreateAccountFromCloudPortal(accId.Id,accId.Name);
                        cloudPortalId= accUpdated.Cloud_Portal_Account_Id__c;
                        
                    }
                    if(String.isBlank(cloudPortalId))
                    {
                        continue;
                    }
                    List<Asset> lstAssetsToUpdate=[Select Id,SerialNumber,Product2.Name,Product2.Model__c,Product2.Product_Type__c,Licenses_Nodes__c,Bandwidth_Nodes__c,License_End_Date__c,Contract_Number__r.StartDate,Contract_Number__r.EndDate,Quantity from Asset where AccountId=:accId.Id and (Product2.Name like 'EC%' or Product2.Name like'UNITY CLOUD%') and Product2.Family='Virtual Image' and (NOT Product2.Name='EC-ORCH') and Status in ('Customer Subscription Active','Customer Subscription','Customer Evaluation','Loan','Conditional PO','Customer Owned') and SBQQ__QuoteLine__c = null ];
                    // Call the account helper to create assets in cloudportal format.
                    List<CPAsset> lstECAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'EC');
                    List<CPAsset> lstSaasAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'SAAS');
                    List<CPAsset> lstCPXAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'CPX');
                    List<CPAsset> lstSPAssets=CloudPortalAccountHelper.ConvertAssetToCpAsset(lstAssetsToUpdate, 'SP');
                    string currToken= CloudPortalAccountHelper.GetTokenFromPortal();
                    CloudPortalPostAssetsApi obj= new CloudPortalPostAssetsApi(cloudPortalId);
                    obj.token=currToken;
                    obj.cpxAssets=lstCPXAssets;
                    obj.ecAssets=lstECAssets;
                    obj.saasAssets=lstSaasAssets;
                    obj.spAssets=lstSPAssets;
                    obj.execute();
                    if(obj.isSucceed)
                    {
                        if(lstAsset!=null && lstAsset.size()>0)
                        {
                            for(Asset item: lstAsset)
                            {
                                item.Sync_With_Cloud_Portal__c=false;
                                item.Cloud_Portal_Sync_Status__c='Complete';
                                lstFinalAssets.add(item);
                            }
                        }
                        System.debug('accUpdated '+ accUpdated);
                        if(accUpdated!=null && accUpdated.Id!=null)
                        { 
                            lstAccountToUpdate.add(accUpdated);
                        }
                        
                        lstFinalSyncAccountUpdate.add(new Account(Id=accId.Id,Sync_Virtual_Assets_with_CP__c=false));
                    } 
                }
                catch(Exception ex)
                {
                    SilverPeakUtils.logException(ex);
                    continue;
                }
            }
            
            try
            {
                if(lstAccountToUpdate.size()>0)
                {
                    update lstAccountToUpdate;
                }
                if(lstFinalAssets.size()>0)
                {
                    update lstFinalAssets;
                }     
                 if(lstFinalSyncAccountUpdate.size()>0)
                {
                    update lstFinalSyncAccountUpdate;
                }    
                 
            }
            catch(Exception ex)
            {
                
                SilverPeakUtils.logException(ex);
            }
        }
        
    }  
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CloudPortalPostAssetsJob obj= new CloudPortalPostAssetsJob();
            System.scheduleBatch(obj, 'CPPostAssets', 30, 1);
        }
        
    }
    
}