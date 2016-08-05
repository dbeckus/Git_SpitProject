public with sharing class HPartnerPortalGetCoursesApi extends HPartnerPortalApiBase
{
	private String token;
	
	public HPartnerPortalGetCoursesApi(String token)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
	}

	public List<HCourses> courses {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/Courses';
    }

	public override HttpRequest setHeaders(HttpRequest request)
	{
        request.setMethod('GET');
        request.setHeader('Authorization',token);
        System.debug(token);
		return request;
	}
    
    public override HttpRequest setBody(HttpRequest request)
    {
    	return request;
    }
    
    public override void processResult(String response)
    {
        courses = (List<HCourses>) JSON.deserialize(response, List<HCourses>.class);
    }
}