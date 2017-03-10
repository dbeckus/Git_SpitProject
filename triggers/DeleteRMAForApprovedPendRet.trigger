trigger DeleteRMAForApprovedPendRet on Request__c (after update) {
    Set<Id> reqIdList= new Set<Id>();
    for(Request__c req: Trigger.New)
    {
        Request__c oldPOC= Trigger.OldMap.get(req.Id);
        if((oldPoc.Status__c=='Shipped- Pending Extension Approval' || oldPoc.Status__c=='Pending Return' || oldPoc.Status__c=='Pending Return - Invoiced' ) && req.Status__c=='Shipped - Extended')
        {
            reqIdList.add(req.Id);
        }
    }
    
    if(reqIdList.size()>0)
    {
        List<RMA__c> rmaIds = [Select Id from RMA__c where Request__c in:reqIdList and Status__c!='Closed'];
        if(rmaIds!=null && rmaIds.size()>0)
        {
            List<Asset> lstAsset=[Select Id from Asset where Id in (Select Asset__c from RMA_Item__c where RMA__c in: rmaIds)];
            if(lstAsset!=null && lstAsset.size()>0)
            {
                for(Asset item: lstAsset)
                {
                    item.Status='Customer Evaluation';
                }
                
                update lstAsset;
            }
            
            delete rmaIds;
        }
    }
    
}