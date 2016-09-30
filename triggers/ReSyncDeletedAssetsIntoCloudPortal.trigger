trigger ReSyncDeletedAssetsIntoCloudPortal on Asset (after delete) {
    Set<Id> acctIds= new Set<Id>();
    List<Account> lstAcctIds= new List<Account>();
    for(Asset asset : Trigger.old)
    {
        if(asset.Status=='Customer Evaluation' && asset.POCRequest__c!=null)
        {
            acctIds.add(asset.AccountId);
        }
        
    }
    if(acctIds.size()>0)
    {
        for(Id item:acctIds )
        {
            lstAcctIds.add(new Account(Id=item,Sync_Virtual_Assets_with_CP__c=true));
        }
        
    }
    if(lstAcctIds.size()>0)
    {
        update lstAcctIds;
    }
    
}