/*
 * Links account to a matching patch on new account insert or certain fields update.
 * In the before trigger, links patch; In the after trigger, creates account team members.
 */ 
trigger LinkAccountToPatch on Account (after insert, after update) 
{
    List<Id> accNeedsPatchAssign = new List<Id>();
    List<Id> accNeedsTeamAssign = new List<Id>();
    if(Trigger.isInsert)
    {
        for(Account acc : Trigger.new)
        {
            if(acc.Patch__c == null)
            {
                accNeedsPatchAssign.add(acc.Id);
            }
            else
            {
                accNeedsTeamAssign.add(acc.Id);
            }
        }
    }
    else if(Trigger.isUpdate)
    {
        for(Account acc : Trigger.new)
        {
            Account oldAccount = Trigger.oldMap.get(acc.Id);
            if(acc.Patch_Locked__c == false)
            {
                PatchRuleEngine.Target target = PatchRuleHelper.getTarget(acc);
                PatchRuleEngine.Target oldTarget = PatchRuleHelper.getTarget(oldAccount);
                if(acc.Trigger_Assignment__c || !PatchRuleHelper.isSameTarget(target, oldTarget))
                {
                    accNeedsPatchAssign.add(acc.Id);
                }
            }
            if(acc.Patch__c != oldAccount.Patch__c || acc.Trigger_Assignment__c)
            {
                accNeedsTeamAssign.add(acc.Id);
            }
        }
    }
    if(accNeedsPatchAssign.size() > 0)
    {
        PatchRuleHelper.assignPatch(accNeedsPatchAssign);
    }
    if(accNeedsTeamAssign.size() > 0)
    {
        PatchRuleHelper.assignTeamMembers(accNeedsTeamAssign);
    }
}