trigger DeletionNotAllowedAccountSyncToCloudPortal on Account (before delete) {
    boolean isSynced=false;
    for(Account acc:Trigger.Old)
    {
        if(acc.Cloud_Portal_Account_Id__c!=null ||acc.Cloud_Portal_Account_Key__c!=null||acc.Cloud_Portal_Account_Name__c!=null || acc.Sync_with_Cloud_Portal__c )
        {
            isSynced=true;
        }
        
        if(!isSynced && (acc.Cloud_Portal_Account_Id__c==null ||acc.Cloud_Portal_Account_Key__c==null||acc.Cloud_Portal_Account_Name__c==null))
        {
            List<Asset> lstAssets= [Select Id from Asset where AccountId=:acc.Id and (Product2.Name like 'EC%' or Product2.Name like 'UNITY%' )];
            if(lstAssets.size()>0)
            {
                isSynced=true;
            }
            
            
        }
        if(isSynced)
        {
            acc.addError('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.');
        }
        
    }
}