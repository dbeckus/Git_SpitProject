/*
 * Links lead to a matching patch on new lead insert or certain fields update.
 * In the before trigger, links patch; In the after trigger, shares lead to patch members.
 */ 
trigger LinkLeadToPatch on Lead (before insert, after insert, before update, after update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        if(Trigger.isBefore && Trigger.isInsert)
        {
            List<Lead> leadsNeedAssignment = new List<Lead>();
            for(Lead lead : Trigger.new)
            {
                if(lead.Patch__c == null)
                {
                    leadsNeedAssignment.add(lead);
                }
            }
            PatchRuleHelper.assignPatches(leadsNeedAssignment);
        }
        else if(Trigger.isBefore && Trigger.isUpdate)
        {
            List<Lead> leadsNeedAssignment = new List<Lead>();
            for(Lead lead : Trigger.new)
            {
                if(!lead.IsConverted)
                {
                    Lead oldLead = Trigger.oldMap.get(lead.Id);
                    PatchRuleEngineBase.Target target = PatchRuleHelper.getTarget(lead);
                    PatchRuleEngineBase.Target oldTarget = PatchRuleHelper.getTarget(oldLead);
                    if(lead.Trigger_Assignment__c || !PatchRuleHelper.isSameTarget(target, oldTarget))
                    {
                        leadsNeedAssignment.add(lead);
                        PatchRuleHelper.leadsNeedAssignment.add(lead.Id);
                    }
                }
            }
            if(leadsNeedAssignment.size() > 0)
            {
                PatchRuleHelper.assignPatches(leadsNeedAssignment);
            }
        }
        else if(Trigger.isAfter)
        {
            if(Trigger.isInsert)
            {
                for(Lead lead : Trigger.new)
                {
                    PatchRuleHelper.leadsNeedAssignment.add(lead.Id);
                }
            }
            if(PatchRuleHelper.leadsNeedAssignment.size() > 0)
            {
                PatchRuleHelper.assignTeamMembers(PatchRuleHelper.leadsNeedAssignment);
                PatchRuleHelper.leadsNeedAssignment = new List<Id>();
            }
        }
    }
}