global with sharing class PartnerPortalGetCourseCertificateApi extends PartnerPortalApiBase 
{
   	private String token;
	private String courseId;
    private String certificationId;
	
	public PartnerPortalGetCourseCertificateApi(String certificationId,String courseId,string token)
	{
		this.token = String.isBlank(token) ? PartnerPortalSSOStub.getToken() : token;
		this.courseId = courseId;
        this.certificationId= certificationId;
	}

	public PartnerPortalCourseCertficate CourseCertificate {get; set;}

	public override String generateEndPoint()
    {
        string url= BaseEndpoint + '/courses/' + courseId + '/certificates/'+certificationId+'?token=' + token; 
        System.debug(url);
    	return url;
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
        CourseCertificate = (PartnerPortalCourseCertficate) JSON.deserialize(response.trim(),PartnerPortalCourseCertficate.class);
    }
}