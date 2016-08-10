/*
 * Links opportunity to a matching patch on new opp insert or certain fields update.
 * In the before trigger, links patch; In the after trigger, creates opportunity team members.
 */ 
trigger LinkOpportunityToPatch on Opportunity (after insert, after update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<Id> oppNeedsPatchAssign = new Set<Id>();
        Set<Id> oppNeedsTeamAssign = new Set<Id>();
        if(Trigger.isInsert)
        {
            for(Opportunity opp : Trigger.new)
            {
                if(opp.Type != 'Marketplace')
                {
                    if(opp.Patch__c == null)
                    {
                        oppNeedsPatchAssign.add(opp.Id);
                    }
                    else
                    {
                        oppNeedsTeamAssign.add(opp.Id);
                    }
                }
            }
        }
        else if(Trigger.isUpdate)
        {
            for(Opportunity opp : Trigger.new)
            {
                if(opp.Type != 'Marketplace' && opp.IsClosed == false)
                {
                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                    if(opp.Patch_Locked__c == false)
                    {
                        if(opp.Trigger_Assignment__c || opp.AccountId != oldOpp.AccountId)
                        {
                            oppNeedsPatchAssign.add(opp.Id);
                            oppNeedsTeamAssign.add(opp.Id);
                            continue;
                        }
                    }
                    if(opp.Patch__c != oldOpp.Patch__c || opp.Trigger_Assignment__c || opp.OwnerId != oldOpp.OwnerId)
                    {
                        oppNeedsTeamAssign.add(opp.Id);
                    }
                }
            }
        }
        //When opp is converted from lead, it will be updated twice to have the fields populated. 
        //We need the patch be assigned after all fields populated, so put the patch assignment to future method
        if(oppNeedsPatchAssign.size() > 0)
        {
            if(System.isFuture() || System.isBatch())
            {
                PatchRuleHelper.assignPatch(new List<Id>(oppNeedsPatchAssign));
            }
            else
            {
                PatchRuleHelper.willAssignPatch(new List<Id>(oppNeedsPatchAssign));
                    
                List<Opportunity> opps = new List<Opportunity>();
                for(Id oppId : oppNeedsPatchAssign)
                {
                    opps.add(new Opportunity(Id=oppId, Trigger_Assignment__c=false, Bypassing_Validation__c=true));
                }
                update opps;
            }
        }
        if(oppNeedsTeamAssign.size() > 0)
        {
            PatchRuleHelper.assignTeamMembers(new List<Id>(oppNeedsTeamAssign));
        }
    }
}