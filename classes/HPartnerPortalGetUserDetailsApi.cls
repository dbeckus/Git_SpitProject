global with sharing class HPartnerPortalGetUserDetailsApi extends HPartnerPortalApiBase 
{
   	private String token;
    private String userId;
	
	public HPartnerPortalGetUserDetailsApi(String userId,string token)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
        this.userId= userId;
	}

	public HPartnerPortalUser UserInfo {get; set;}

	public override String generateEndPoint()
    {
        string url= BaseEndpoint + '/Users/'+userId; 
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
        UserInfo = (HPartnerPortalUser) JSON.deserialize(response.trim(),HPartnerPortalUser.class);
        System.debug(UserInfo);
    }
}