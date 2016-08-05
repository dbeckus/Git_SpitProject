public with sharing class HPartnerPortalLMSObject 
{
	public HPartnerPortalLMSObject() 
	{	
	}

	public String Value {get; set;}

	public String getId()
	{
		return Value.substring(Value.indexOf('/') + 1);
	}
}