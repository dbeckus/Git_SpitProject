trigger UpdateOppTypeforAccount on Account (after update) {
    Map<Id,string> accids= new Map<Id,string>();
    List<Opportunity> allOppsToUpdate= new List<Opportunity>();
    for(Account acc:Trigger.new)
    {
        Account oldAcc=Trigger.OldMap.get(acc.Id);
        if(acc.First_Asset_Quarter__c!=oldAcc.First_Asset_Quarter__c)
        {
            accids.put(acc.Id,acc.First_Asset_Quarter__c);
        }
    }
    for(Id item: accIds.keyset())
    {
        List<Opportunity> lstAllOpp=[Select Id, CloseDate,Fiscal_Quarter_Name__c,Type from Opportunity where AccountId=:item and StageName not in ('Closed Dead','Closed Deleted','Closed Lost')];
        if(lstAllOpp!=null && lstAllOpp.size()>0)
        {
            
            for(Opportunity opp: lstAllOpp)
            {
                if(opp.Type==null|| opp.Type=='New Business'|| opp.Type=='Follow on Business')
                {
                    string type='New Business';
                    string recordTypeId='012500000005bUW';
                    if(accids.get(item)!=null && opp.Fiscal_Quarter_Name__c!=accids.get(item))
                    {
                        type='Follow on Business';
                        recordTypeId='012500000005bUb';
                    }
                    opp.Type= type;
                    opp.RecordTypeId=recordTypeId;
                    allOppsToUpdate.add(opp);
                }
                
            }
            
            
        }
    }
    
    if(allOppsToUpdate.size()>0)
    {
        update allOppsToUpdate;
    }
}