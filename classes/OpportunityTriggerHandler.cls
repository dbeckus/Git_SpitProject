public class OpportunityTriggerHandler implements ITriggerHandler {
    public OpportunityTriggerHandler()
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
            for(Opportunity oppInfo:(List<Opportunity>)newItems)
            {
                
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                if(!newOpp.IsClosed)
                {
                    if(oldOpp.Has_Active_POCs__c != newOpp.Has_Active_POCs__c)
                    {
                        if(newOpp.Has_Active_POCs__c)
                        {
                            newOpp.POC_Start_Date__c = Date.today();
                            newOpp.POC_End_Date__c   = Date.today();
                            newOpp.POC_Duration__c   = oldOpp.POC_Age__c;
                        }
                        else
                        {
                            newOpp.POC_End_Date__c   = Date.today();
                        }
                    }
                }
                else if(newOpp.IsClosed && !oldOpp.IsClosed)
                {
                    if(newOpp.Has_Active_POCs__c)
                    {
                        newOpp.POC_End_Date__c = Date.today();
                    }   
                }
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        if(oldItems.size()>0)
        {
            for(Id oppId:oldItems.keySet())
            {
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<Id> lstOpps= new List<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                if(newOpp.CampaignId == SalesDevelopmentHelper.getSDcampaign())
                {
                    lstOpps.add(oppId);
                }
            }
            
            ResetPrimaryCampaignSource(lstOpps);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        List<Opportunity> wanStartOpps= new List<Opportunity>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
                if(!SilverPeakUtils.BypassingTriggers)
                {  
                    wanStartOpps.add(newOpp);
                }
            }
            
            CreateWANStartCase(wanStartOpps);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id oppId : oldItems.keyset())
            {
                Opportunity oldOpp=(Opportunity)oldItems.get(oppId);
            }
            if(!SilverPeakUtils.BypassingTriggers)
            {
                OpportunityMergeController.removeOrphanedPOC();
            }  
            
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id oppId : newItems.keyset())
            {
                Opportunity newOpp=(Opportunity)newItems.get(oppId);
            }
        }
    }
    
    private void ResetPrimaryCampaignSource(List<Id> setOpps)
    {
        if(setOpps.size() > 0)
        {
            if(System.isFuture())
            {
                SalesDevelopmentHelper.ResetPrimaryCampaignSource(setOpps);
            }
            else
            {
                SalesDevelopmentHelper.willResetPrimaryCampaignSource(setOpps);
            }
        }
    }
    private void CreateWANStartCase(List<Opportunity> lstOpps)
    {
        if(lstOpps!=null && lstOpps.size()>0)
        {
            
        }
    }
    private Boolean isUpdatedStageOrWanStart(Opportunity newOpp, Opportunity oldOpp)
    {
        return newOpp.IsWon != oldOpp.IsWon || newOpp.WANstart_count__c != oldOpp.WANstart_count__c || newOpp.WANstartCaseCreated__c != oldOpp.WANstartCaseCreated__c;
    }
}