public class CloudPortalProvisionAssetsJob  implements Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Name,Cloud_Portal_Account_Id__c from Account where Sync_With_Cloud_Portal__c=true]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
       
        List<Asset> lstAsset=null;
        boolean isSuccessCallout=false;
       
        List<Account> lstAccountToUpdate= new List<Account>();
        List<Asset> lstFinalAssets= new List<Asset>();
        List<Account> lstFinalSyncAccountUpdate= new List<Account>();
        
        
        List<Account> lstAccounts=(List<Account>)scope;
        if(lstAccounts!=null && lstAccounts.size()>0)
        {
            for(Account accId:lstAccounts)
            {
                try
                {
                    string cloudPortalId='';
                    Account accUpdated= new Account();
                    lstAsset= new List<Asset>();
                    
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
                    lstAsset=[Select Id from Asset where AccountId=:accId.Id and Sync_With_Cloud_Portal__c=true and Product2.Name like 'EC%' and Cloud_Portal_Sync_Status__c='Pending' and Product2.Family='Product'];
                    List<Asset> lstAssetsToUpdate=[Select Id,SerialNumber,Product2.Model__c,Product2.Name from Asset where AccountId=:accId.Id and Product2.name like 'EC%' and status not in ('Silver Peak Inventory','Write-Off','Obsolete RMA Unit–Supp Transferred–WO','Owned Eval/NFR') and Product2.Family='Product' and SBQQ__QuoteLine__c = null ];
                    Map<string,string> lstSerialNumber= new Map<string,string>();
                    if(lstAssetsToUpdate!=null && lstAssetsToUpdate.size()>0)
                    {
                        for(Asset info: lstAssetsToUpdate)
                        {
                            lstSerialNumber.put(info.SerialNumber,info.Product2.Name);
                        }
                        
                    }
                    
                    string currToken= CloudPortalAccountHelper.GetTokenFromPortal();
                    CloudPortalPostProvisionAssetsApi obj= new CloudPortalPostProvisionAssetsApi(cloudPortalId,lstSerialNumber);
                    obj.token=currToken;
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
                        if(accUpdated!=null && accUpdated.Id!=null)
                        { lstAccountToUpdate.add(accUpdated);} 
                        
                       lstFinalSyncAccountUpdate.add(new Account(Id=accId.Id,Sync_With_Cloud_Portal__c=false));
                        
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
            CloudPortalProvisionAssetsJob obj= new CloudPortalProvisionAssetsJob();
            System.scheduleBatch(obj, 'CPProvisionAssets', 30,1);
        }
        
    }
    
    
}