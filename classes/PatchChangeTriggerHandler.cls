public class PatchChangeTriggerHandler implements ITriggerHandler {
    
    public PatchChangeTriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        Map<Id,String> setCAMChange = new Map<Id,String>();
        Map<Id,String> setRSMChange = new Map<Id,String>();
        
        for(Id recId:newItems.keyset())
        {
            Patch_Change__e obj= (Patch_Change__e)newItems.get(recId);
            if(obj.Channel_Manager_Name__c!=null)
            {
                setCAMChange.put((Id)obj.Patch_Id__c,obj.Channel_Manager_Name__c);
            }
            if(obj.RSM_Name__c!=null)
            {
                setRSMChange.put((Id)obj.Patch_Id__c,obj.RSM_Name__c);
            }
            
        }
        try
        {
            if(setCAMChange.size()>0)
            {
                List<Opportunity> lstOpp=[Select Id,Patch__c,Channel_Manager__c from Opportunity where IsClosed=false and Patch__c in:setCAMChange.keyset()];
                if(lstOpp!=null && lstOpp.size()>0)
                {
                    
                    for(Opportunity opp: lstOpp)
                    {
                        opp.Channel_Manager__c=setCAMChange.get(opp.Patch__c);
                    }
                    Database.update(lstOpp, false);
                    System.debug('Done');
                }
                
            }
            if(setRSMChange.size()>0)
            {
                List<Opportunity> lstOpp=[Select Id,Patch__c,Regional_Sales_Manager__c from Opportunity where IsClosed=false and Patch__c in:setRSMChange.keyset()];
                if(lstOpp!=null && lstOpp.size()>0)
                {
                    for(Opportunity opp: lstOpp)
                    {
                        opp.Regional_Sales_Manager__c=setRSMChange.get(opp.Patch__c);
                    }
                    Database.update(lstOpp, false);
                    System.debug('Done');
                }
                
            }
            
        }
        catch(Exception ex)
        {
            System.debug(ex);
            SilverPeakUtils.logException(ex);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
}