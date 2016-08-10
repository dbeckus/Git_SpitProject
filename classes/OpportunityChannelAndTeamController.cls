/*
 * Controller of component OpportunityChannelAndTeamList
 */
public class OpportunityChannelAndTeamController
{
    private Opportunity oppRecord;
    private Boolean isAdmin;
    
    public OpportunityChannelAndTeamController()
    {
        List<User> users = [select Id, Profile.PermissionsModifyAllData from User where Id=:UserInfo.getUserId() limit 1];
        isAdmin = users[0].Profile.PermissionsModifyAllData;
    }
    
    public Id oppId { get; set; }
    public Opportunity opp
    {
        get
        {
            if(oppRecord == null)
            {
                List<Opportunity> opps = [select Id, OwnerId, Patch_Locked__c, Registered_Partner__c, Sales_Region__c, Patch__c, Patch__r.Patch_Name__c from Opportunity where Id=:oppId limit 1];
                oppRecord = (opps.size() > 0) ? oppRecord = opps[0] : new Opportunity();
            }
            return oppRecord;
        }
    }
    
    public List<PartnerInfo> AllPartners
    {
        get
        {
            List<PartnerInfo> result = new List<PartnerInfo>();
            if(oppId != null)
            {
                List<Partner> partners = [select Id, Role, AccountToId, AccountTo.Name from Partner where OpportunityId=:oppId and Role in ('Tier 1', 'Tier 2', 'Tier 3') order by Role];
                partners.addAll([select Id, Role, AccountToId, AccountTo.Name from Partner where OpportunityId=:oppId and Role not in ('Tier 1', 'Tier 2', 'Tier 3', 'Client', 'Supplier', 'Vendor') order by Role]);
                for(Partner p : partners)
                {
                    result.add(new PartnerInfo(p.AccountToId, p.AccountTo.Name, p.Role));
                }
            }
            return result;
        }
    }
    
    public List<OpportunityTeamMember> AllMembers
    {
        get
        {
            return [select Id, UserId, User.Name, TeamMemberRole from OpportunityTeamMember where OpportunityId=:oppId order by TeamMemberRole];
        }
    }

    public Boolean PatchLocked { get; set; }
    public Boolean showLockButton { get { return (opp.OwnerId == UserInfo.getUserId() || isAdmin) && opp.Patch_Locked__c == false; }}
    public Boolean showUnlockButton { get { return (opp.OwnerId == UserInfo.getUserId() || isAdmin) && opp.Patch_Locked__c == true; }}
    
    public class PartnerInfo
    {
        public PartnerInfo(String aid, String name, String role)
        {
            this.AccountId = aid;
            this.AccountName = name;
            this.Role = role;
        }
        
        public String Role { get; set; }
        public String AccountId { get; set; }
        public String AccountName { get; set; }
        
    }
    
    @isTest
    static void test()
    {
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), OwnerId=UserInfo.getUserId(), Patch_Locked__c=false);
        insert opp;
        OpportunityChannelAndTeamController controller = new OpportunityChannelAndTeamController();
        controller.oppId = opp.Id;
        System.assertEquals(0, controller.AllPartners.size());
      //System.assertEquals(0, controller.AllMembers.size()); This has to be disabled because of splits. Splits add opp owner by default.
        Boolean show1 = controller.showLockButton;
        Boolean show2 = controller.showUnlockButton;
    }
}