public class TestDataController {
    public static string caseNumber{get;set;}
    public PageReference SaveData()
    {
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST');
        req.setEndpoint('https://silverpeaksystems--spit.cs30.my.salesforce.com'+'/services/oauth2/token');
        req.setBody('grant_type=password' +
                    '&client_id=' + '3MVG9PerJEe9i8iJHT36EOe.CDwodG04rDZo.EXoBfzJOIRF4lZIpmVa0omAgwrgr8fxBi.pXVUfrze3NmlYg' +
                    '&client_secret=' + '362843396604305330' +
                    '&username=' + EncodingUtil.urlEncode('prane@silver-peak.com.spit', 'UTF-8') +
                    '&password=' + EncodingUtil.urlEncode('Fluffy1989', 'UTF-8'));
        
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        
        System.debug('BODY: '+res.getBody());
        System.debug('STATUS:'+res.getStatus());
        System.debug('STATUS_CODE:'+res.getStatusCode());
        LoginData data= (LoginData) JSON.deserialize(res.getBody(),LoginData.class);
        System.debug('access_token'+data.access_token);
        //System.JSONObject jsonObj= new JsonObject(res.getBody());
        // Call the get case data
        /* HttpRequest req1 = new HttpRequest(); 
req1.setMethod('GET');
req1.setEndpoint('https://silverpeaksystems--spit.cs30.my.salesforce.com/services/apexrest/CPCaseInfo?caseNumber=20170125-196107');
req1.setHeader('AUTHORIZATION', 'Bearer '+data.access_token);

Http http1 = new Http();

HTTPResponse res1 = http1.send(req1);
System.debug('BODY: '+res1.getBody());
System.debug('STATUS:'+res1.getStatus());
System.debug('STATUS_CODE:'+res1.getStatusCode());
*/
       /* 
        HttpRequest req2 = new HttpRequest(); 
        req2.setMethod('POST');
        req2.setEndpoint('https://silverpeaksystems--spit.cs30.my.salesforce.com/services/apexrest/CPCaseInfo');
        req2.setHeader('AUTHORIZATION', 'Bearer '+data.access_token);
        req2.setHeader('Content-Type', 'application/json');
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('caseInfo');
        generator.writeStartObject();
        generator.writeObjectField('subject','Test Subject');
        generator.writeObjectField('description','a thing\nanother thing');
        generator.writeObjectField('priority','P4 - Low');
        generator.writeObjectField('emailAddress','prane233@silver-peak.com');
        generator.writeObjectField('serialNumber','001ddd444bbb');
        
        generator.writeEndObject();
        generator.writeEndObject();
        String parameters = generator.getAsString();
        req2.setBody(parameters);
        System.debug('parameters'+ parameters);
        Http http2 = new Http();
        
        HTTPResponse res2 = http2.send(req2);
        System.debug('BODY: '+res2.getBody());
        System.debug('STATUS:'+res2.getStatus());
        System.debug('STATUS_CODE:'+res2.getStatusCode());
        caseNumber=res2.getBody();
*/
        
        HttpRequest req3 = new HttpRequest(); 
        req3.setMethod('POST');
        req3.setEndpoint('https://silverpeaksystems--spit.cs30.my.salesforce.com/services/apexrest/CPFileInfo');
        req3.setHeader('AUTHORIZATION', 'Bearer '+data.access_token);
        req3.setHeader('Content-Type', 'application/json');
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeFieldName('fileInfo');
        generator.writeStartArray();
        generator.writeStartObject();
        generator.writeObjectField('sfCaseId','57838423842384293084');
        generator.writeObjectField('fileName','Test File Name Praj');
        generator.writeObjectField('fileKey','00D300000000byV/005500000046tQb/1432834561534/silverpeak.docx');
        generator.writeObjectField('fileSize','2555');
        generator.writeEndObject();
        generator.writeEndArray();
        generator.writeEndObject();
        string parameters = generator.getAsString();
        req3.setBody(parameters);
        System.debug('parameters'+ parameters);
        Http http3 = new Http();
        
        HTTPResponse res3 = http3.send(req3);
        System.debug('BODY: '+res3.getBody());
        System.debug('STATUS:'+res3.getStatus());
        System.debug('STATUS_CODE:'+res3.getStatusCode());
        return null;
    }
    
    
    public class LoginData
    {
        public string access_token{get;set;}
    }
}