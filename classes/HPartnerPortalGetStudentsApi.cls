public with sharing class HPartnerPortalGetStudentsApi extends HPartnerPortalApiBase
{
	private String token;
    private String userName;
	
	
	public HPartnerPortalGetStudentsApi(String token, String userName)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
		this.userName=userName;
	}

	public List<HPartnerPortalStudentInfo> students {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/Users?username='+userName;
    }

	public override HttpRequest setHeaders(HttpRequest request)
	{
        request.setMethod('GET');
        request.setHeader('Authorization',token);
		return request;
	}
    
    public override HttpRequest setBody(HttpRequest request)
    {
    	return request;
    }
    
    public override void processResult(String response)
    {
       
        students = (List<HPartnerPortalStudentInfo>)JSON.deserialize(response, List<HPartnerPortalStudentInfo>.class);
    }
}