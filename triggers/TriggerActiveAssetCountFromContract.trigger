trigger TriggerActiveAssetCountFromContract on Contract (after update) {
    Set<Id> acctIds= new Set<Id>();
    List<Account> updatingAccounts= new List<Account>();
   /* if(Trigger.isDelete)
    {
        for(Contract con : Trigger.old)
        {
            if(con.AccountId!=null && con.Contract_Type__c!='Evaluation')
            {
                acctIds.add(con.AccountId);
            }
        }
    }
    else if(Trigger.isInsert || Trigger.isUndelete)
    {
        for(Contract con : Trigger.New)
        {
            if(con.AccountId!=null && con.Contract_Type__c!='Evaluation')
            {
                acctIds.add(con.AccountId);
            }
        }
    }
    else
    {*/
        //isUpdate
        for(Contract con : Trigger.new)
        {
            Contract oldContract = Trigger.oldMap.get(con.Id);
            if(oldContract.AccountId != con.AccountId)
            {
                if(con.AccountId != null && con.Contract_Type__c!='Evaluation')
                {
                    acctIds.add(con.AccountId);
                }
                if(oldContract.AccountId != null && con.Contract_Type__c!='Evaluation')
                {
                    acctIds.add(oldContract.AccountId);
                }
            }
            if(oldContract.Status != con.Status)
            {
                if(con.AccountId != null && con.Contract_Type__c!='Evaluation')
                {
                    acctIds.add(con.AccountId);
                }
            }
            
        }
   // }
    if(acctIds.size() > 0)
    {
        for(Id counter: acctIds)
        {
            updatingAccounts.add(new Account(Id = counter, Trigger_Active_Asset_Count__c=true));
        }
        
    }
    if(updatingAccounts.size()>0)
    {
        update updatingAccounts;
    }
    
}