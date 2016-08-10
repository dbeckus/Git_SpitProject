public with sharing class PartnerPortalCreateDepartmentApi extends PartnerPortalApiBase
{
	private Map<String, String> params;
    
	public PartnerPortalCreateDepartmentApi(Map<String, String> params)
	{
		this.params = params;
	}
	
	public String departmentId {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/createdepartment';
    }

    public override HttpRequest setHeaders(HttpRequest request)
	{
        request.setMethod('POST');
        request.setHeader('charset', ContentCharset);
        request.setHeader('Content-Type', 'application/json');
        return request;
	}
    
    public override HttpRequest setBody(HttpRequest request)
    {
    	JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        for(String fieldName : params.keySet())
        {
            if(String.isNotBlank(params.get(fieldName)))
            {
    			generator.writeStringField(fieldName, params.get(fieldName));
            }
        }    
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        System.debug(parameters);
        request.setBody(parameters);
		System.debug(request);
    	
        return request;
    }
    
    public override void processResult(String response)
    {
    	PartnerPortalLMSObject department = (PartnerPortalLMSObject) JSON.deserialize(response, PartnerPortalLMSObject.class);
    	departmentId = department.getId();
        System.debug(response);
    }
}