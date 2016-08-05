public class PartnerListController 
{
    private String oppId;
    
    public PartnerListController(ApexPages.StandardController controller) 
    {
        oppId = controller.getId();
    }
    
    public List<PartnerInfo> LeftPartners
    {
        get
        {
            List<PartnerInfo> result = new List<PartnerInfo>();
            Set<String> existing = new Set<String>();
            for(Partner partner : AllPartners)
            {
                if(partner.Role == 'Tier 1' || partner.Role == 'Tier 2' || partner.Role == 'Tier 3')
                {
                	String key = partner.Role + partner.AccountToId;
                	if(!existing.contains(key))
                	{
                		existing.add(partner.Role + partner.AccountToId);
                    	result.add(new PartnerInfo(partner.Role, partner.AccountToId, partner.AccountTo.Name));
                	}
                }
            }
            return result;
        }
    }
    
    public List<PartnerInfo> RightPartners
    {
        get
        {
            List<PartnerInfo> result = new List<PartnerInfo>();
            Set<String> existing = new Set<String>();
            for(Partner partner : AllPartners)
            {
                if(partner.Role != 'Tier 1' && partner.Role != 'Tier 2' && partner.Role != 'Tier 3' && partner.Role != 'Client' && partner.Role != 'Supplier' && partner.Role != 'Vendor' )
                {
                	String key = partner.Role + partner.AccountToId;
                	if(!existing.contains(key))
                	{
                		existing.add(partner.Role + partner.AccountToId);
                    	result.add(new PartnerInfo(partner.Role, partner.AccountToId, partner.AccountTo.Name));
                	}
                }
            }
            return result;
        }
    }
    
    private List<Partner> AllPartners
    {
        get
        {
            return [select Id, Role, AccountToId, AccountTo.Name from Partner where OpportunityId=:oppId order by Role];
        }
    }
    
    public class PartnerInfo
    {
        public PartnerInfo(String role, String id, String name)
        {
            this.Role = role;
            this.PartnerId = id;
            this.PartnerName = name;
        }
        
        public String Role { get; set; }
        public String PartnerId { get; set; }
        public String PartnerName { get; set; }
    }
    
    @isTest
    static void testPartnerListController()
    {
    	Account acc = new Account(Name='acme');
        insert acc;
        Account acc2 = new Account(Name='acme2');
        insert acc2;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id);
        insert opp;
        Partner partner = new Partner(OpportunityId=opp.Id, AccountToId=acc2.Id, Role='Tier1');
        insert partner;
        ApexPages.StandardController controller = new ApexPages.StandardController(opp);
        PartnerListController extension = new PartnerListController(controller);
        System.assert(extension.LeftPartners != null);
        System.assert(extension.RightPartners != null);
    	
    }

}