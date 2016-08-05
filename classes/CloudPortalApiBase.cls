public abstract class CloudPortalApiBase {
   
    public static Integer ApiTimeOut = 60000;
    public static String ContentCharset = 'UTF-8';
    public static String BaseEndpoint = SilverPeakUtils.IsProduction()?'https://cloudportal.silver-peak.com/portal/apis/rest':'https://portaldev.silver-peak.com/portal/apis/rest';
    
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
                System.debug(response.getBody());
                System.debug(response.GetStatusCode());
                processResult(response.getBody());
                
            }
            else
            {
                //system.debug(response.getStatusCode());
                system.debug(response.getBody());
                insert new ErrorLog__c(Subject__c='CloudPortal Http Send Failure', Message__c=response.getBody());
            }
        }
        catch(Exception ex)
        {
            insert new ErrorLog__c(Subject__c='Error in Cloud Portal RestAPI Base', Message__c=ex.getMessage() + '\r\n' + ex.getStackTraceString());
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