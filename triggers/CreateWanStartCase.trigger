/*
 * when an opp closes won with a wanstart SKU, creates a case
 */
trigger CreateWanStartCase on Opportunity (after update) 
{
    Id TechSupportQueue = '00G30000000mEL4';
    List<Case> cases = new List<Case>();
    Set<Id> oppIds = new Set<Id>();
 
    if(!SilverPeakUtils.BypassingTriggers)
    {   
        for(Opportunity opp : Trigger.new)
        {
            if (opp.WANstartCaseCreated__c == null)
            {
                opp.WANstartCaseCreated__c = false;
            }
            if (opp.IsWon && opp.WANstart_count__c > 0 && opp.WANstartCaseCreated__c == false && isUpdatedStageOrWanStart(opp, Trigger.oldMap.get(opp.Id)))
            {
                oppIds.add(opp.Id);
            }
        }
        if(oppIds.size() > 0)
        {
            List<Opportunity> opps = new List<Opportunity>();
            for(Opportunity opp : [select Id, AccountId, Account.Name, Technical_Responsible__c, (select Id from OpportunityLineItems where PricebookEntry.ProductCode='300019-002') from Opportunity where Id in :oppIds])
            {
                if (opp.AccountId != null)
                {
                    Case newCase = new Case(Subject='New WANstart for ' + opp.Account.Name, AccountId=opp.AccountId);
                    if(opp.Technical_Responsible__c != null)
                    {
                        newCase.OwnerId = opp.Technical_Responsible__c;
                    }
                    else
                    {
                        newCase.OwnerId = TechSupportQueue;
                    }
                    if(opp.OpportunityLineItems.size() > 0)
                    {
                        newCase.Type = 'WANstart Services';
                        newCase.Status = 'Staged';
                    }
                    else
                    {
                        newCase.Type = 'WANstart Bundled';
                        newCase.Status = 'Staged';
                    }
                    cases.add(newCase);
                    opps.add(new Opportunity(Id=opp.Id, WANstartCaseCreated__c=true));
                }
            }
            if(cases.size() > 0)
            {
                try
                {
                    insert cases;
                    update opps;
                }
                catch(Exception ex)
                {
                    Trigger.new[0].addError(ex.getMessage());
                }
            }
        }
    }
    
    private Boolean isUpdatedStageOrWanStart(Opportunity newOpp, Opportunity oldOpp)
    {
        return newOpp.IsWon != oldOpp.IsWon || newOpp.WANstart_count__c != oldOpp.WANstart_count__c || newOpp.WANstartCaseCreated__c != oldOpp.WANstartCaseCreated__c;
    }
}