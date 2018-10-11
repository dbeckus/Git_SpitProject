public class CloudPortalApiMock implements HttpCalloutMock {
  	protected Integer code;
    protected String status;
    protected String body;
    //protected String token;
    protected Map<String, String> responseHeaders;
    public CloudPortalApiMock(Integer code, String status, String body, Map<String, String> responseHeaders) 
    {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
        
    }
    public HTTPResponse respond(HTTPRequest req) 
    {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(code);
		System.debug('req.GetEndPoint'+req.getEndpoint());
    	if(req.getEndpoint().indexOf('/provision') > 0)
        {
            res.setBody('{"Value":"account/123666669898"}');
        }
        if(req.getEndpoint().indexOf('/assets') > 0)
        {
            res.setBody('{"Value":"account/123666669898"}');
        }
        if(req.getEndpoint().indexOf('/account/0') > 0)
        {
            res.setBody('{"salesforceId":"001W000000LMxab","id":"123666669899","name":"acme","accountKey":"aed873823iui877"}');
        }
        if(req.getEndpoint().indexOf('/salesforce/account?salesforceId') > 0)
        {
            res.setBody('{"accounts":[{"salesforceId":"001W000000LN3hQ","Id":"123666669889","name":"acme_test","accountKey":"aed873823iui887"}]}');
        }
        if(req.getEndpoint().indexOf('/salesforce/account?modifiedTime') > 0)
        {
            res.setBody('{"accounts":[{"salesforceId":"001W000000LN3tQ","id":"123666669889","name":"acme_test_updated","accountkey":"aed873823iui899"}]}');
        }
        if(req.getEndpoint().indexOf('/login') > 0)
        {
            res.setBody('{"Value":"test123"}');
        }
        System.debug('res' +res);
        return res;
    }
}