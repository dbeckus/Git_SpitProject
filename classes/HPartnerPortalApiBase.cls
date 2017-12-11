public abstract class HPartnerPortalApiBase
{
    public static Integer ApiTimeOut = 60000;
    public static String ContentCharset = 'UTF-8';
    public static String BaseEndpoint = 'https://silverpeaksystems-migration.sandbox.myabsorb.com/api/Rest/v1';
    
    public Boolean isSucceed { get; set; }

    /**
     * Executes this api.
     */
    public void execute()
    {
        isSucceed = false;
        try
        {
            // Sets http request headers and body.
            HttpRequest request = setHeaders(new HttpRequest());
            request.setEndpoint(generateEndPoint());
            System.debug(request.getEndpoint());
            request = setBody(request);
            //system.debug(request);
            // Sends request.
            System.debug(request.getBody());
            HttpResponse response = new Http().send(request);
            
            // Process response.
            system.debug(response.getStatusCode());
            if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
            {
                isSucceed = true;
                processResult(response.getBody());
            }
            else
            {
                system.debug(response.getBody());
            }
        }
        catch(Exception ex)
        {
            throw ex;
            // TBD: throw exception.
        }
    }
    
    /**
     * Sets headers for a http request.
     */
    protected virtual HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('GET');
        request.setHeader('charset', ContentCharset);
        request.setHeader('Content-Type', 'application/json');
        return request;
    }
    
    /**
     * Generates the endpoint for this dropbox api.
     */
    protected abstract String generateEndPoint();
    
    /**
     * Sets body for a http request.
     */
    protected abstract HttpRequest setBody(HttpRequest request);
    
    /**
     * Processes returned response which is in JSON format.
     */
    protected abstract void processResult(String json);
}