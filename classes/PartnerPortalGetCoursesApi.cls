public with sharing class PartnerPortalGetCoursesApi extends PartnerPortalApiBase
{
	private String token;
	
	public PartnerPortalGetCoursesApi(String token)
	{
		this.token = String.isBlank(token) ? PartnerPortalSSOStub.getToken() : token;
	}

	public List<PartnerPortalQueryResult> courses {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/courses?token=' + token;
    }

	public override HttpRequest setHeaders(HttpRequest request)
	{
        request.setMethod('GET');
		return request;
	}
    
    public override HttpRequest setBody(HttpRequest request)
    {
    	return request;
    }
    
    public override void processResult(String response)
    {
    	system.debug(response);
        courses = (List<PartnerPortalQueryResult>) JSON.deserialize(response, List<PartnerPortalQueryResult>.class);
    }
}