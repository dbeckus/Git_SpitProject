/*
 * Copies new mdf to Account.MDF_Requested
 * Copies approved mdf to Account.MDF_Approved
 */
trigger CopyMdfToAccount on MDF_Request__c (after insert, after update) 
{
    Set<Id> accountIds = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(MDF_Request__c mdf : Trigger.new)
        {
            accountIds.add(mdf.Account__c);
        }
    }
    else if(Trigger.isUpdate)
    {
        for(MDF_Request__c mdf : Trigger.new)
        {
            MDF_Request__c oldMdf  = Trigger.oldMap.get(mdf.Id);
            if(mdf.Approval_Status__c == 'Approved' && oldMdf.Approval_Status__c != 'Approved' || oldMdf.Account__c != mdf.Account__c)
            {
                accountIds.add(mdf.Account__c);
            }
        }
    }
    accountIds.remove(null);
    List<Account> updatingAccounts = new List<Account>();
    if(accountIds.size() > 0)
    {
        List<AggregateResult> allMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds group by Account__c];
        List<AggregateResult> approvedMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds and Approval_Status__c='Approved' group by Account__c];
        
        for(Id accId : accountIds)
        {
            updatingAccounts.add(new Account(Id=accId, Total_Requested_MDF__c=0, Total_Approved_MDF__c=0));
        }
        for(AggregateResult r :  allMdfs)
        {
            Id accId = (Id)r.get('a');
            Decimal amount = (Decimal)r.get('c');
            for(Account acc : updatingAccounts)
            {
                if(acc.Id == accId)
                {
                    acc.Total_Requested_MDF__c = amount;
                    break;
                }
            }
        }
        for(AggregateResult r :  approvedMdfs)
        {
            Id accId = (Id)r.get('a');
            Decimal amount = (Decimal)r.get('c');
            for(Account acc : updatingAccounts)
            {
                if(acc.Id == accId)
                {
                    acc.Total_Approved_MDF__c = amount;
                    break;
                }
            }
        }
    }
    if(updatingAccounts.size() > 0)
    {
        Database.update(updatingAccounts, false);
    }
}