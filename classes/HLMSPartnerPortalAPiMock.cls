@isTest
public class HLMSPartnerPortalAPiMock implements HttpCalloutMock 
{

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public HLMSPartnerPortalAPiMock(Integer code, String status, String body, Map<String, String> responseHeaders) 
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
		System.debug('req.GetEndPoint'+req.getEndpoint());
        
        if(req.getEndpoint().indexOf('/Authenticate') > 0)
        {
            res.setBody('{a750ad20-34ff-4f05-a292-8a227c323441}');
        }
       else if(req.getEndpoint().indexOf('/createdepartment') > 0)
        {
            res.setBody('{"Value":"departments/01I38000000RCsi"}');
        }
        // One department.
        else if(req.getEndpoint().indexOf('departments/') > 0)
        {
            res.setBody('{"Locations":null,"Name":"Silver Peak","Notes":null,"ParentDeptID":0,"Id":"01I38000000RCsg"}');
        }
        // Departments.
        else if(req.getEndpoint().indexOf('/departments') > 0)
        {
            res.setBody('[{"Id":"01I38000000RCsg","Name":"Silver Peak","Password":null,"Uri":"/departments/85748","Value":"Silver Peak","externalId":null,"parentId":0}]');
        }
        
        else if(req.getEndpoint().indexOf('/createabsorbaccount') > 0)
        {
            res.setBody('{"Value":"students/618708"}');
        }
        else if(req.getEndpoint().indexOf('certificates/') > 0)
        {
            res.setBody('{"ActiveStatus":null,"Date":"/Date(1380223630000-0600)/","Email":"srussell@silver-peak.com","Id":1547239,"Uri":"courses/138078/certificates/1547239","Value":null,"externalId":null,"parentId":1423952,"studentsId":"1423952"}');
        }
         else if(req.getEndpoint().indexOf('/certificates') > 0)
        {
            res.setBody('[{"EnrollmentId":"78100ccc-9800-42d4-b767-021d8b1954fd","ActiveStatus":null,"Date":"/Date(1380223630000-0600)/","Email":"srussell@silver-peak.com","Id":"98bcad2d-aaae-4329-8807-1b9bfd6fa473","Uri":"courses/138078/certificates/1547239","Value":null,"externalId":null,"parentId":1423952}]');
        }
        else if(req.getEndpoint().indexOf('courses/') > 0)
        {
            res.setBody('{"Id":"01I38000000RCsf",Active":1,"ActiveDisplay":"Active","CategoryDisplay":null,"Cost":1,"Description":"<p>This course will show you what you need to know to be successful selling Silver Peaks Velocity VRX product line. Pass the exam at the end of the course to become a <strong>Silver Peak Certified Velocity Sales Specialist</strong> (SCVSS)</p>","EducationalUnits":null,"Expire":null,"IsEnrolled":false,"Score":null,"Start":null,"Thumbnail":"/courses/clients/648/images/SPX_64x48.png","Title":"VRX (Velocity) Sales Certification Training","Type":0,"TypeDisplay":"Online Course","Uri":"/courses/138078","categoryId":35033,"courseId":138078,"locked":false,"tags":[]}');
        }
        
        else if(req.getEndpoint().indexOf('/Courses') > 0)
        {
            res.setBody('[{"Active":1,"ActiveDisplay":"Active","CategoryDisplay":null,"Cost":1,"Description":"<p>This course will show you what you need to know to be successful selling Silver Peaks Velocity VRX product line. Pass the exam at the end of the course to become a <strong>Silver Peak Certified Velocity Sales Specialist</strong> (SCVSS)</p>","EducationalUnits":null,"Expire":null,"IsEnrolled":false,"Score":null,"Start":null,"Thumbnail":"/courses/clients/648/images/SPX_64x48.png","Title":"VRX (Velocity) Sales Certification Training","Type":0,"TypeDisplay":"Online Course","Uri":"/courses/138078","categoryId":35033,"courseId":138078,"locked":false,"tags":[]}]');
        }
        else if(req.getEndpoint().indexOf('students/') > 0)
        {
            res.setBody('{"studentId":"1423952","Username":"srusell","Email":"srussell@silver-peak.com"}');
        }
       
         else if(req.getEndpoint().indexOf('Users/') > 0)
        {
            res.setBody('{"Id":"01p3B000000Ea8s","DepartmentId":"01p3B000000Ea8s","FirstName":"Praj","LastName":"Rane","EmailAddress": "srussell@silver-peak.com"}');
        }
         else if(req.getEndpoint().indexOf('/Users') > 0)
        {
            res.setBody('[{"Id":"01p3B000000Ea8s","DepartmentId":"01p3B000000Ea8s","FirstName":"Praj","LastName":"Rane"}]');
        }
        else if(req.getEndpoint().indexOf('enrollments/') > 0)
        {
            res.setBody('{"Id":"78100ccc-9800-42d4-b767-021d8b1954fd","UserId":"01p3B000000Ea8s","CertificateId":"98bcad2d-aaae-4329-8807-1b9bfd6fa473"}');
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