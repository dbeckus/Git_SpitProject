public class HPartnerPortalGetDepartmentApi extends HPartnerPortalApiBase 
{
   	private String token;
    private String departmentId;
	
	public HPartnerPortalGetDepartmentApi(String departmentId,string token)
	{
		this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
        this.departmentId= departmentId;
	}

	public HPartnerPortalLMSDepartment department {get; set;}

	public override String generateEndPoint()
    {
        string url= BaseEndpoint + '/departments/'+departmentId; 
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
        department = (HPartnerPortalLMSDepartment) JSON.deserialize(response.trim(),HPartnerPortalLMSDepartment.class);
        System.debug(department);
    }
}