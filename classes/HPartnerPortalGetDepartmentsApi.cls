public with sharing class HPartnerPortalGetDepartmentsApi extends HPartnerPortalApiBase
{
    private String token;
    private string departmentName;
  

	public HPartnerPortalGetDepartmentsApi(String token, String departmentName)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken(): token;
        this.departmentName = departmentName;
	}

	public List<HPartnerPortalQueryResult> departments {get; set;}

	public override String generateEndPoint()
    {
    	
    	String endpoint = BaseEndpoint + '/departments';
    	if(!String.isBlank(departmentName))
    	{
    		endpoint += '?departmentName=' + departmentName;
    	}
		return endpoint;
    	
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
    	System.debug(response);
    	departments = (List<HPartnerPortalQueryResult>) JSON.deserialize(response, List<HPartnerPortalQueryResult>.class);
    }
}