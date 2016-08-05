global class OpportunityPocStatusBatchJob implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([select Id from Account]);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> accts)
    {
        List<Opportunity> opportunities = [select Id, Has_Active_POCs__c, AccountId, (select Id, IsClosed__c from Requests__r where IsClosed__c  != true) from Opportunity where AccountId in : accts];
        List<Account> accounts = [select Id, Has_Active_POCs__c from Account where  Id in : accts];
        List<Opportunity> updatingOpps = new List<Opportunity>();
        List<Account> updatingAccts = new List<Account>();
        for(Opportunity opp : opportunities)
        {
            Boolean oldValue = opp.Has_Active_POCs__c;
            opp.Has_Active_POCs__c = false;
            for(Request__c poc : opp.Requests__r)
            {
                if(!poc.IsClosed__c)
                {
                    opp.Has_Active_POCs__c = true;
                    break;
                }
            }
            if(oldValue != opp.Has_Active_POCs__c)
            {
                opp.Bypassing_Validation__c = true;
                updatingOpps.add(opp);
            }
        }
        for(Account acct : accounts)
        {
            Boolean oldValue = acct.Has_Active_POCs__c;
            acct.Has_Active_POCs__c = false;
            for(Opportunity opp : updatingOpps)
            {
                if(acct.Id == opp.AccountId)
                {
                    acct.Has_Active_POCs__c = true;
                    break;
                }
            }
            if(oldValue != acct.Has_Active_POCs__c)
            {
                updatingAccts.add(acct);
            }
        }
        if(updatingOpps.size() > 0)
        {
            update updatingOpps;
            update updatingAccts;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {   
    }

}