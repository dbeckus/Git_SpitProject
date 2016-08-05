public with sharing class PartnerPortalLMSObject 
{
	public PartnerPortalLMSObject() 
	{	
	}

	public String Value {get; set;}

	public String getId()
	{
		return Value.substring(Value.indexOf('/') + 1);
	}
}