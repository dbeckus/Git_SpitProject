trigger ReSyncDeletedAssetsIntoCloudPortal on Asset (after delete) {
    Set<Id> acctIds= new Set<Id>();
    List<Account> lstAcctIds= new List<Account>();
    for(Asset asset : Trigger.old)
    {
        System.debug(asset.Model__c);
        System.debug(asset.Product_Family__c);
        if(asset.Status=='Customer Evaluation' && asset.Model__c.startsWith('EC') && asset.Product_Family__c=='Virtual Image')
        {
            acctIds.add(asset.AccountId);
        }
        
    }
    if(acctIds.size()>0)
    {
        for(Id item:acctIds )
        {
            System.debug('account.Id'+item);
            lstAcctIds.add(new Account(Id=item,Sync_Virtual_Assets_with_CP__c=true));
        }
        
    }
    if(lstAcctIds.size()>0)
    {
        System.debug('lstAcctIds'+lstAcctIds.size());
        update lstAcctIds;
    }
    
    
}