public with sharing class PartnerPortalUpdateLearnerApi extends PartnerPortalApiBase
{
	private Map<String, String> params;
	private String studentId;
	private String token;

	public PartnerPortalUpdateLearnerApi(Map<String, String> params, String token) 
	{
		this.params = params;
		studentId = params.get('studentId');
		this.token = String.isNotBlank(token) ? token : PartnerPortalSSOStub.getToken();
	}

    public override String generateEndPoint()
    {
    	return BaseEndpoint + '/students/' + studentId;
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
        generator.writeStringField('token', token);
        generator.writeFieldName('studentInfo');
        generator.writeStartObject();
        for(String fieldName : params.keySet())
        {
            if(String.isNotBlank(params.get(fieldName)))
            {
                generator.writeStringField(fieldName, params.get(fieldName));
            }
        }
        generator.writeEndObject();        
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        System.debug(parameters);
        request.setBody(parameters);
        return request;
    }
    
    public override void processResult(String response)
    {
    	PartnerPortalLMSObject student = (PartnerPortalLMSObject) JSON.deserialize(response, PartnerPortalLMSObject.class);
        //studentId = student.getId();
    	System.debug(response);
    }
}