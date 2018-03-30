public with sharing class HPartnerPortalSSOStub
{
    private static final String FAILD_TO_CREATE_DEPARTMENT_MSG = 'Failed to create a department, please contact your system administrator.';
    private static final String FAILD_TO_CREATE_LEARNER_MSG = 'Failed to create your leaner account, please contact your system administrator.';
    private static final String FAILD_TO_UPDATE_LEARNER_MSG = 'Failed to update your leaner account, please contact your system administrator.';
    private static final String INVALID_CONTACT_MSG = 'Contact without account.';
    private static final String DEFAULT_PARENT_DEPARTMENT_ID = 'b773d051-47fb-4119-9154-fa0d5a749801';//85750 LMS AccountName='Partners'
    
    private static String ssoBase = 'https://partners.silver-peak.com/idp/login?app=0sp380000004CMo';
    private static String adminKey = '33e4e49e-a306-42f9-9230-3a79cdd08d04';//43a8764c-d95b-4f6b-b563-6ad5ffc06f97;
    private static String httpLoginBase='https://silverpeaksystems.myabsorb.com/api/Rest/v1/Authenticate?username=prane@silver-peak.com&password=Test-1234&privateKey=33e4e49e-a306-42f9-9230-3a79cdd08d04';
    
    public static String getHttpToken()
    {
        string token='';
        
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('charset', 'UTF-8');
        request.setHeader('Content-Type', 'application/json'); 
        request.setEndpoint(httpLoginBase);
        request.setBody('');
        HttpResponse response = new Http().send(request);
        
        // Process response.
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 400)
        {
            system.debug(response.getStatusCode());
            
            token=response.getBody();
            token=token.substring(1,token.length()-1);
            System.debug('token'+token);
        }
        else
        {
            system.debug(response.getBody());
        }
        
        return token;
    }
    
    
    public static String getSSOLink(Id uid)
    {
        User currentUser = [select Id, UserName, Email, ContactId, Contact.FirstName, Contact.LastName, Contact.Email, 
                            Contact.AccountId, Contact.Account.Name, Contact.Account.Description, Contact.Account.BillingCity, 
                            Contact.Account.ParentId
                            from User where Id = :uid];
        if(currentUser.ContactId != null)
        {
            String username = currentUser.Email; //currentUser.UserName.removeEnd('.sp');
            Contact currentContact = [select Id, FirstName, LastName, Title, Email, AccountId, Account.ParentId, (select Id, LMSUserName__c, LMSUserId__c, Dell_Segment__c from Partner_Contacts_Profile__r) from Contact where Id = :currentUser.ContactId];
            
            Set<Id> setAcctIds= new Set<Id>{currentContact.AccountId,currentContact.Account.ParentId};
                System.debug('setAcctIds '+setAcctIds);
            Map<Id, Account> relatedAccounts = new Map<Id, Account>([select Id, Name, Description, BillingCity, BillingCountry, GEO_Supported__c, ParentId from Account where Id in:setAcctIds]);
            System.debug('relatedAccounts.size'+ relatedAccounts.size());
            Account currentAccount = relatedAccounts.get(currentContact.AccountId);
            Account parentAccount = relatedAccounts.get(currentContact.Account.ParentId);
            System.debug('parentAccount '+parentAccount);
            System.debug('currentAccount ' + currentAccount);
            String token;
            if(Test.isRunningTest())
            {
                token = 'x1x2x3x4x5x6x7';
            }
            else
            {
                token = getHttpToken();
            }
            
            string departmentId = validateDepartment(currentAccount, token);
            string parentDepartmentId=null;
            
            if(parentAccount!=null)
                parentDepartmentId=validateDepartment(parentAccount, token);
            System.debug('departmentId'+ departmentId);
            System.debug('parentDepartmentId'+ parentDepartmentId);
            if(departmentId == null || String.isBlank(departmentId))
            {
                departmentId = createDepartment(currentAccount, parentDepartmentId, token);
            }
            
            // Creates lms user
            HPartnerPortalStudentInfo studentInfo= validateLearner(username, token);
            if(studentInfo==null)
            {
                String studentId = createLearner(currentContact, departmentId, username, token,currentAccount);
                System.debug('studentId' + studentId);
                
            }
            else
            {
                if(studentInfo.DepartmentId!=departmentId) // As per conv with Steve update the departmetnId               
                {
                    updateLearner(studentInfo, departmentId,token);
                }
            }
            return ssoBase;
            
        }
        else
        {
            return null;
        }
        
        return null;
    }
    
    
    /**
* Return value status:
* 1. Account profile has Id: valid LmsDepartmentId__c;
* 2. Account profile doesn't have Id:
*  2.1 has LmsDepartmentId__c: valid department name;
*  2.2 doesn't have has LmsDepartmentId__c: invalid department name, need to create.
*/
    @testVisible
    private static string validateDepartment(Account currentAccount, String token)
    {
        System.debug('validateDepartment');
        string departmentId=null;
        String departmentName = currentAccount.Name;
        System.debug('department'+departmentName);
        HPartnerPortalGetDepartmentsByExtIdApi resultById = validateDepartmentBySalesforceId(currentAccount.Id, token);
        
        if(resultById.isSucceed && resultById.departments != null && resultById.departments.size() > 0)
        {
            departmentId=String.valueOf(resultById.departments[0].Id);
            System.debug('departmentId' + departmentId);
            return departmentId;
        }
        
        HPartnerPortalGetDepartmentsApi result = validateDepartmentByName(departmentName, token);
        if(result.isSucceed && result.departments != null && result.departments.size() > 0)
        {
            departmentId=String.valueOf(result.departments[0].Id);
            System.debug('departmentId' + departmentId);
            return departmentId;
        }
        return null;
    }
    
    
    @testVisible
    private static HPartnerPortalGetDepartmentsByExtIdApi validateDepartmentBySalesforceId(String salesforceId, String token)
    {
        try
        {
            System.debug('validateDepartmentBySalesforceId');
            HPartnerPortalGetDepartmentsByExtIdApi obj = new HPartnerPortalGetDepartmentsByExtIdApi(token,salesforceId);
            obj.execute();
            return obj;  
        }
        catch(Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }    
        return null;
    }
    @testVisible
    private static HPartnerPortalGetDepartmentsApi validateDepartmentByName(String departmentName, String token)
    {
        try
        {
            System.debug('validateDepartmentByName');
            HPartnerPortalGetDepartmentsApi obj = new HPartnerPortalGetDepartmentsApi(token, departmentName);
            obj.execute();
            System.debug('HPartnerPortalGetDepartmentsApi'+obj);
            return obj;
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            throw new PartnerPortalSSOException(ex.getMessage());
        }
    }
    
    
    
    @testVisible
    private static String createDepartment(Account currentAccount, string parentDepartmentId, String token)
    {
        System.debug('createDepartment');
        Map<String, String> departmentParams = new Map<String, String>();
        departmentParams.put('name', currentAccount.Name);
        departmentParams.put('ExternalId', currentAccount.Id);
        if(parentDepartmentId != null && !string.isBlank(parentDepartmentId))
        {
            departmentParams.put('ParentId',parentDepartmentId);
        }
        else
        {
            departmentParams.put('ParentId', DEFAULT_PARENT_DEPARTMENT_ID);
        }
        
        HPartnerPortalCreateDepartmentApi createDepartmentApi = new HPartnerPortalCreateDepartmentApi(token,departmentParams);
        createDepartmentApi.execute();
        
        system.debug(createDepartmentApi);
        
        if(createDepartmentApi.isSucceed && createDepartmentApi.departmentId != null)
        {
            return createDepartmentApi.departmentId;
        }
        else
        {
            throw new PartnerPortalSSOException(FAILD_TO_CREATE_DEPARTMENT_MSG);
        }
    }
    @testVisible
    private static HPartnerPortalStudentInfo validateLearner(String username, String token)
    {
        try
        {
            //Map<String, String> studentParams = new Map<String, String>{'username'=>username};
            HPartnerPortalGetStudentsApi obj = new HPartnerPortalGetStudentsApi(token, username);
            obj.execute();
            System.debug('getStudents'+obj.students);
            if(obj.students!=null && obj.students.size()>0)
            {
                return obj.students[0];
            }
            
        }
        catch (Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }
        return null;
    }
    @testVisible
    private static String createLearner(Contact currentContact, String departmentId, String username, String token,Account acc)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('username', username);
        studentParams.put('firstName', currentContact.FirstName);
        studentParams.put('lastName', currentContact.LastName);
        studentParams.put('JobTitle', currentContact.Title);
        studentParams.put('emailAddress', username);
        studentParams.put('departmentId', departmentId);
        studentParams.put('location', acc.GEO_Supported__c);
        
        System.debug('studentParams '+ studentParams);
        HPartnerPortalCreateLearnerApi createLearnerApi = new HPartnerPortalCreateLearnerApi(token,studentParams);
        createLearnerApi.execute();
        if(!createLearnerApi.isSucceed)
        {
            throw new PartnerPortalSSOException(FAILD_TO_CREATE_LEARNER_MSG);
        }
        return createLearnerApi.studentId;
    }
    @testVisible
    private static Boolean updateLearner(HPartnerPortalStudentInfo studentInfo,string departmentId, String token)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('Id', studentInfo.Id);
        studentParams.put('DepartmentId', departmentId);
        studentParams.put('Username', studentInfo.Username);
        studentParams.put('FirstName', studentInfo.FirstName);
        studentParams.put('LastName', studentInfo.LastName);
        studentParams.put('EmailAddress', studentInfo.EmailAddress);
        
        System.debug(studentParams);
        HPartnerPortalUpdateLearnerApi updateLearnerApi = new HPartnerPortalUpdateLearnerApi(studentParams, token);
        updateLearnerApi.execute();
        if(updateLearnerApi.isSucceed)
            return true;
        if(!updateLearnerApi.isSucceed)
        {
            throw new PartnerPortalSSOException(FAILD_TO_UPDATE_LEARNER_MSG);
        }
        return false;
    }
    
    
}