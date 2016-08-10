public class ShareMDFToPartnerHelper
{
    public static void shareMDFs(List<MDF_Request__c> mdfs)
    {
        List<MDF_Request__Share> mdfShares = new List<MDF_Request__Share>();
        Set<Id> accIds = new Set<Id>();
        for(MDF_Request__c request : mdfs)
        {
            accIds.add(request.Account__c);
        }
        Map<Id, Id> portalUsers = getPortalUserRoles(new List<Id>(accIds));
        
        for(MDF_Request__c mdf : mdfs)
        {
            if(mdf.Account__c != null && portalUsers.get(mdf.Account__c) != null)
            {
                mdfShares.add(new MDF_Request__Share(ParentId = mdf.Id, UserOrGroupId = portalUsers.get(mdf.Account__c), AccessLevel = 'Edit'));
            }
        }
        Database.insert(mdfShares, false);
    }
    
    //returns a map with accountId => portal user group Id
    private static Map<Id, Id> getPortalUserRoles(List<Id> accIds)
    {
        Map<Id, Id> result = new Map<Id, Id>();
        List<UserRole> portalRoleList = [select Id, PortalAccountId from UserRole where PortalType='Partner' and PortalRole='Manager' and PortalAccountId in :accIds];
        List<Group> groups = [select Id, RelatedId from Group where RelatedId in :portalRoleList];
        for(UserRole role : portalRoleList)
        {
            for(Group g : groups)
            {
                if(role.Id == g.RelatedId)
                {
                    result.put(role.PortalAccountId, g.Id);
                    break;
                }
            }
        }
        return result;
    }
}