/*
 * Controller of component LeadChannelAndSalesTeamList
 */

public with sharing class LeadChannelAndSalesTeamController 
{
    private Boolean isAdminUser;
    private Lead theLead;

    public String LeadId { get; set; }

    public Lead Lead
    {
        get
        {
            if(theLead == null)
            {
                List<Lead> leads = [SELECT OwnerId, Patch_Locked__c, rvpe__RVAccount__c, rvpe__RVAccount__r.Name, rvpe__RVMember__c, rvpe__RVMember__r.Name, 
                                           Secondary_RV_Account__c, Secondary_RV_Account__r.Name, Secondary_RV_Member__c, Secondary_RV_Member__r.Name,
                                           SE__c, SE__r.Name, CSM__c, CSM__r.Name, ISR__c, ISR__r.Name, RSM__c, RSM__r.Name 
                                    FROM Lead 
                                    WHERE Id = :LeadId 
                                    LIMIT 1];
                theLead = (leads.size() == 1) ? leads[0] : new Lead();
            }
            return theLead;
        }
    }

    public List<PartnerInfo> AllPartners
    {
        get
        {
            List<PartnerInfo> result = new List<PartnerInfo>();
            if(Lead.rvpe__RVAccount__c != null)
            {
                result.add(new PartnerInfo('Partner Account', Lead.rvpe__RVAccount__c, Lead.rvpe__RVAccount__r.Name));
            }
            if(Lead.rvpe__RVMember__c != null)
            {
                result.add(new PartnerInfo('Partner Rep', Lead.rvpe__RVMember__c, Lead.rvpe__RVMember__r.Name));
            }
            if(Lead.Secondary_RV_Account__c != null)
            {
                result.add(new PartnerInfo('Distributor Account', Lead.Secondary_RV_Account__c, Lead.Secondary_RV_Account__r.Name));
            }
            if(Lead.Secondary_RV_Member__c != null)
            {
                result.add(new PartnerInfo('Distributor Rep', Lead.Secondary_RV_Member__c, Lead.Secondary_RV_Member__r.Name));
            }
            return result;
        }
    }
    
    public List<MemberInfo> AllMembers
    {
        get
        {
            List<MemberInfo> result = new List<MemberInfo>();
            if(Lead.SE__c != null)
            {
                result.add(new MemberInfo('SE', Lead.SE__c, Lead.SE__r.Name));
            }
            if(Lead.CSM__c != null)
            {
                result.add(new MemberInfo('CSM', Lead.CSM__c, Lead.CSM__r.Name));
            }
            if(Lead.ISR__c != null)
            {
                result.add(new MemberInfo('ISR', Lead.ISR__c, Lead.ISR__r.Name));
            }
            if(Lead.RSM__c != null)
            {
                result.add(new MemberInfo('RSM', Lead.RSM__c, Lead.RSM__r.Name));
            }
            return result;
        }
    }

    public Boolean ShowLockButton 
    {
        get 
        {
            return (Lead.OwnerId == UserInfo.getUserId() || isAdminUser) && Lead.Patch_Locked__c == false; 
        }
    }

    public Boolean ShowUnlockButton
    {
        get
        {
            return (Lead.OwnerId == UserInfo.getUserId() || isAdminUser) && Lead.Patch_Locked__c == true;
        }
    }
    

    public LeadChannelAndSalesTeamController()
    {
        User currentUser = [SELECT Id, Profile.PermissionsModifyAllData FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        isAdminUser = currentUser.Profile.PermissionsModifyAllData;
    }

    public class PartnerInfo
    {
        public PartnerInfo(String role, String accountId, String accountName)
        {
            this.Role           = role;
            this.AccountId      = accountId;
            this.AccountName    = accountName;
        }
        
        public String Role          { get; set; }
        public String AccountId     { get; set; }
        public String AccountName   { get; set; }
    }

    public class MemberInfo
    {
        public MemberInfo(String role, String userId, String userName)
        {
            this.Role       = role;
            this.UserId     = userId;
            this.UserName   = userName;
        }

        public String Role      { get; set; }
        public String UserId    { get; set; }
        public String UserName  { get; set; }
    }
}