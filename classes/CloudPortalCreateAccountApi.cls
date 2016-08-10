public class CloudPortalCreateAccountApi extends CloudPortalApiBase {
    public string token; 
    public string AccountKey; 
    private Map<String, String> params;
    public CloudPortalAccount CPAccount= new CloudPortalAccount();
    public CloudPortalCreateAccountApi(Map<String, String> params)
    {
        this.params = params;
    }
    public override String generateEndPoint()
    {
        return BaseEndpoint + '/salesforce/account/0';
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('POST');
        request.setHeader('charset', ContentCharset);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', token);
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
        request.setBody(parameters);
        return request;
    }
    
    public override void processResult(String response)
    {
        System.debug(response);
        this.CPAccount = (CloudPortalAccount)JSON.deserialize(response,CloudPortalAccount.class);
    }
}