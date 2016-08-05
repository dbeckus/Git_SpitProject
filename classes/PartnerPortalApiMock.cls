@isTest
public class PartnerPortalApiMock implements HttpCalloutMock 
{

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public PartnerPortalApiMock(Integer code, String status, String body, Map<String, String> responseHeaders) 
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
        res.setStatusCode(200);

        if(req.getEndpoint().indexOf('/createdepartment') > 0)
        {
            res.setBody('{"Value":"departments/45685"}');
        }
        // One department.
        else if(req.getEndpoint().indexOf('departments/') > 0)
        {
            res.setBody('{"CompanyEmail":null,"CompanyImage":null,"CompanyName":null,"CompanyPhone":null,"IsSmartDept":false,"LMSLink":null,"Locations":null,"Name":"Silver Peak","Notes":null,"ParentDeptID":0,"Uri":"/departments/85748","departmentId":85748}');
        }
        // Departments.
        else if(req.getEndpoint().indexOf('/departments') > 0)
        {
            res.setBody('[{"Id":85748,"Password":null,"Uri":"/departments/85748","Value":"Silver Peak","externalId":null,"parentId":0}]');
        }
        else if(req.getEndpoint().indexOf('/createabsorbaccount') > 0)
        {
            res.setBody('{"Value":"students/618708"}');
        }
        else if(req.getEndpoint().indexOf('certificates') > 0)
        {
            res.setBody('[{"ActiveStatus":null,"Date":"/Date(1380223630000-0600)/","Email":null,"Id":1547239,"Uri":"courses/138078/certificates/1547239","Value":null,"externalId":null,"parentId":1423952}]');
        }
        else if(req.getEndpoint().indexOf('courses/') > 0)
        {
            res.setBody('{"Active":1,"ActiveDisplay":"Active","CategoryDisplay":null,"Cost":1,"Description":"<p>This course will show you what you need to know to be successful selling Silver Peaks Velocity VRX product line. Pass the exam at the end of the course to become a <strong>Silver Peak Certified Velocity Sales Specialist</strong> (SCVSS)</p>","EducationalUnits":null,"Expire":null,"IsEnrolled":false,"Score":null,"Start":null,"Thumbnail":"/courses/clients/648/images/SPX_64x48.png","Title":"VRX (Velocity) Sales Certification Training","Type":0,"TypeDisplay":"Online Course","Uri":"/courses/138078","categoryId":35033,"courseId":138078,"locked":false,"tags":[]}');
        }
        else if(req.getEndpoint().indexOf('/courses') > 0)
        {
            res.setBody('[{"Active":1,"ActiveDisplay":"Active","CategoryDisplay":null,"Cost":1,"Description":"<p>This course will show you what you need to know to be successful selling Silver Peaks Velocity VRX product line. Pass the exam at the end of the course to become a <strong>Silver Peak Certified Velocity Sales Specialist</strong> (SCVSS)</p>","EducationalUnits":null,"Expire":null,"IsEnrolled":false,"Score":null,"Start":null,"Thumbnail":"/courses/clients/648/images/SPX_64x48.png","Title":"VRX (Velocity) Sales Certification Training","Type":0,"TypeDisplay":"Online Course","Uri":"/courses/138078","categoryId":35033,"courseId":138078,"locked":false,"tags":[]}]');
        }
        else if(req.getEndpoint().indexOf('students/') > 0)
        {
            res.setBody('{"Value":"Student updated - 1858983, obj: 1858983"}');
        }
        else if(req.getEndpoint().indexOf('/students') > 0)
        {
            if(req.getEndpoint().indexOf('username=xxxx') > 0)
            {
                res.setStatusCode(404);
                res.setBody('');
            }
            else
            {
                res.setBody('[{"ActiveStatus":1,"Date":"/Date(1409274556963-0600)/","Email":"srussell@silver-peak.com","Id":1423952,"Uri":"students/1423952","Value":"Steven Russell","externalId":null,"parentId":85749},{"ActiveStatus":1,"Date":"/Date(1413925557830-0600)/","Email":"steve@voxmore.com","Id":1424206,"Uri":"students/1424206","Value":"Dell1 Partner","externalId":null,"parentId":85751},{"ActiveStatus":1,"Date":"/Date(1415210821973-0700)/","Email":"srussell@silver-peak.com","Id":1424207,"Uri":"students/1424207","Value":"Joe Partner","externalId":null,"parentId":85753}]');
            }
        }
        
        return res;
    }

}