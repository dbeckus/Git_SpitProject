trigger DeleteRMAForApprovedPendRet on Request__c (after update) {
    Set<Id> reqIdList= new Set<Id>();
    for(Request__c req: Trigger.New)
    {
        Request__c oldPOC= Trigger.OldMap.get(req.Id);
        if((oldPoc.Status__c=='Pending Return' || oldPoc.Status__c=='Pending Return - Invoiced')&& req.Status__c=='Shipped - Extended')
        {
            reqIdList.add(req.Id);
        }
    }
    
    List<RMA__c> rmaIds = [Select Id from RMA__c where Request__c in:reqIdList];
    if(rmaIds!=null && rmaIds.size()>0)
    {
        delete rmaIds;
    }
}