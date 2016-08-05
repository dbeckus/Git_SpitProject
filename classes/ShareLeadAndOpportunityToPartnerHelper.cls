public class ShareLeadAndOpportunityToPartnerHelper
{
    @future
    public static void willShareLeads(List<Id> leadIds)
    {
        List<Lead> theLeads = [select Id, Name, OwnerId, Registered_Distributor__c, Registered_Partner__c, Registered_Distributor_Contact__c, Registered_Partner_Sales_Rep__c from Lead where Id in :leadIds];
        shareLeads(theLeads);
    }
    
    public static void shareLeads(List<Id> leadIds)
    {
        shareLeads([select Id, Name, OwnerId, Registered_Distributor__c, Registered_Partner__c, Registered_Distributor_Contact__c, Registered_Partner_Sales_Rep__c from Lead where Id in :leadIds]);
    }
    
    public static void shareLeads(List<Lead> theLeads)
    {
        List<LeadShare> newLeadShares = new List<LeadShare>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Lead ld : theLeads)
        {
            accIds.add(ld.Registered_Distributor__c);
            accIds.add(ld.Registered_Partner__c);
            contactIds.add(ld.Registered_Distributor_Contact__c);
            contactIds.add(ld.Registered_Partner_Sales_Rep__c);
        }
        Map<Id, Id> portalManagers = getPortalManagerRoles(new List<Id>(accIds));
        Map<Id, Id> portalUserIds = getPortalUsers(new List<Id>(contactIds));
        
        for(Lead ld : theLeads)
        {
            if(ld.Registered_Distributor__c != null && portalManagers.get(ld.Registered_Distributor__c) != null)
            {
                newLeadShares.add(new LeadShare(LeadId = ld.Id, UserOrGroupId = portalManagers.get(ld.Registered_Distributor__c), LeadAccessLevel = 'Edit'));
            }
            if(ld.Registered_Partner__c != null && portalManagers.get(ld.Registered_Partner__c) != null)
            {
                newLeadShares.add(new LeadShare(LeadId = ld.Id, UserOrGroupId = portalManagers.get(ld.Registered_Partner__c), LeadAccessLevel = 'Edit'));
            }
            if(ld.Registered_Distributor_Contact__c != null && portalUserIds.get(ld.Registered_Distributor_Contact__c) != null)
            {
                newLeadShares.add(new LeadShare(LeadId = ld.Id, UserOrGroupId = portalUserIds.get(ld.Registered_Distributor_Contact__c), LeadAccessLevel = 'Edit'));
            }
            if(ld.Registered_Partner_Sales_Rep__c != null && portalUserIds.get(ld.Registered_Partner_Sales_Rep__c) != null)
            {
                newLeadShares.add(new LeadShare(LeadId = ld.Id, UserOrGroupId = portalUserIds.get(ld.Registered_Partner_Sales_Rep__c), LeadAccessLevel = 'Edit'));
            }
        }
        Database.insert(newLeadShares, false);
    }
    
    public static void shareOpportunities(List<Id> oppIds)
    {
        shareOpportunities([select Id, Registered_Distributor__c, Registering_Partner__c, Registered_Distributor_Contact__c, Registering_Partner_Sales_Rep__c from Opportunity where Id in :oppIds]);
    }
    
    public static void shareOpportunities(List<Opportunity> opps)
    {
        List<OpportunityShare> newOppShares = new List<OpportunityShare>();
        Set<Id> accIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Opportunity opp : opps)
        {
            accIds.add(opp.Registered_Distributor__c);
            accIds.add(opp.Registering_Partner__c);
            contactIds.add(opp.Registered_Distributor_Contact__c);
            contactIds.add(opp.Registering_Partner_Sales_Rep__c);
        }
        
        Map<Id, Id> portalManagers = getPortalManagerRoles(new List<Id>(accIds));
        Map<Id, Id> portalUserIds = getPortalUsers(new List<Id>(contactIds));
        
        for(Opportunity opp : opps)
        {
            if(opp.Registered_Distributor__c != null && portalManagers.get(opp.Registered_Distributor__c) != null)
            {
                newOppShares.add(new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = portalManagers.get(opp.Registered_Distributor__c), OpportunityAccessLevel = 'Edit'));
            }
            if(opp.Registering_Partner__c != null && portalManagers.get(opp.Registering_Partner__c) != null)
            {
                newOppShares.add(new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = portalManagers.get(opp.Registering_Partner__c), OpportunityAccessLevel = 'Edit'));
            }
            if(opp.Registered_Distributor_Contact__c != null && portalUserIds.get(opp.Registered_Distributor_Contact__c) != null)
            {
                newOppShares.add(new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = portalUserIds.get(opp.Registered_Distributor_Contact__c), OpportunityAccessLevel = 'Edit'));
            }
            if(opp.Registering_Partner_Sales_Rep__c != null && portalUserIds.get(opp.Registering_Partner_Sales_Rep__c) != null)
            {
                newOppShares.add(new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = portalUserIds.get(opp.Registering_Partner_Sales_Rep__c), OpportunityAccessLevel = 'Edit'));
            }
        }
        Database.insert(newOppShares, false);
    }

    private static Map<Id, Id> getPortalManagerRoles(List<Id> accIds)
    {
        Map<Id, Id> result = new Map<Id, Id>();
        List<UserRole> portalManagerRoleList = [select Id, PortalAccountId from UserRole where PortalType='Partner' and PortalRole='Manager' and PortalAccountId in :accIds];
        List<Group> groups = [select Id, RelatedId from Group where RelatedId in :portalManagerRoleList];
        for(UserRole role : portalManagerRoleList)
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
    
    /*private static Map<Id, Id> getPortalUserRoles()
    {
        if(portalUserRoles == null)
        {
            portalUserRoles = new Map<Id, Id>();
            List<UserRole> portalUserRoleList = [select Id, PortalAccountId from UserRole where PortalType='Partner' and PortalRole in ('Worker', 'User') and PortalAccountId!=null];
            List<Group> groups = [select Id, RelatedId from Group where RelatedId in :portalUserRoleList];
            for(UserRole role : portalUserRoleList)
            {
                for(Group g : groups)
                {
                    if(role.Id == g.RelatedId)
                    {
                        portalUserRoles.put(role.PortalAccountId, g.Id);
                        break;
                    }
                }
            }
        }
        return portalUserRoles;
    }*/
    
    private static Map<Id, Id> getPortalUsers(List<Id> contactIds)
    {
        Map<Id, Id> result = new Map<Id, Id>();
        Map<Id, User> userMap = new Map<Id, User>([select Id, ContactId, Contact.AccountId from User where isActive = true and UserType = 'PowerPartner' and ContactId in :contactIds]);
        for(Id userId : userMap.keyset())
        {
            User thePortalUser = userMap.get(userId);
            result.put(thePortalUser.ContactId, userId);
        }
        return result;
    }
}