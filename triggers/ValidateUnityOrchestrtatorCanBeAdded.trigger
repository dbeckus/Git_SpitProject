trigger ValidateUnityOrchestrtatorCanBeAdded on Request__c (before insert, before update) {
    
    for(Request__c item:Trigger.New)
    {
        Request__c oldPOC=null;
        if(Trigger.IsUpdate)
        {
            oldPOC=Trigger.OldMap.get(item.Id);
        }
        if(item.POC_Type__c=='EdgeConnect' && item.Is_Unity_Cloud_Orchestrator__c && (oldPOC==null || (oldPOC!=null && oldPoc.Is_Unity_Cloud_Orchestrator__c!=item.Is_Unity_Cloud_Orchestrator__c)))
        {
            List<Request__c> lstReq=[Select Id from Request__c where Opportunity__c =:item.Opportunity__c and Is_Unity_Cloud_Orchestrator__c=true and status__c in('Open','Approved To Ship','Pending Approvals')];
            List<Asset> lstAsset=[Select Id from Asset where Product2.Name like 'EC-ORCH-AAS%' and Status in('Customer Subscription Active','Customer Evaluation')];
            if((lstReq!=null && lstReq.size()>0)||(lstAsset!=null && lstAsset.size()>0))
            {
                item.addError('Unity Cloud Orchestrator cannot be requested as there is an existing active cloud orch asset or POC on this account.');
            }
        }
    }

}