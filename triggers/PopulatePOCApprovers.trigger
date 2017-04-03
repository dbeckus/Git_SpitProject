trigger PopulatePOCApprovers on Request__c (after insert,after update) {
    Map<Id,Opportunity> mapOppId= new Map<Id,Opportunity>(); 
    Map<Id,Id> mapReqId= new Map<Id,Id>(); 
    Set<Id> removeUsers = new Set<Id>{'00550000000lhIW','00530000000jZPL'};// remove eric and chris helfer from the APAC and EMEA
        if(Trigger.IsInsert)
    {
        for(Request__c req :Trigger.New)
        {
            if(req.Opportunity__c!=null)
            {
                mapReqId.put(req.Id,req.Opportunity__c);
                if(!mapOppId.containsKey(req.Opportunity__c))
                {
                    mapOppId.put(req.Opportunity__c,null);
                }
            }
        }
    }
    if(Trigger.IsUpdate)
    {
        for(Request__c req :Trigger.New)
        {
            Request__c oldPoc= Trigger.OldMap.get(req.Id);
            if(oldPoc.Trigger_POC_Approvers__c!=req.Trigger_POC_Approvers__c && req.Trigger_POC_Approvers__c)
            {
                if(req.Opportunity__c!=null)
                {
                    mapReqId.put(req.Id,req.Opportunity__c);
                    if(!mapOppId.containsKey(req.Opportunity__c))
                    {
                        mapOppId.put(req.Opportunity__c,null);
                    }
                }
            }
        }
    }
    if(mapOppId.size()>0)
    {
        List<Opportunity> lstOpportunity=[Select Id,Account.ECSP__c,OwnerId,Owner.ManagerId,Owner.Manager.ManagerId,Technical_Responsible__c,Technical_Responsible__r.ManagerId,Technical_Responsible__r.Manager.ManagerId, GEO_Region__c from Opportunity where Id in:mapOppId.keySet()];
        for(Opportunity opp:lstOpportunity)
        {
            if(mapOppId.containsKey(opp.Id))
            {
                mapOppId.put(opp.Id,opp);
            }
        }
        List<Request__c> lstPocs= new List<Request__c>();
        for(Id reqId:mapReqId.keySet())
        {
            
            Opportunity finalOpp= mapOppId.get(mapReqId.get(reqId));
            Request__c pocToUpdate= new Request__c(Id=reqId);
            pocToUpdate.RSM__c=finalOpp.OwnerId!=null?finalOpp.OwnerId:null;
            pocToUpdate.SE__c=finalOpp.Technical_Responsible__c!=null?finalOpp.Technical_Responsible__c:null;
            if(finalOpp.Account.ECSP__c || finalOpp.GEO_Region__c.startsWith('APAC') || finalOpp.GEO_Region__c.startsWith('EMEA'))
            {
                pocToUpdate.RSM_Manager__c=(finalOpp.Owner.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.ManagerId) )?finalOpp.Owner.ManagerId:null;
                pocToUpdate.RSM_VP_Sales__c=(finalOpp.Owner.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Owner.Manager.ManagerId))?finalOpp.Owner.Manager.ManagerId:null;
                pocToUpdate.SE_Manager__c=(finalOpp.Technical_Responsible__r.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.ManagerId))?finalOpp.Technical_Responsible__r.ManagerId:null;
                pocToUpdate.SE_Director__c=(finalOpp.Technical_Responsible__r.Manager.ManagerId!=null && !removeUsers.contains(finalOpp.Technical_Responsible__r.Manager.ManagerId) )?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
            }
            else
            {
                pocToUpdate.RSM_Manager__c=finalOpp.Owner.ManagerId!=null?finalOpp.Owner.ManagerId:null;
                pocToUpdate.RSM_VP_Sales__c=finalOpp.Owner.Manager.ManagerId!=null?finalOpp.Owner.Manager.ManagerId:null;
                pocToUpdate.SE_Manager__c=finalOpp.Technical_Responsible__r.ManagerId!=null?finalOpp.Technical_Responsible__r.ManagerId:null;
                pocToUpdate.SE_Director__c=finalOpp.Technical_Responsible__r.Manager.ManagerId!=null?finalOpp.Technical_Responsible__r.Manager.ManagerId:null;
            }
            pocToUpdate.Trigger_POC_Approvers__c=false;
            lstPocs.add(pocToUpdate);
            
        }
        if(lstPocs.size()>0)
            update lstPocs;
    }
}