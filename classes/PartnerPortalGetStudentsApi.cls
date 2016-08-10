public with sharing class PartnerPortalGetStudentsApi extends PartnerPortalApiBase
{
	private String token;
	private Map<String, String> params;
	
	public PartnerPortalGetStudentsApi(String token, Map<String, String> params)
	{
		this.token = String.isBlank(token) ? PartnerPortalSSOStub.getToken() : token;
		this.params = params;
	}

	public List<PartnerPortalQueryResult> students {get; set;}

	public override String generateEndPoint()
    {
    	String queryString = '';
    	for(String key : params.keySet())
    	{
    		queryString += '&' + key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8');
    	}
    	return BaseEndpoint + '/students?token=' + token + queryString;
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
        students = (List<PartnerPortalQueryResult>) JSON.deserialize(response, List<PartnerPortalQueryResult>.class);
    }
}