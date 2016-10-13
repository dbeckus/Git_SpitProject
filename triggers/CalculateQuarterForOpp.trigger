trigger CalculateQuarterForOpp on Opportunity (before insert,before update) {
    List<Opportunity> lstOpp= new List<Opportunity>();
    List<Opportunity> lstOppToUpdate= new List<Opportunity>();
    
    for(Opportunity opp: Trigger.New)
    {
        if(Trigger.IsInsert)
        {
            List<Period> currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <=:opp.CloseDate AND EndDate >=:opp.CloseDate limit 1];
            if(currentPeriod !=null && currentPeriod.size()>0)
            {
                string currentFiscalQuarter = currentPeriod[0].FiscalYearSettings.Name + 'Q' + currentPeriod[0].Number;
                opp.Fiscal_Quarter_Name__c=currentFiscalQuarter;
            }
            else
            {
                opp.Fiscal_Quarter_Name__c=null;
            }
            
        }
        if(Trigger.IsUpdate)
        {
            Opportunity oldOpp=Trigger.OldMap.get(opp.Id);
            if(opp.CloseDate!=oldOpp.CloseDate)
            {
                
                List<Period> currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <=:opp.CloseDate AND EndDate >=:opp.CloseDate limit 1];
                if(currentPeriod !=null && currentPeriod.size()>0)
                {
                    string currentFiscalQuarter = currentPeriod[0].FiscalYearSettings.Name + 'Q' + currentPeriod[0].Number;
                    opp.Fiscal_Quarter_Name__c=currentFiscalQuarter;
                    
                }
                else
                {
                    opp.Fiscal_Quarter_Name__c=null;
                }
            }
        }
        
    }
    
}