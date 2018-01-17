trigger UpdateGEORegionTrigger on User_GEO_Region__e (after insert) {
    
    Map<Id,string> mapGEORegion= new Map<Id,string>();
    try
    {
        for(User_GEO_Region__e  rec:Trigger.New)
        {
            mapGEORegion.put(rec.Owner_Id__c,rec.GEO_Region__c);
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