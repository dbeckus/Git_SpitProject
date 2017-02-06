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
                List<String> fields = describeFields();
                fields.add('Patch__r.Patch_Name__c');
                List<Opportunity> opps = Database.query('select ' + String.join(fields, ',') + ' from Opportunity where Id=:oppId limit 1');
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
    
    private List<String> describeFields()
    {
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.Opportunity.fields.getMap();
        List<String> result = new List<String>();
        result.addAll(fields.keyset());
        return result;
    }
    
    @isTest
    static void test()
    {
        Account acc1 = new Account(Name='acme');
        Account acc2 = new Account(name='acme');
        insert new List<Account> { acc1, acc2 };
        Opportunity opp = new Opportunity(AccountId=acc1.Id, Name='acme', StageName='Discovery', CloseDate=Date.today(), OwnerId=UserInfo.getUserId(), Patch_Locked__c=false);
        insert opp;
        Partner p = new Partner(OpportunityId=opp.Id, AccountToId=acc2.Id);
        insert p;
        
        Test.startTest();
        OpportunityChannelAndTeamController controller = new OpportunityChannelAndTeamController();
        controller.oppId = opp.Id;
        opp = controller.opp;
        System.assertEquals(1, controller.AllPartners.size());
      //System.assertEquals(0, controller.AllMembers.size()); This has to be disabled because of splits. Splits add opp owner by default.
        Boolean show1 = controller.showLockButton;
        Boolean show2 = controller.showUnlockButton;
        Test.stopTest();
    }
}