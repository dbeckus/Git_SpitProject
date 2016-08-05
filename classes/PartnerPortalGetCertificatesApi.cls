public with sharing class PartnerPortalGetCertificatesApi extends PartnerPortalApiBase 
{
    private String token;
    private String courseId;
    private string validSince;
    
    public PartnerPortalGetCertificatesApi(String courseId, String token, Date validSince)
    {
        this.token = String.isBlank(token) ? PartnerPortalSSOStub.getToken() : token;
        this.courseId = courseId;
        if(validSince!=null)
        {
            this.validSince= validSince.year() +'/'+validSince.month()+'/'+validSince.day();
        }
    }
    
    public List<PartnerPortalCertificate> Certificates {get; set;}
    
    public override String generateEndPoint()
    {
        if(this.validSince!=null)
        {return BaseEndpoint + '/courses/' + courseId + '/certificates?validSince='+validSince+'&token=' + token;}
        else
        {
            return BaseEndpoint + '/courses/' + courseId + '/certificates?token=' + token;
        }
        
    }
    
    public override HttpRequest setHeaders(HttpRequest request)
    {
        request.setMethod('GET');
        return request;
    }
    
    public override HttpRequest setBody(HttpRequest request)
    {
        return request;
    }
    
    public override void processResult(String response)
    {
        this.Certificates = (List<PartnerPortalCertificate>) JSON.deserialize(response, List<PartnerPortalCertificate>.class);
       
    }
}