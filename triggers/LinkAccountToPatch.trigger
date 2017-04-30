/*
 * Links account to a matching patch on new account insert or certain fields update.
 * In the before trigger, links patch; In the after trigger, creates account team members.
 */ 
trigger LinkAccountToPatch on Account (after insert, after update) 
{
    List<Id> accNeedsPatchAssign = new List<Id>();
    List<Id> accNeedsTeamAssign  = new List<Id>();
    Set<Id> accPatchChanged      = new Set<Id>(); //list to get accounts for which opps should be updated. 
    
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
                accPatchChanged.add(acc.Id);   
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
    if(accPatchChanged.size() > 0){
        assocOpps(); //Update associated opps patch if Account patch is changed. 
    }
    
    private static void assocOpps()
    {  
       List<Opportunity> lstAssocOpps = [Select Id, Account.Id, StageName, Trigger_Assignment__c from Opportunity where
                                         Patch_Locked__c=False and Account.Id =:accPatchChanged and (NOT StageName Like '%Closed%')];
       List<Opportunity> lstFinalOpps = new List<Opportunity>();
        if(lstAssocOpps.size()>0 && lstAssocOpps!=Null )
        {
             for(Opportunity o: lstAssocOpps){
                 Opportunity accOpp = new Opportunity();
                 accOpp.Id= o.Id;
                 accOpp.Trigger_Assignment__c = True;
                 lstFinalOpps.add(accOpp);
             }
            if(lstFinalOpps.size()>0){ 
            update lstFinalOpps;
            } 
        }    
    }   
}