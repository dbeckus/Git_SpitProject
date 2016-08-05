/*
 * Sets Bypassing_Validation to false after it's set to true
 * The flag is used to bypass validation rules on opp
 */
trigger ClearBypassingValidationFlag on Opportunity (after insert, after update) 
{
    /*List<Opportunity> opps = new List<opportunity>();
    for(Opportunity opp : Trigger.new)
    {
        if(opp.Bypassing_Validation__c == true)
        {
            opps.add(new Opportunity(Id=opp.Id, Bypassing_Validation__c=false));
        }
    }
    if(opps.size() > 0)
    {
        SilverPeakUtils.BypassingTriggers = true;
        Database.SaveResult[] results = Database.update(opps, false);
        SilverPeakUtils.BypassingTriggers = false;
        SilverPeakUtils.logDatabaseError(opps, results);
    }*/
}