trigger CalculatePOCAge on Opportunity (before update) {

    for(Opportunity opp : Trigger.new)
    {
        Opportunity oldOpp = Trigger.Oldmap.get(opp.Id);
        
        Boolean oldActivePOC = oldOpp.Has_Active_POCs__c;
        Boolean newActivePOC = opp.Has_Active_POCs__c;
        
        if(!opp.IsClosed){
         if(oldActivePOC != newActivePOC)
         {
            if(newActivePOC)
            {
               opp.POC_Start_Date__c = Date.today();
               opp.POC_End_Date__c   = Date.today();
               opp.POC_Duration__c   = oldOpp.POC_Age__c;
            }
            else
            {
                opp.POC_End_Date__c   = Date.today();
            }
         }
        }
        else if(opp.IsClosed && !oldopp.IsClosed){
        {
            if(newActivePOC)
            {
            opp.POC_End_Date__c = Date.today();
            }   
        }
        }
    }       
}