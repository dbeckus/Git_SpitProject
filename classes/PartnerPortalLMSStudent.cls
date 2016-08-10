public with sharing class PartnerPortalLMSStudent 
{
	public PartnerPortalLMSStudent(String name, String firstName, String lastName) 
	{	
		this.Uri = name;
		this.FirstName = firstName;
		this.LastName = lastName;
	}

	public Integer studentId {get; set;}
	public String Email {get; set;}
	public String FirstName {get; set;}
	public String LastName {get; set;}
	public Integer departmentId {get; set;}
	public String Uri {get; set;}
}