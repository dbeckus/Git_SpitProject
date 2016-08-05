public with sharing class PartnerPortalCreateLearnerApi extends PartnerPortalApiBase
{
	private Map<String, String> params;
	
	public PartnerPortalCreateLearnerApi(Map<String, String> params) 
	{
		this.params = params;
	}
    public String studentId {get; set;}
	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/createabsorbaccount';
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
        return request;
    }
    
    public override void processResult(String response)
    {
    	PartnerPortalLMSObject student = (PartnerPortalLMSObject) JSON.deserialize(response, PartnerPortalLMSObject.class);
        studentId = student.getId();
    	System.debug(response);
    }
}