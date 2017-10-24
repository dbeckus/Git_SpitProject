public class RMAItemTriggerHandler implements ITriggerHandler {
    Id silverpeakSystemsId='00130000007mEjX';// production Id
    public RMAItemTriggerHandler()
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
            
            for (Id rmaItemId : newItems.keyset())
            {
                RMA_Item__c  newRMAItem=(RMA_Item__c )newItems.get(rmaItemId);
                RMA_Item__c  oldRMAItem=(RMA_Item__c )oldItems.get(rmaItemId);
                
                
                
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for(Id rmaItemId: newItems.keyset())
            {
            }
            
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        List<Asset> lstAsset= new List<Asset>();
        Set<Id> assetIds = new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id rmaItemId: newItems.keyset())
            {
                RMA_Item__c newRMAItem= (RMA_Item__c)newItems.get(rmaItemId);
                RMA_Item__c oldRMAItem= (RMA_Item__c)oldItems.get(rmaItemId);
                if(newRMAItem.Asset__c!=null && newRMAItem.Status__c!=oldRMAItem.Status__c && newRMAItem.Status__c=='Received' )
                {
                    if(newRMAItem.Product_Category__c!=null && (newRMAItem.Product_Category__c =='Appliance' || newRMAItem.Product_Category__c =='GMS'))
                    {
                        Asset asset= new Asset(Id=newRMAItem.Asset__c);
                        asset.ContactId = null;
                        asset.Status = 'Silver Peak Inventory';
                        asset.Description = null;
                        asset.Ship_To_Location__c = null;
                        asset.Installed_At_Location__c = null;
                        asset.Ship_Date__c = null;
                        asset.Warranty_Start_Date__c = null;
                        asset.Warranty_End_Date__c = null;
                        asset.Evaluation_Start_Date__c = null;
                        asset.Evaluation_End_Date__c = null;
                        asset.End_of_Software_Support__c = null;
                        asset.GMS_Nodes__c = null;
                        asset.POCRequest__c = null;
                        asset.Customer_Notes__c= null;
                        asset.AccountId = silverpeakSystemsId;
                        lstAsset.add(asset);
                    }
                    
                }
            }
            if(lstAsset!=null && lstAsset.size()>0)
           		update lstAsset;
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
}