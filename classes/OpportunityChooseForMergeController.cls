/*
 *    Controller of Page OpportunityChooseForMerge
 */
public class OpportunityChooseForMergeController 
{
    public static Integer MaxRecords { get { return 100; }}
    
    public OpportunityChooseForMergeController() 
    {
        Id oppId = ApexPages.currentPage().getParameters().get('Id');
        List<Opportunity> opps = [select Id, Name, OwnerId, Owner.ProfileId from Opportunity where Id = :oppId limit 1];
        Opportunity = (opps.size() > 0) ? opps[0] : new Opportunity();
        List<Profile> profiles = [select Id from Profile where Name = 'System Administrator' limit 1];
        AdminId = (profiles.size() > 0) ? profiles[0].Id : null;
        OppInfos = new List<OppInfo>();
        Keyword = '';
        search();
    }
    
    public List<OppInfo> OppInfos { get; set; }
    public String Keyword { get; set; } 
    
    public Opportunity Opportunity { get; set; }
    private Id AdminId { get; set; }
    
    public PageReference search()
    {
        OppInfos.clear();
        String keywordPattern = '%' + Keyword + '%';
        if(UserInfo.getProfileId() == AdminId)
        {
            for(Opportunity opp : [select Id, Name, Account.Name, Amount, CloseDate, StageName, CreatedDate, Owner.Name from Opportunity where Id != :Opportunity.Id and 
            IsClosed=false and IsWon=false and Name like :keywordPattern and StageName != 'Closed Deleted' order by Name limit :MaxRecords])
            {
                OppInfos.add(new OppInfo(opp));
            }
        }
        else
        {
            for(Opportunity opp : [select Id, Name, Account.Name, Amount, CloseDate, StageName, CreatedDate, Owner.Name from Opportunity where Id != :Opportunity.Id and 
            IsClosed=false and IsWon=false and OwnerId = :Opportunity.OwnerId and Name like :keywordPattern and StageName != 'Closed Deleted' order by Name limit :MaxRecords])
            {
                OppInfos.add(new OppInfo(opp));
            }
        }
        
        return null;
    }
    
    public PageReference nextStep()
    {
        for(OppInfo oppInfo : oppInfos)
        {
            if(oppInfo.IsSelected)
            {
                PageReference p = Page.OpportunityMerge;
                p.getParameters().put('op1', Opportunity.Id);
                p.getParameters().put('op2', oppInfo.Opportunity.Id);
                return p;
            }
        }
        
        return null;
    }
    
    public PageReference cancel()
    {
        return new PageReference('/' + Opportunity.Id);
    }
    
    public class OppInfo
    {
        public OppInfo(Opportunity newOpp)
        {
            IsSelected = false;
            Opportunity = newOpp;
        }
        
        public Boolean IsSelected { get; set; }
        public Opportunity Opportunity { get; set; }
    }
    
    @IsTest
    static void testOppChooseController()
    {
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < 10; i++)
        {
            opps.add(new Opportunity(Name = 'acme' + i, CloseDate = System.today(), StageName = 'Discovery'));
        }
        
        insert opps;
        
        PageReference p = Page.OpportunityChooseForMerge;
        Test.setCurrentPage(p);
        
        OpportunityChooseForMergeController controller = new OpportunityChooseForMergeController();
        
        System.assertEquals(10, controller.OppInfos.size());
        
        controller.Keyword = 'acme1';
        controller.search();
        System.assertEquals(1, controller.OppInfos.size());
        
        controller.Keyword = '';
        controller.search();
        controller.OppInfos[0].IsSelected = true;
        PageReference nextPage = controller.nextStep();
        
        PageReference cancelPage = controller.cancel();
    }
}