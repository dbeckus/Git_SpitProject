global with sharing class HPartnerPortalGetEnrollementDetailsApi extends HPartnerPortalApiBase 
{
   	private String token;
    private String enrollId;
	
	public HPartnerPortalGetEnrollementDetailsApi(String enrollId,string token)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
        this.enrollId= enrollId;
	}

	public HPartnerPortalEnrollment Enrollement {get; set;}

	public override String generateEndPoint()
    {
        string url= BaseEndpoint + '/enrollments/'+enrollId; 
        System.debug(url);
    	return url;
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
        Enrollement = (HPartnerPortalEnrollment) JSON.deserialize(response.trim(),HPartnerPortalEnrollment.class);
    }
}