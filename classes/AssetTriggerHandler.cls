public class AssetTriggerHandler implements ITriggerHandler {
    
    public AssetTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
            
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
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id assetId : newItems.keyset())
            {
                Asset data= (Asset)newItems.get(assetId);
            }
            
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            
            for (Id assetId : newItems.keyset())
            {
                
            }
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        Set<Id> acctIds= new Set<Id>();
        List<Account> lstAcctIds= new List<Account>();
        for(Id assetId : oldItems.keySet())
        {
            Asset oldAsset=(Asset)oldItems.get(assetId);
            if(oldAsset.Status=='Customer Evaluation' && oldAsset.Model__c.startsWith('EC') && oldAsset.Product_Family__c=='Virtual Image')
            {
                if(!acctIds.contains(oldAsset.AccountId))
                {
                    acctIds.add(oldAsset.AccountId);
                    lstAcctIds.add(new Account(Id=assetId,Sync_Virtual_Assets_with_CP__c=true));
                }
            }  
        }
        if(lstAcctIds.size()>0)
        {
            update lstAcctIds;
        }
    }
    public void AfterUndelete(Map<Id, SObject> oldItems) 
    {
        
    }
    
    
}