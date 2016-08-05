public with sharing class HPartnerPortalGetCertificatesApi extends HPartnerPortalApiBase 
{
    private String token;
    private String courseId;
    private string validSince;
    
    public HPartnerPortalGetCertificatesApi(String courseId, String token, Date validSince)
    {
        this.token = String.isBlank(token) ? HPartnerPortalSSOStub.getHttpToken() : token;
        this.courseId = courseId;
        if(validSince!=null)
        {
            this.validSince= validSince.year() +'/'+validSince.month()+'/'+validSince.day();
        }
    }
    
    public List<HPartnerPortalCertificate> Certificates {get; set;}
    
    public override String generateEndPoint()
    {
        if(this.validSince!=null)
        {
            return BaseEndpoint + '/courses/' + courseId + '/certificates?acquiredDate='+validSince;
        }
        else
        {
            return BaseEndpoint + '/courses/' + courseId + '/certificates';
        }
        
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
        this.Certificates = (List<HPartnerPortalCertificate>) JSON.deserialize(response.trim(), List<HPartnerPortalCertificate>.class);
        System.debug('Certificates'+Certificates);
    }
}