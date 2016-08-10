/*
 * Adds a default competitor to opportunity if the opportunity is set to "Closed Won" and contains no competitor
 * the name of the default competitor is "Not Specified"
 */
trigger AddDefaultCompetitorName on Opportunity (after update) 
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Set<Id> oppIds = new Set<Id>();
        List<OpportunityCompetitor> newCompetitors = new List<OpportunityCompetitor>();
        for(Opportunity opp : Trigger.new)
        {
            Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
            if(opp.StageName != oldOpp.StageName && opp.StageName == 'Closed Won')
            {
                oppIds.Add(opp.Id);
            }
        }
        if(oppIds.size() > 0)
        {
            List<Opportunity> oppList = [select Id, (select OpportunityID from OpportunityCompetitors limit 1) from Opportunity where Id in :oppIds];
            for(Opportunity opp : oppList)
            {
                if(opp.OpportunityCompetitors.size() == 0)
                {
                    OpportunityCompetitor competitor = new OpportunityCompetitor(OpportunityID = opp.Id, CompetitorName = 'Not Specified');
                    newCompetitors.add(competitor);
                }
            }
            if(newCompetitors.size() > 0)
            {
                insert newCompetitors;
            }
        }
    }
}