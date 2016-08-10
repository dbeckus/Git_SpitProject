public with sharing class PartnerPortalGetDepartmentsApi extends PartnerPortalApiBase
{
    private String token;
    private Map<String, String> params;

	public PartnerPortalGetDepartmentsApi(String token, Map<String, String> params)
	{
		this.token = String.isBlank(token) ? PartnerPortalSSOStub.getToken(): token;
        this.params = params;
	}

	public List<PartnerPortalQueryResult> departments {get; set;}

	public override String generateEndPoint()
    {
    	String departmentId = params.get('departmentId');
    	String endpoint = BaseEndpoint + '/departments';
    	if(String.isBlank(departmentId))
    	{
    		endpoint += '?token=' + token;
    	}
    	else
		{
			endpoint += '/' + departmentId + '?token=' + token;
		}
		for(String key : params.keySet())
		{
			if(!key.equalsIgnoreCase('departmentId'))
			{
				endpoint += '&' + key + '=' + EncodingUtil.urlEncode(params.get(key), 'UTF-8') ;
			}
		}
		return endpoint;
    	//return BaseEndpoint + '/departments/' + departmentId + '?token=' + token;// PartnerPortalSSOStub.getToken();
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
    	System.debug(response);
    	departments = (List<PartnerPortalQueryResult>) JSON.deserialize(response, List<PartnerPortalQueryResult>.class);
    }
}