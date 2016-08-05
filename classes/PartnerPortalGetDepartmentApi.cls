public with sharing class PartnerPortalGetDepartmentApi extends PartnerPortalApiBase
{
	private String departmentId;
    private String token;

	public PartnerPortalGetDepartmentApi(String departmentId, String token)
	{
		this.departmentId = departmentId;
        this.token = token;
	}

    public PartnerPortalLMSDepartment department {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/departments/' + departmentId + '?token=' + token;// PartnerPortalSSOStub.getToken();
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
        department = (PartnerPortalLMSDepartment) JSON.deserialize(response, PartnerPortalLMSDepartment.class);
    }
}