public class GEORegionChangeTriggerHandler implements ITriggerHandler {
    public GEORegionChangeTriggerHandler()
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
        Map<Id,string> mapGEORegion= new Map<Id,string>();
        try
        {
            Map<Id, User_GEO_Region__e>lstGeoRegion=(Map<Id, User_GEO_Region__e>) newItems;
            for(Id  recId:lstGeoRegion.keyset())
            {
                User_GEO_Region__e item= lstGeoRegion.get(recId);
                mapGEORegion.put((Id)item.Owner_Id__c,item.GEO_Region__c);
            }
            if(mapGEORegion.size()>0)
            {
                List<opportunity> lstOpp=[Select Id,ownerId from Opportunity where ISClosed=false and OwnerId in:mapGEORegion.keySet()];
                System.debug('lstOpp.size()' + lstOpp.size());
                if(lstOpp!=null && lstOpp.size()>0)
                {
                    for(Opportunity opp: lstOpp)
                    {
                        opp.Sales_Region__c=mapGEORegion.get(opp.ownerId);
                        System.debug('opp.Sales_Region__c '+ opp.Sales_Region__c);
                    }
                    
                    System.debug('lstOpp'+ lstOpp);
                    update lstOpp;
                }
            }
            
        }
        catch(Exception ex)
        {
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