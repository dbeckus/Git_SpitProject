trigger SetAccountNameFromCaseContact on Case (after insert, after update) {
    Set<Id> caseIds = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Case caseInfo : Trigger.new)
        {
            if(caseInfo.ContactId!=null)
            {
                caseIds.add(caseInfo.Id);
            }
            
            
        }
    }
    else 
    {
        for(Case caseInfo : Trigger.new)
        {
            if(caseInfo.ContactId != Trigger.oldMap.get(caseInfo.Id).ContactID)
            {
                caseIds.add(caseInfo.Id);
            }
        }
        
    }
    
    if(caseIds.size()>0)
    {
        List<Case> caseList=[Select Id, ContactId,AccountID from Case where Id in:caseIds];
        List<Case> lstCaseUpdated= new List<Case>();
        for(Case counter:caseList)
        {
            if(counter.ContactId!=null)
            {
                Contact contactInfo= [Select Id,AccountId from Contact where Id=:counter.ContactId LIMIT 1];
                counter.AccountId = contactInfo.AccountId;
                lstCaseUpdated.add(counter);
            }
        }
        if(lstCaseUpdated.size()>0)
        {update lstCaseUpdated;}
    }
    
}