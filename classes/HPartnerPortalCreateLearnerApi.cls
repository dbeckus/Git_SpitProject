public with sharing class HPartnerPortalCreateLearnerApi extends HPartnerPortalApiBase
{
	private Map<String, String> params;
	 	private String token;
	public HPartnerPortalCreateLearnerApi(string token,Map<String, String> params) 
	{
        this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
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
        request.setHeader('Authorization',token);
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
    	HPartnerPortalLMSObject student = (HPartnerPortalLMSObject) JSON.deserialize(response, HPartnerPortalLMSObject.class);
        studentId = student.getId();
    	System.debug(response);
    }
}