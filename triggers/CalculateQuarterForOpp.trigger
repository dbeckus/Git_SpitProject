trigger CalculateQuarterForOpp on Opportunity (before insert,before update) {
    List<Opportunity> lstOpp= new List<Opportunity>();
    List<Opportunity> lstOppToUpdate= new List<Opportunity>();
    
    for(Opportunity opp: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            Period currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <=:opp.CloseDate AND EndDate >=:opp.CloseDate limit 1];
            if(currentPeriod !=null)
            {
                string currentFiscalQuarter = currentPeriod.FiscalYearSettings.Name + 'Q' + currentPeriod.Number;
                opp.Fiscal_Quarter_Name__c=currentFiscalQuarter;
                
            }
            
        }
        if(Trigger.IsUpdate)
        {
            Opportunity oldOpp=Trigger.OldMap.get(opp.Id);
            if(opp.CloseDate!=oldOpp.CloseDate)
            {
                
                Period currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <=:opp.CloseDate AND EndDate >=:opp.CloseDate limit 1];
                if(currentPeriod !=null)
                {
                    string currentFiscalQuarter = currentPeriod.FiscalYearSettings.Name + 'Q' + currentPeriod.Number;
                    opp.Fiscal_Quarter_Name__c=currentFiscalQuarter;
                    
                }
            }
        }
        
    }
    
}