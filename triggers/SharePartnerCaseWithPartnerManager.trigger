trigger SharePartnerCaseWithPartnerManager on Case (after insert,after update) {
    Set<Id> caseId= new Set<Id>();
    if(Trigger.IsInsert)
    {
        for(Case item: Trigger.New)
        {
            
        }
    }
    if(Trigger.IsUpdate)
    {
        
    }

}