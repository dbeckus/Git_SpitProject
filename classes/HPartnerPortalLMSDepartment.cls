public with sharing class HPartnerPortalLMSDepartment 
{
	public HPartnerPortalLMSDepartment(String name) 
	{		
		this.Name = name;
	}

	public Integer departmentId {get; set;}
	public String Name {get; set;}
	public String Notes {get; set;}
	public String Locations {get; set;}
	public Integer ParentDeptID {get; set;}
	public String LMSLink {get; set;}
	public Boolean IsSmartDept {get; set;}
	public String CompanyName {get; set;}
	public String CompanyPhone {get; set;}
	public String CompanyEmail {get; set;}
	public String CompanyImage {get; set;}
}