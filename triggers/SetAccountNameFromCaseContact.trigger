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
        List<Case> caseList=[Select Id, ContactId,AccountID,Contact.AccountId from Case  where Id in:caseIds FOR UPDATE];
        List<Case> lstCaseUpdated= new List<Case>();
        for(Case counter:caseList)
        {
            if(counter.ContactId!=null && counter.Contact.AccountId!=null)
            {
                //Contact contactInfo= [Select Id,AccountId from Contact where Id=:counter.ContactId LIMIT 1];
                System.debug('counter.AccountID'+counter.AccountID);
                System.debug('counter.Contact.AccountId'+counter.Contact.AccountId);
                if(counter.AccountID!=counter.Contact.AccountId)
                {
                    counter.AccountId = counter.Contact.AccountId;
                    lstCaseUpdated.add(counter);
                }
            }
        }
        if(lstCaseUpdated.size()>0)
        {update lstCaseUpdated;}
    }
    
}