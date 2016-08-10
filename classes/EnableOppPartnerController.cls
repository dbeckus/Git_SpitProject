/*
 * controller of page EnableOppPartner
*/
public class EnableOppPartnerController 
{
	private Opportunity record;
	
	public EnableOppPartnerController(ApexPages.StandardController ctrl)
	{
		record = (Opportunity)ctrl.getRecord();
	}
	
	public PageReference enablePartner()
	{
		List<Partner> partners = [select AccountToId, IsPrimary from Partner where OpportunityId=:record.Id and IsPrimary=true];
		for(Partner ptn : partners)
		{
			record.Primary_Partner__c = ptn.AccountToId;
			update record;
			return new PageReference('/' + record.Id);
		}
		record.Primary_Partner__c = null;
		update record;
		return new PageReference ('/' + record.Id);
	}
	
	@isTest
	static void testEnableOppPartnerController()
	{
		Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today());
		insert opp;
		ApexPages.StandardController ctrl = new ApexPages.StandardController(opp);
		EnableOppPartnerController eopc = new EnableOppPartnerController(ctrl);
		eopc.enablePartner();
	}
}