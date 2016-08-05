/*
 *   Set POC_Summary_Started__c of Opportunity to true if POC Summary is inserted
 */
trigger CheckPOCSummaryStarted on POC_Summary__c (after insert) 
{
    List<Opportunity> opps = new List<Opportunity>();
    for(POC_Summary__c pocSummary : Trigger.new)
    {
        opps.add(new Opportunity(Id = pocSummary.POC_For__c, POC_Summary_Started__c = true));
    }
    
    try
    {
        update opps;
    }
    catch(Exception ex)
    {
        Trigger.new[0].addError(ex.getMessage());
    }
}