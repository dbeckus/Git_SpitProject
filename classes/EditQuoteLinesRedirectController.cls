/*
 * extension class of visualforce page EditQuoteLinesRedirect
 * just redirects the standard edit and del button of Quote_Line to the desired page EditQuoteLine
 */
public class EditQuoteLinesRedirectController 
{
	private String quoteId;
	public EditQuoteLinesRedirectController(ApexPages.StandardController controller)
	{
		Quote_Line__c record = (Quote_Line__c)controller.getRecord();
		if(record != null)
		{
			quoteId = record.Quote__c;
		}
	}
	
	public PageReference redirect()
	{
		return new PageReference('/apex/EditQuoteLines?id=' + quoteId);
	}
	
	@isTest
	static void testEditQuoteLinesRedirectController()
	{
		List<Quote_Line__c> lines = [select Id, Quote__c from Quote_Line__c limit 1];
		if(lines.size() > 0)
		{
			EditQuoteLinesRedirectController controller = new EditQuoteLinesRedirectController(new ApexPages.StandardController(lines[0]));
			System.assert(controller.redirect() != null);
		}
	}
}