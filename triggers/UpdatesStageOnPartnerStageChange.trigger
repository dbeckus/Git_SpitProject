/*
 * Updates opportunity stage to Discovery if PartnerStage is changed and is not closed won
 */
trigger UpdatesStageOnPartnerStageChange on Opportunity (before update) 
{
    for(Opportunity opp : Trigger.new)
    {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if(opp.PartnerStage__c != oldOpp.PartnerStage__c && !(opp.IsClosed && opp.IsWon))
        {
            opp.StageName = 'Discovery';
        }
    }
}