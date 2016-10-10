public class CloudPortalPostProvisionAssetsApi extends CloudPortalApiBase {
    public string token; 
    public string cloudPortalId;
    public Map<string,string> lstSerialNumber;
    public CloudPortalPostProvisionAssetsApi(string cloudAccId,Map<string,string> lstSn)
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
        generator.writeFieldName('serials');
        generator.writeStartArray();
        for(string item:lstSerialNumber.keyset())
            {
                generator.writeStartObject();   
                generator.writeObjectField('serial',item);
                generator.writeObjectField('model',lstSerialNumber.get(item));
                generator.writeEndObject();
            }
        generator.writeEndArray();
       	//generator.writeObjectField('serials', lstSerialNumber);
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