public class PartnerPortalGetStudentInformationApi extends PartnerPortalApiBase 
{
	private String token;
    private string studentId;
	
	public PartnerPortalGetStudentInformationApi(string studentId,string token)
	{
		this.token = string.isBlank(token)?PartnerPortalSSOStub.getToken():token;
		this.studentId = studentId;
	}

	public PartnerPortalStudentInfoResult studentInfo {get; set;}

	public override String generateEndPoint()
    {
    	return BaseEndpoint + '/students/'+studentId+'?token='+token;
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
    	
        studentInfo = (PartnerPortalStudentInfoResult) JSON.deserialize(response, PartnerPortalStudentInfoResult.class);
        system.debug(studentInfo);
    }
}