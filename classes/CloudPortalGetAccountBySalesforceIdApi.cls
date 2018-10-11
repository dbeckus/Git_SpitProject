public class CloudPortalGetAccountBySalesforceIdApi extends CloudPortalApiBase {
    public string token; 
    public string recordId;
    public CloudPortalAccountList CPAccount= new CloudPortalAccountList() ;
    public CloudPortalGetAccountBySalesforceIdApi(string salesforceId)
    {
        recordId=salesforceId;
    }
    public override String generateEndPoint()
    {
        return BaseEndpoint + '/salesforce/account?salesforceId='+recordId;
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
        super.setHeaders(request);
        request.setMethod('GET');
        request.setHeader('charset', ContentCharset);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', token);
        return request;
    }
    
    public override HttpRequest setBody(HttpRequest request)
    {
        return request;
    }
    
    public override void processResult(String response)
    {
        System.debug(response);
        this.CPAccount = (CloudPortalAccountList)JSON.deserialize(response,CloudPortalAccountList.class);
        
    }
    
    
}