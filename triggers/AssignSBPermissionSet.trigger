trigger AssignSBPermissionSet on User (after insert) {
    List<PermissionSetAssignment> lstPermissionSetAssignment= new List<PermissionSetAssignment>();
    Set<Id> profileIds = new Set<Id>();
    //Adding elements in Array
    profileIds.add('00e50000000vvsg');
    profileIds.add('00e50000000vMfm');
    profileIds.add('00e50000000vvsq');
    profileIds.add('00e50000000vucz');
    profileIds.add('00e50000000vvBM');
    profileIds.add('00e50000000vMPT');
    profileIds.add('00e38000001Buca');
    
    for(User usr:Trigger.New)
    {
        if(profileIds.contains(usr.ProfileId))
        {
            PermissionSetAssignment obj= new PermissionSetAssignment();
            obj.AssigneeId=usr.Id;
            obj.PermissionSetId='0PS38000000LQeF';
            lstPermissionSetAssignment.add(obj);
            
            PermissionSetAssignment obj1= new PermissionSetAssignment();
            obj1.AssigneeId=usr.Id;
            obj1.PermissionSetId='0PS38000000Xzp1';
            lstPermissionSetAssignment.add(obj1);
            
        }
    }
    if(!Test.isRunningTest())
    {
        if(lstPermissionSetAssignment.size()>0)
        {
            insert lstPermissionSetAssignment;
        }
    }
    
    
}