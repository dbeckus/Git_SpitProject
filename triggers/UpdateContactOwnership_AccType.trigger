trigger UpdateContactOwnership_AccType on Account (after update) {
    Set<Id> acctIds= new Set<Id>();
    if(Trigger.IsUpdate)
    {
        for(Account acc : Trigger.New)
        {
            Account oldAcc = Trigger.oldMap.get(acc.Id);
            if(acc.Patch__c != oldAcc.Patch__c || acc.Type != oldAcc.Type)
            {
                acctIds.add(acc.Id);
             
            }
        }
        ContactOwnershipHelper.UpdateContactOwnership_Bulk(acctIds);
        
    }
    
    
    
}