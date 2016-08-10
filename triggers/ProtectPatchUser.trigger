/*
 * If user is in any patch team, do not allow to disable
 */
trigger ProtectPatchUser on User (before update) 
{
    Set<Id> users = new Set<Id>();
    for(User usr : Trigger.new)
    {
        User oldUsr = Trigger.oldMap.get(usr.Id);
        if(!usr.IsActive && oldUsr.IsActive)
        {
            users.add(usr.Id);
        }
    }
    if(users.size() > 0)
    {
        Set<Id> wrongUsers = new Set<Id>();
        for(Patch__c patch : [select Id, Owner__c, RSM__c, ISR__c, CSM__c, SE__c from Patch__c where Owner__c in :users or RSM__c in :users or ISR__c in :users or CSM__c in :users or SE__c in :users])
        {
            if(users.contains(patch.Owner__c))
            {
                wrongUsers.add(patch.Owner__c);
            }
            if(users.contains(patch.RSM__c))
            {
                wrongUsers.add(patch.RSM__c);
            }
            if(users.contains(patch.ISR__c))
            {
                wrongUsers.add(patch.ISR__c);
            }
            if(users.contains(patch.CSM__c))
            {
                wrongUsers.add(patch.CSM__c);
            }
            if(users.contains(patch.SE__c))
            {
                wrongUsers.add(patch.SE__c);
            }
        }
        for(Id wrongUser : wrongUsers)
        {
            Trigger.newMap.get(wrongUser).addError('This user is in a patch team. You cannot deactivate this user before replacing the team member.');
        }
    }
}