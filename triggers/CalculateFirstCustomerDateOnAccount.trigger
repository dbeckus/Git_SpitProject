trigger CalculateFirstCustomerDateOnAccount on Opportunity (after update) {
    Set<Id> lstAcc= new Set<Id>();
    List<Account> lstAccToUpdate= new List<Account>();
    
    for(Opportunity opp: Trigger.New)
    {
        Opportunity oldOpp= Trigger.OldMap.get(opp.Id);
        if(opp.StageName!=oldOpp.StageName || (opp.CloseDate!=oldOpp.CloseDate && opp.StageName=='Closed Won' ))
        {
            if(opp.AccountId!=null)
            {
                lstAcc.add(opp.AccountId);
            }
            
        }
        
    }
    
    if(lstAcc.size()>0)
    {
        for(Id item: lstAcc)
        {
            Date minDate=null;
            boolean partnerInitated;
            List<Opportunity> lstOpp=[Select Id, CloseDate,Deal_Reg__c from Opportunity where AccountId=:item and StageName='Closed Won' order by CloseDate asc];
            Account currAcc=[Select Id ,First_Asset_Quarter__c,Is_Partner_Initiated_Account__c from Account where Id=:item];
            if(lstOpp!=null && lstOpp.size()>0)
            {
                minDate= lstOpp[0].CloseDate;
                partnerInitated=lstOpp[0].Deal_Reg__c;
                Period currentPeriod = [Select Type, StartDate, EndDate, QuarterLabel, PeriodLabel, Number, FiscalYearSettings.Name From Period  where Type ='Quarter' and StartDate <=:minDate AND EndDate >=:minDate limit 1];
                string currentFiscalQuarter = currentPeriod.FiscalYearSettings.Name + 'Q' + currentPeriod.Number;
                if(currAcc.First_Asset_Quarter__c!=currentFiscalQuarter || currAcc.Is_Partner_Initiated_Account__c!=partnerInitated)
                {
                   
                    lstAccToUpdate.add(new Account(Id=item,First_Asset_Quarter__c=currentFiscalQuarter,Is_Partner_Initiated_Account__c=partnerInitated));
                }
            } 
            else
            {
                lstAccToUpdate.add(new Account(Id=item,First_Asset_Quarter__c='',Is_Partner_Initiated_Account__c=false));
            }
        }
    }
    if(lstAccToUpdate.size()>0)
    {
        update lstAccToUpdate;
    }
}