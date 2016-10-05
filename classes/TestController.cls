public class TestController {
    
    
    public PageReference Save()
    {
        string token='';
        CP();
        return null;
    }
    
    private static void AuthenticateLMSUser()
    {
        /* string SSOKey='a750ad20-34ff-4f05-a292-8a227c323441';
string emailAddress='dbeckus@silver-peak.com';
string url='https://silverpeaksystems-migration.sandbox.myabsorb.com';


string idAndKey = emailAddress+SSOKey;
blob salt = EncodingUtil.base64Decode(token);
string key=EncodingUtil.base64Encode(Crypto.generateDigest('PBKDF2', Blob.valueOf(idAndKey+salt)));
string test=url+'/externallogincallback?id='+emailAddress+'&key='+key;

//HttpRequest req= new HttpRequest();*/
    }
    
    private void GetCourses()
    {
        HPartnerPortalGetEnrollementDetailsApi obj= new HPartnerPortalGetEnrollementDetailsApi('2caa05cb-6b7c-457c-b5d7-412ca904dc24','');
        obj.execute();
        System.debug(obj.Enrollement);
        
    }
    private void VALidateDepartmentById()
    {
        string token=	HPartnerPortalSSOStub.getHttpToken();
        
        System.debug(HPartnerPortalSSOStub.validateDepartmentById('18a9be99-1089-468d-9099-25701197d562',token));
        
    }
    private void VALidateDepartmentByName()
    {
        string token=	HPartnerPortalSSOStub.getHttpToken();
        HPartnerPortalGetDepartmentsApi obj=HPartnerPortalSSOStub.validateDepartmentByName('Beckus and Associates',token);
        System.debug(obj);
        
    }
    
     private void CreateLearner()
    {
        string token=	HPartnerPortalSSOStub.getHttpToken();
        Contact con=[Select Id,FirstName,LastName,Title from Contact where Id='0033B000007F0CC'];
        Account acc=[Select Id,Name,GEO_Supported__c from Account where Id='0013B0000081IuG'];
        string obj=HPartnerPortalSSOStub.createLearner(con,'18a9be99-1089-468d-9099-25701197d562','test@123.com',token,acc);
        System.debug(obj);
        
    }
     private void CreateDepartment()
    {
        string token=	HPartnerPortalSSOStub.getHttpToken();
        Account acc=[Select Id,Name,GEO_Supported__c from Account where Id='0013B000007Zwb8'];
        string obj=HPartnerPortalSSOStub.createDepartment(acc,null,token);
        System.debug(obj);
        
    }
     private void UpdateLearner()
    {
        string token=	HPartnerPortalSSOStub.getHttpToken();
         Contact con=[Select Id,FirstName,LastName,Title,Email from Contact where Id='0033B000007F0CC'];
        HPartnerPortalSSOStub.updateLearner('cc1953ca-e06c-4520-a5cf-ad3e46b44dc0','CA','Sunnyvale',token,con);
       
        
    }
     private void VALidateLearner()
    {
        string token=HPartnerPortalSSOStub.getHttpToken();
        boolean isSucceed=HPartnerPortalSSOStub.validateLearner('dennis.beckus@gmail.com',token);
        System.debug('isSucceed'+isSucceed);
        
    }
    private  void CP()
    {
        string token='';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('charset', 'UTF-8');
        request.setHeader('Content-Type', 'application/json');
        Api_Configuration__c dataObj=[Select Endpoint_URL__c ,UserName__c,Password__c from Api_Configuration__c where Environment_Name__c='Cloud Portal Testing' LIMIT 1];
        System.debug(dataObj.Endpoint_URL__c);
        System.debug(dataObj.UserName__c);
        System.debug(dataObj.Password__c);
        request.setEndpoint(dataObj.Endpoint_URL__c);
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeStringField('email', dataObj.UserName__c);
        generator.writeStringField('mfaCode', '');
        generator.writeStringField('password', dataObj.Password__c);
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        System.debug(parameters);
        request.setBody(parameters);
        
        HttpResponse response = new Http().send(request);
        
        // Process response.
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
        {
            string cookie=response.getHeader('set-cookie');
            string[] cookiesArr= cookie.split(';');
            //token= cookiesArr[0].substring(cookiesArr[0].indexOf('=')+1,cookiesArr[0].length());
            token=cookiesArr[0];
            System.debug('token '+token);
            
            
            
        }
        else
        {
            system.debug(response.getBody());
        }
        
        // Create account 
        //AddAccount(token);
        GetAccountUsingSalesforceId(token);
        //GetAccountsUpdated(token);
        
    }
    private void GetAccountsUpdated(string token)
    {
        DateTime dt=DateTime.newInstance(Date.today().addDays(-1),Time.newInstance(0, 0, 0, 0));
        long millis=dt.getTime();
        long seconds=millis/1000;
        CloudPortalGetUpdatedAccountsApi obj= new CloudPortalGetUpdatedAccountsApi(seconds);
        obj.token=token;
        obj.execute();
        CloudPortalAccountList lst= obj.CPAccountList;
        System.debug(lst.accounts.size());
        if(lst.accounts.size()>0)
        {
            for(CloudPortalAccountList.CPAccount acc:lst.accounts)
            { System.debug(acc.salesforceId+' Name '+ acc.name +' Key '+ acc.accountKey);}
            
            
        }
    }
    
    private void GetAccountUsingSalesforceId(string token)
    {
        CloudPortalGetAccountBySalesforceIdApi obj = new CloudPortalGetAccountBySalesforceIdApi('001W000000KQAgM');
        obj.token=token;
        obj.execute();
        System.debug(obj.CPAccount);
        
        /* HttpRequest request = new HttpRequest();
request.setMethod('GET');
request.setHeader('charset', 'UTF-8');
request.setHeader('Content-Type', 'application/json');
request.setHeader('Cookie', token);
request.setEndpoint('https://portaldev.silver-peak.com/portal/apis/rest/salesforce/account?salesforceId=001W000000LUW6Y');
/*JSONGenerator generator = JSON.createGenerator(true);
generator.writeStartObject();
generator.writeStringField('name', 'Test Cloud Portal');
//generator.writeStringField('email', 'dbeckus@silver-peak.com');
//generator.writeStringField('phone', '22444444');
generator.writeStringField('salesforceId', '001W000000LUW6Y');
generator.writeEndObject();        
String parameters = generator.getAsString();
System.debug(parameters);
request.setBody(parameters);

HttpResponse response = new Http().send(request);

// Process response.
if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
{
system.debug(response.getBody());
string body= response.getBody();
}
else
{
system.debug(response.getBody());
}*/
    }
    private void AddAccount(string token)
    {
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('charset', 'UTF-8');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Cookie', token);
        request.setEndpoint('https://portaldev.silver-peak.com/portal/apis/rest/account/0');
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeStringField('name', 'Test Cloud Portal');
        //generator.writeStringField('email', 'dbeckus@silver-peak.com');
        //generator.writeStringField('phone', '22444444');
        generator.writeStringField('salesforceId', '001W000000LUW6Y');
        generator.writeEndObject();        
        String parameters = generator.getAsString();
        System.debug(parameters);
        request.setBody(parameters);
        
        HttpResponse response = new Http().send(request);
        
        // Process response.
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
        {
            system.debug(response.getBody());
            string body= response.getBody();
        }
        else
        {
            system.debug(response.getBody());
        }
    }
    
    public static integer GetYearsFromString(string inputData)
    {
        integer outputNumber=1;        
        Pattern p = Pattern.compile('\\d+');
        Matcher m = p.matcher(inputData);
        while(m.find()) {
            outputNumber=integer.valueOf(m.group());
        }
        return outputNumber;
    }
}