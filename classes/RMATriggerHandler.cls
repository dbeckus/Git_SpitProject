public class RMATriggerHandler implements ITriggerHandler {
    Set<Id> caseIds = new Set<Id>();
    public RMATriggerHandler()
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
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                if(newRMA.Case__c != null)
                {
                    caseIds.add(newRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {    
        Set<Id> setRMAs= new Set<Id>();
        Set<Id> setRMADispatchIds= new Set<Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                RMA__c oldRMA= (RMA__c) oldItems.get(rmaId);
                if(newRMA.Type__c=='Advance Replace'&& newRMA.Status__c=='In FA/Recd' && oldRMA.Status__c!=newRMA.Status__c)
                {
                    setRMAs.add(rmaId);
                }
                if(newRMA.Status__c == 'Dispatched' && oldRMA.Status__c != 'Dispatched')
                {
                    setRMADispatchIds.add(rmaId);
                }
                if(newRMA.Case__c != oldRma.Case__c)
                {
                    if(newRMA.Case__c != null)
                    {
                        caseIds.add(newRMA.Case__c);
                    }
                    if(oldRma.Case__c != null)
                    {
                        caseIds.add(oldRma.Case__c);
                    }
                }
                
            }
            UpdateRMACountOnCase();
            DispatchRMAItem(setRMADispatchIds);
            SendNotificationtoHardwareEngineering(setRMAs);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        if(oldItems!=null && oldItems.size()>0)
        {
            for (Id rmaId : oldItems.keyset())
            {
                RMA__c oldRMA= (RMA__c) oldItems.get(rmaId);
                if(oldRMA.Case__c != null)
                {
                    caseIds.add(oldRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id rmaId : newItems.keyset())
            {
                RMA__c newRMA= (RMA__c) newItems.get(rmaId);
                if(newRMA.Case__c != null)
                {
                    caseIds.add(newRMA.Case__c);
                }
            }
            UpdateRMACountOnCase();
        }
    }
    
    private void UpdateRMACountOnCase()
    {
        if(caseIds!=null && caseIds.size()>0)
        {
            List<Case> updatingCases = new List<Case>();
            for(Id caseId : caseIds)
            {
                Integer count = [select count() from RMA__c where Case__c=:caseId];
                Case updatingCase = new Case(Id = caseId, RMA_Count__c = count);
                updatingCases.add(updatingCase);
            }
            update updatingCases;
        }
        
    }
    
    private void DispatchRMAItem(Set<Id> setRMAIds)
    {
        List<RMA_Item__c> items = new List<RMA_Item__c>();
        if(setRMAIds!=null && setRMAIds.size()>0)
        {
            items = [select Id from RMA_Item__c where RMA__c in:setRMAIds];
            if(items.size() > 0)
            {
                update items;
            }
        }
        
    }
    
    private void SendNotificationtoHardwareEngineering(Set<Id> setRMAIds)
    {
        if(setRMAIds!=null && setRMAIds.size()>0)
        {
            List<RMA_Item__c> rmaItems=[Select Id,Asset__r.Name,Asset__r.Product2.Name,RMA__r.Name,RMA__r.Disposition__c,RMA__r.Disposition_Notes__c,RMA__r.Account__r.Name,RMA__r.Contact__r.Id from RMA_Item__c where RMA__c in:setRMAIds];
            if(rmaItems!=null && rmaItems.size()>0)
            {
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                for(RMA_Item__c item:rmaItems)
                {
                    OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Silver Peak Notifications' limit 1];
                    String templateString='S/N {0} ({1}) has been returned from {2} against {3}.\n\n\n';
                    String[] arguments = new String[] {item.Asset__r.Name, item.Asset__r.Product2.Name,item.RMA__r.Account__r.Name,item.RMA__r.Name};
                        string bodyText= string.format(templateString,arguments);
                    bodyText= bodyText+ 'Disposition Location: '+ item.RMA__r.Disposition__c +'\n';
                    bodyText= bodyText+ 'Notes: '+ item.RMA__r.Disposition_Notes__c;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(owa.id);
                    List<String> sendTo = new List<String>();
                    sendTo.add('hware@silver-peak.com');
                    mail.setToAddresses(sendTo);
                    mail.setSubject(item.RMA__r.Name +' faulty system received');
                    mail.setPlainTextBody (bodyText);
                    List<String> ccTo = new List<String>();
                    ccTo.add('notifications@silver-peak.com');
                    mail.setCcAddresses(ccTo);
                    allmsg.add(mail);
                    
                }
                if(allmsg.size()>0)
                {
                    if(!Test.isRunningTest())
                    {
                        Messaging.sendEmail(allmsg,false);
                    }
                    
                }
                
                
            }
        }
    }
}