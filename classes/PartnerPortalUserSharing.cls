/*
 * Helper class includes method to add partner portal users to geo related groups
 */
public class PartnerPortalUserSharing
{
    public static void sharePortalUser(List<Id> userIds)
    {
        Map<String, Id> groupsMap = getPublicGroups();
        if(userIds != null && !userIds.isEmpty())
        {
            List<GroupMember> newGroupMembers = new List<GroupMember>();
            String geo, accountName;
            for(User userNew : [select Contact.Account.Name, Contact.Account.GEO_Supported__c from User where Id in :userIds])
            {
                accountName = userNew.Contact.Account.Name;
                geo = userNew.Contact.Account.GEO_Supported__c;
                newGroupMembers.addAll(addNewGroups(groupsMap, geo, accountName, userNew.Id));
            }

            if(!newGroupMembers.isEmpty())
            {
                Database.insert(newGroupMembers, false);
            }           
        }
    }
    
    public static void removeSharingPortalUser(List<Id> userIds)
    {
        if(userIds != null && !userIds.isEmpty())
        {
            Database.delete([select Id from GroupMember where UserOrGroupId in :userIds], false);
        }
    }
    
    public static void sharePortalUserOnAccount(List<Id> accountIds)
    {
        if(accountIds != null && !accountIds.isEmpty())
        {
            List<User> users = [select Id from User where Contact.AccountId in :accountIds and UserType='PowerPartner' and IsActive=true];
            List<Id> userIds = new List<Id>();
            for(User usr : users)
            {
                userIds.add(usr.Id);
            }
            removeSharingPortalUser(userIds);
            sharePortalUser(userIds);
        }
    }
    
    private static Map<String, Id> getPublicGroups()
    {
        Map<String, Id> result = new Map<String, Id>();
        for(Group grp : [select Id, DeveloperName from Group where DeveloperName in ('Partner_Portal_APAC', 'Partner_Portal_EMEA', 'Partner_Portal_LAT', 'Partner_Portal_NA_GAM', 'Partner_Portal_Dell')])
        {
            result.put(grp.DeveloperName, grp.Id); 
        }
        return result;
    }
    
    private static List<GroupMember> addNewGroups(Map<String, Id> allGroups, String geo, String accountName, Id userId)
    {
        List<GroupMember> result = new List<GroupMember>();
        geo = (geo == null) ? '' : geo;
        if(allGroups.containsKey('Partner_Portal_APAC') && (geo.contains('APAC') || geo.contains('All')))
        {
            result.add(new GroupMember(UserOrGroupId = userId, GroupId = allGroups.get('Partner_Portal_APAC')));
        }
        if(allGroups.containsKey('Partner_Portal_EMEA') && (geo.contains('EMEA') || geo.contains('All')))
        {
            result.add(new GroupMember(UserOrGroupId = userId, GroupId = allGroups.get('Partner_Portal_EMEA')));
        }
        if(allGroups.containsKey('Partner_Portal_NA_GAM') && (geo.contains('NAM') || geo.contains('All')))
        {
            result.add(new GroupMember(UserOrGroupId = userId, GroupId = allGroups.get('Partner_Portal_NA_GAM')));
        }
        if(allGroups.containsKey('Partner_Portal_LAT') && (geo.contains('LAT') || geo.contains('All')))
        {
            result.add(new GroupMember(UserOrGroupId = userId, GroupId = allGroups.get('Partner_Portal_LAT')));
        }
        if(allGroups.containsKey('Partner_Portal_Dell') && isDellCompany(accountName))
        {
            result.add(new GroupMember(UserOrGroupId = userId, GroupId = allGroups.get('Partner_Portal_Dell')));
        }
        return result;
    }
    
    private static Boolean isDellCompany(String accName)
    {
        accName = (accName == null) ? '' : accName;
        Pattern p = Pattern.compile('(^|\\W)[Dd][Ee][Ll][Ll]($|\\W)');
        Matcher m = p.matcher(accName);
        return m.matches() || m.find();
    }
}