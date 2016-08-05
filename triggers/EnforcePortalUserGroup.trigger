/*
 * After account's GEO is updated, 
 */
trigger EnforcePortalUserGroup on Account (after update) 
{
    List<Id> accIds = new List<Id>();
    for(Account acc : Trigger.new)
    {
        Account oldAcc = Trigger.oldmap.get(acc.Id);
        if(acc.GEO_Supported__c != oldAcc.GEO_Supported__c)
        {
            accIds.add(acc.Id);
        }
    }
    if(accIds.size() > 0)
    {
        PartnerPortalUserSharingBatch job = new PartnerPortalUserSharingBatch(accIds);
        Database.executeBatch(job);
    }
}