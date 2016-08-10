/*
 * Keep Opportunity.HasActivePoc up to date
 * Active pocs depend on Request.IsClosed field
 */
trigger UpdatePocStatusToOpportunity on Request__c (after insert, after update, after delete, after undelete) 
{
    Set<Id> opportunityIds = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Request__c request : Trigger.new)
        {
            opportunityIds.add(request.Opportunity__c);
        }
    }
    else if(Trigger.isUpdate)
    {
        for(Request__c request : Trigger.new)
        {
            Request__c oldRequest = Trigger.oldMap.get(request.Id);
            if(request.Status__c != oldRequest.Status__c)
            {
                opportunityIds.add(request.Opportunity__c);
            }
            if(request.Opportunity__c != oldRequest.Opportunity__c)
            {
                opportunityIds.add(request.Opportunity__c);
                opportunityIds.add(oldRequest.Opportunity__c);
            }
        }
    }
    else if(Trigger.isDelete)
    {
        for(Request__c request : Trigger.old)
        {
            opportunityIds.add(request.Opportunity__c);
        }
    }
    else if(Trigger.isUndelete)
    {
        for(Request__c request : Trigger.new)
        {
            opportunityIds.add(request.Opportunity__c);
        }
    }
    opportunityIds.remove(null);
    if(opportunityIds.size() > 0)
    {
        List<Opportunity> opps = [select Id, Has_Active_POCs__c, AccountId, Account.Has_Active_POCs__c, Account.POC_Request_Date__c, (select Id from Requests__r where IsClosed__c=false limit 1) from Opportunity where Id in :opportunityIds and StageName!='Closed Deleted'];
        Set<Id> accIds = new Set<Id>();
        for(Opportunity opp : opps)
        {
            opp.Has_Active_POCs__c = opp.Requests__r.size() > 0;
            if(opp.Has_Active_POCs__c == true && opp.POC_History__c == false)
            {
                opp.POC_History__c = true;
            }
            opp.Bypassing_Validation__c = true;
            accIds.add(opp.AccountId);
        }
        try
        {
            update opps;
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
        List<Account> accs = [select Id, POC_Request_Date__c, Has_Active_POCs__c, (select Id from Opportunities where Has_Active_POCs__c=true limit 1) from Account where Id in :accIds];
        for(Account acc : accs)
        {
            acc.Has_Active_POCs__c = acc.Opportunities.size() > 0;
            if(acc.POC_Request_Date__c == null)
            {
                acc.POC_Request_Date__c = Date.today();
            }
        }
        try
        {
            update accs;
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
}