trigger DisableSelfRegOnAccount on Account (after update) {
    
    Set<Id>accIds= new Set<Id>();
    for(Account acc:Trigger.New)
    {
        Account oldAcc= Trigger.OldMap.get(acc.Id);
        if(!acc.IsCustomerPortal && oldAcc.IsCustomerPortal)
        {
            accIds.add(acc.Id);
        }
        
    }
    if(accIds.size()>0)
    {
        List<Contact> lstCon=[Select Id from Contact where AccountId in: accIds and CanAllowPortalSelfReg=true];
        Set<Id> conIds= new Set<Id>();
        for(Contact con: lstCon)
        {
            conIds.add(con.Id);
        }
        
        ContactOwnershipHelper.DisableAllowSelfReg(conIds);
    }
}