public with sharing class PartnerPortalCourse 
{
	public PartnerPortalCourse()
	{

	}
	public Integer courseId {get; set;}
	public Integer categoryId {get; set;}
	public String Title {get; set;}
	public String Description {get; set;}
	public Integer Active {get; set;} //1 is Active or 2 is Inactive.
	public String ActiveDisplay {get; set;}
	public Integer Type {get; set;} //2 is Optional Online Course, 1 is Sequential Online Course, 3 is Instructor Led Course, 4 is Other Course, 0 is Online Course.
	public String TypeDisplay {get; set;}
	public Datetime Start {get; set;}
	public Datetime Expire {get; set;}
	public Decimal Cost {get; set;}
	public String CategoryDisplay {get; set;}
	public String Uri {get; set;}
	public List<String> tags {get; set;}
	public Boolean locked {get; set;}

}