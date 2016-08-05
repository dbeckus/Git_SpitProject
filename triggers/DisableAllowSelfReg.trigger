trigger DisableAllowSelfReg on User (after update) {
  
    Set<Id> conList= new Set<Id>();
    for(User usr: Trigger.New)
    {
        User oldUser=Trigger.OldMap.get(usr.Id);
        if(oldUser.IsActive!=usr.IsActive && !usr.IsActive && ((usr.UserType=='Customer Portal Manager')||(usr.UserType=='Customer Portal User')||(usr.UserType=='PowerCustomerSuccess')))
        {
           
            conList.add(oldUser.ContactId);
        }
    }
    if(conList.size()>0)
    {
        ContactOwnershipHelper.DisableAllowSelfReg(conList);
    }
}