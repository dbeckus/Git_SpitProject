/**
 * Api base, presents a http request and processes the response. All api classes should extends this class.
 * Following are the steps to perform a api call.
 * 1. Sets http headers;
 * 2. Sets http body if necessary;
 * 3. Sends the request and process the response.
 */
public abstract class PartnerPortalApiBase
{
    public static Integer ApiTimeOut = 60000;
    public static String ContentCharset = 'UTF-8';
    public static String BaseEndpoint = 'https://www.absorbadmin.com/shared/services/api2.svc';
    
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
            request = setBody(request);
            system.debug(request);
            // Sends request.
            HttpResponse response = new Http().send(request);
            
            // Process response.
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