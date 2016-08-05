public class CloudPortalPostProvisionAssetsApi extends CloudPortalApiBase {
    public string token; 
    public string cloudPortalId;
    public Set<string> lstSerialNumber;
    public CloudPortalPostProvisionAssetsApi(string cloudAccId,Set<string> lstSn)
    {
        cloudPortalId=cloudAccId;
        lstSerialNumber=lstSn;
    }
    public override String generateEndPoint()
    {
        return BaseEndpoint+'/salesforce/account/'+cloudPortalId+'/provision';
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
       	generator.writeObjectField('serials', lstSerialNumber);
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        request.setBody(parameters);
        System.debug(parameters);
        return request;
    }
    
    public override void processResult(String response)
    {
        System.debug(response);
        
    }
    
    
}