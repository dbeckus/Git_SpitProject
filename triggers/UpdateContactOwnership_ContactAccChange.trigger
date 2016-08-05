trigger UpdateContactOwnership_ContactAccChange on Contact (after insert,after update) {
    Set<Id> acctIds= new Set<Id>();
    if(Trigger.IsInsert)
    {
        for(Contact con : Trigger.New)
        {
            if(con.AccountId!=null)
            {
                acctIds.add(con.AccountId);
            } 
        }
        
    }
    if(Trigger.IsUpdate)
    {
        for(Contact con : Trigger.New)
        {
            Contact oldCon = Trigger.oldMap.get(con.Id);
            if(oldCon.AccountId!=con.AccountId)
            {
                acctIds.add(con.AccountId);
                
            }
        }
    }
    if(acctIds.size()>0)
    {
        for(Id accId: acctIds)
        {
            ContactOwnershipHelper.UpdateContactOwnership(accId);
        }
    }
    
}