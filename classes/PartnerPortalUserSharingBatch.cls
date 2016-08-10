public class PartnerPortalUserSharingBatch implements Database.Batchable<sObject>
{
    private List<Id> relevantAccounts;
    
    public PartnerPortalUserSharingBatch()
    {
    }
    
    public PartnerPortalUserSharingBatch(List<Id> accountIds)
    {
        relevantAccounts = accountIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(!Test.isRunningTest())
        {
            if(relevantAccounts == null || relevantAccounts.size() == 0)
            {
                return Database.getQueryLocator([select Id from User where UserType='PowerPartner' and IsActive=true]);
            }
            else
            {
                return Database.getQueryLocator([select Id from User where UserType='PowerPartner' and IsActive=true and Contact.AccountId in :relevantAccounts]);
            }
        }
        else
        {    
            return Database.getQueryLocator([select Id from User where UserType='PowerPartner' and IsActive=true limit 1]);
        }
    }
    
    public void execute (Database.BatchableContext bc, List<sObject> scope)
    {
        List<Id> userIds = new List<Id>();
        for(sObject user : scope)
        {
            userIds.add(user.Id);
        }
        PartnerPortalUserSharing.sharePortalUser(userIds);
    }
    
    public void finish(Database.BatchableContext bc){}
}