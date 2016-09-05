public with sharing class HPartnerPortalUpdateLearnerApi extends HPartnerPortalApiBase
{
    private Map<String, String> params;
    private String studentId;
    private String token;
    
    public HPartnerPortalUpdateLearnerApi(Map<String, String> params, String token) 
    {
        this.params = params;
        studentId = params.get('Id');
        this.token = String.isNotBlank(token) ? token : HPartnerPortalSSOStub.getHttpToken();
    }
    
    public override String generateEndPoint()
    {
        return BaseEndpoint + '/Users/' + studentId;
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('PUT');
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
        
        System.debug(response);
    }
}