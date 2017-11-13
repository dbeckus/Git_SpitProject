/*
 * updates the RMA_Count field on case according to the count of its RMAs.
 */
trigger UpdateRMACountOnCase on RMA__c (after insert, after delete, after undelete, after update) 
{
    Set<Id> caseIds = new Set<Id>();
    if(Trigger.isDelete)
    {
        for(RMA__c rma : Trigger.old)
        {
            if(rma.Case__c != null)
            {
                caseIds.add(rma.Case__c);
            }
        }
    }
    else if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(RMA__c rma : Trigger.new)
        {
            if(rma.Case__c != null)
            {
                caseIds.add(rma.Case__c);
            }
        }
    }
    else
    {
        //isUpdate
        for(RMA__c rma : Trigger.new)
        {
            RMA__c oldRma = Trigger.oldMap.get(rma.Id);
            if(rma.Case__c != oldRma.Case__c)
            {
                if(rma.Case__c != null)
                {
                    caseIds.add(rma.Case__c);
                }
                if(oldRma.Case__c != null)
                {
                    caseIds.add(oldRma.Case__c);
                }
            }
        }
    }
    List<Case> updatingCases = new List<Case>();
    for(Id caseId : caseIds)
    {
        Integer count = [select count() from RMA__c where Case__c=:caseId];
        Case updatingCase = new Case(Id = caseId, RMA_Count__c = count);
        updatingCases.add(updatingCase);
    }
    update updatingCases;
}