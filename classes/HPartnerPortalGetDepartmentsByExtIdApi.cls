public with sharing class HPartnerPortalGetDepartmentsByExtIdApi extends HPartnerPortalApiBase
{
    private String token;
    private string externalId;
  

    public HPartnerPortalGetDepartmentsByExtIdApi(String token, String salesforceId)
    {
        this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken(): token;
        this.externalId = salesforceId;
    }

    public List<HPartnerPortalLMSDepartment> departments {get; set;}

    public override String generateEndPoint()
    {
        
        String endpoint = BaseEndpoint + '/departments';
        if(!String.isBlank(externalId))
        {
            endpoint += '?externalId='+externalId;
        }
        return endpoint;
        
    }

    public override HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('GET');
        request.setHeader('Authorization',token);
        return request;
    }
    
    public override HttpRequest setBody(HttpRequest request)
    {
        return request;
    }
    
    public override void processResult(String response)
    {
        System.debug(response);
        departments = (List<HPartnerPortalLMSDepartment>) JSON.deserialize(response, List<HPartnerPortalLMSDepartment>.class);
    }
}