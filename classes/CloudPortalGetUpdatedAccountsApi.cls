public class CloudPortalGetUpdatedAccountsApi extends CloudPortalApiBase {
    
    public long updatedTime;
    public string token;
    public CloudPortalAccountList CPAccountList= new CloudPortalAccountList() ;
    public CloudPortalGetUpdatedAccountsApi(long updatedTime)
    {
        this.updatedTime=updatedTime;
    }
    public override String generateEndPoint()
    {
        return BaseEndpoint + '/salesforce/account?modifiedTime='+updatedTime;
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
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
        CPAccountList= (CloudPortalAccountList)JSON.deserialize(response,CloudPortalAccountList.class);
        
    }
}