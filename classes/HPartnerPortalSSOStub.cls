public with sharing class HPartnerPortalSSOStub
{
    private static final String FAILD_TO_CREATE_DEPARTMENT_MSG = 'Failed to create a department, please contact your system administrator.';
    private static final String FAILD_TO_CREATE_LEARNER_MSG = 'Failed to create your leaner account, please contact your system administrator.';
    private static final String INVALID_CONTACT_MSG = 'Contact without account.';
    private static final String DEFAULT_PARENT_DEPARTMENT_ID = '83a738a2-1c22-45d0-bf55-76a6daf18e18';//85750 LMS AccountName='Partners'
    
    private static String ssoBase = 'https://full-silverpeak.cs95.force.com/idp/login?app=0sp0x000000000L';
    private static String adminKey = '43a8764c-d95b-4f6b-b563-6ad5ffc06f97';
    private static String httpLoginBase='https://silverpeaksystems-migration.sandbox.myabsorb.com/api/Rest/v1/Authenticate?username=ithelp@silver-peak.com&password=Speak-123&privateKey=43a8764c-d95b-4f6b-b563-6ad5ffc06f97';
    
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
            if(currentContact != null && currentContact.Partner_Contacts_Profile__r != null && currentContact.Partner_Contacts_Profile__r.size() > 0 && String.isNotBlank(currentContact.Partner_Contacts_Profile__r[0].LMSUserName__c))
            {
                username = currentContact.Partner_Contacts_Profile__r[0].LMSUserName__c;
            }
            
            Map<Id, Account> relatedAccounts = new Map<Id, Account>([select Id, Name, Description, BillingCity, BillingCountry, GEO_Supported__c, ParentId, (select Id, LmsDepartmentName__c, LmsDepartmentId__c from Partner_Accounts_Profile__r) from Account where Id = :currentContact.AccountId or Id = :currentContact.Account.ParentId]);
            Account currentAccount = relatedAccounts.get(currentContact.AccountId);
            Account parentAccount = relatedAccounts.get(currentContact.Account.ParentId);
            
            String token;
            if(Test.isRunningTest())
            {
                token = 'x1x2x3x4x5x6x7';
            }
            else
            {
                token = getHttpToken();
            }
            String departmentId;
            //Boolean departmentValid = validateDepartment(currentAccount, token);
            Partner_Account_Profile__c deptProfile = validateDepartment(currentAccount, token);
            System.debug('depTProfile'+ deptProfile);
            if(deptProfile.Id == null && String.isBlank(deptProfile.LmsDepartmentId__c))
            {
                departmentId = createDepartment(currentAccount, parentAccount, token);
            }
            else
            {
                //departmentId  = currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c;
                departmentId = deptProfile.LmsDepartmentId__c;
            }
            
            // Creates lms user
            if(!validateLearner(username, token))
            {
                String studentId = createLearner(currentContact, departmentId, username, token,currentAccount);
                System.debug('studentId' + studentId);
                Partner_Contact_Profile__c contactProfile;
                if(currentContact.Partner_Contacts_Profile__r != null && currentContact.Partner_Contacts_Profile__r.size() > 0)
                {
                    contactProfile = currentContact.Partner_Contacts_Profile__r[0];
                }
                else
                {
                    contactProfile = new Partner_Contact_Profile__c(Contact__c = currentContact.Id);
                }
                contactProfile.LMSUserName__c = username;
                contactProfile.LMSUserId__c = studentId;
                System.debug('contactProfile' + contactProfile);
                upsert contactProfile;
            }
            if(deptProfile.Id == null)
            {
                System.debug('deptProfile.Id');
                Partner_Account_Profile__c accountProfile;
                if(currentAccount.Partner_Accounts_Profile__r != null && currentAccount.Partner_Accounts_Profile__r.size() > 0)
                {
                    accountProfile = currentAccount.Partner_Accounts_Profile__r[0];
                }
                else
                {
                    accountProfile = new Partner_Account_Profile__c(Account__c = currentAccount.Id);
                }
                accountProfile.LmsDepartmentId__c = departmentId;
                accountProfile.LmsDepartmentName__c = deptProfile.LmsDepartmentName__c;
                System.debug('accountProfile'+accountProfile);
                upsert accountProfile;
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
    private static Partner_Account_Profile__c validateDepartment(Account currentAccount, String token)
    {
        
        Partner_Account_Profile__c accountProfile = new Partner_Account_Profile__c();
        String departmentName = currentAccount.Name;
        if(currentAccount != null && currentAccount.Partner_Accounts_Profile__r != null 
           && currentAccount.Partner_Accounts_Profile__r.size() > 0)
        {
            
            if(String.isNotBlank(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c)
               && validateDepartmentById(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c, token))
            {
                return currentAccount.Partner_Accounts_Profile__r[0];
            }
            else if(String.isNotBlank(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentName__c))
            {
                departmentName = currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentName__c;
            }
        }
       
        HPartnerPortalGetDepartmentsApi result = validateDepartmentByName(departmentName, token);
        accountProfile.LmsDepartmentName__c = departmentName;
        if(result.isSucceed && result.departments != null && result.departments.size() > 0)
        {
            accountProfile.LmsDepartmentId__c = String.valueOf(result.departments[0].Id);
        }
        System.debug('****'+accountProfile.Name);
        return accountProfile;
    }
    
    public static Boolean validateDepartmentById(String departmentId, String token)
    {
        try
        {
            HPartnerPortalGetDepartmentApi getDepartmentApi = new HPartnerPortalGetDepartmentApi(departmentId, token);
            getDepartmentApi.execute();
            if(getDepartmentApi.department!=null)
            {
                return true;
            }
            return false;  
        }
        catch(Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }    
        return false;
    }
    
    public static HPartnerPortalGetDepartmentsApi validateDepartmentByName(String departmentName, String token)
    {
        try
        {
            //Map<String, String> params = new Map<String, String>{'departmentname'=>departmentName};
            HPartnerPortalGetDepartmentsApi obj = new HPartnerPortalGetDepartmentsApi(token, departmentName);
            System.debug('token'+token);
            obj.execute();
            System.debug('obj'+obj);
            return obj;
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            throw new PartnerPortalSSOException(ex.getMessage());
        }
    }
    
    
    public static String createDepartment(Account currentAccount, Account parentAccount, String token)
    {
        Map<String, String> departmentParams = new Map<String, String>();
        departmentParams.put('name', currentAccount.Name);
        //departmentParams.put('notes', currentAccount.Description);
        //departmentParams.put('locations', currentAccount.BillingCity);
        //departmentParams.put('token', token);
        
        if(parentAccount != null && parentAccount.Partner_Accounts_Profile__r != null && parentAccount.Partner_Accounts_Profile__r.size() > 0 && String.isNotBlank(parentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c))
        {
            departmentParams.put('ParentId', parentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c);
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
    
    public static Boolean validateLearner(String username, String token)
    {
        try
        {
            //Map<String, String> studentParams = new Map<String, String>{'username'=>username};
            HPartnerPortalGetStudentsApi obj = new HPartnerPortalGetStudentsApi(token, username);
            obj.execute();
            System.debug('getStudents'+obj.students);
            if(obj.students!=null && obj.students.size()>0)
            {
                return true;
            }
            return false;
        }
        catch (Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }
        return false;
    }
    
    public static String createLearner(Contact currentContact, String departmentId, String username, String token,Account acc)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('username', username);
        studentParams.put('firstName', currentContact.FirstName);
        studentParams.put('lastName', currentContact.LastName);
        studentParams.put('JobTitle', currentContact.Title);
        studentParams.put('emailAddress', username);
        studentParams.put('departmentId', departmentId);
        studentParams.put('location', acc.GEO_Supported__c);
        //studentParams.put('token', token);
        if(currentContact.Partner_Contacts_Profile__r != null && currentContact.Partner_Contacts_Profile__r.size() > 0)
        {
            studentParams.put('extra2', currentContact.Partner_Contacts_Profile__r[0].Dell_Segment__c);
        }
        
        HPartnerPortalCreateLearnerApi createLearnerApi = new HPartnerPortalCreateLearnerApi(token,studentParams);
        createLearnerApi.execute();
        if(!createLearnerApi.isSucceed)
        {
            throw new PartnerPortalSSOException(FAILD_TO_CREATE_LEARNER_MSG);
        }
        return createLearnerApi.studentId;
    }
    
    public static void updateLearner(String studentId, String country, String location, String token,Contact con)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('Id', studentId);
        studentParams.put('DepartmentId', '18a9be99-1089-468d-9099-25701197d562');
        studentParams.put('LastName', con.LastName);
        studentParams.put('FirstName', con.FirstName);
        studentParams.put('EmailAddress', con.Email);
        studentParams.put('UserName', con.Email);
        //studentParams.put('Country', country);
        studentParams.put('Location', location);
        HPartnerPortalUpdateLearnerApi updateLearnerApi = new HPartnerPortalUpdateLearnerApi(studentParams, token);
        updateLearnerApi.execute();
        if(!updateLearnerApi.isSucceed)
        {
            throw new PartnerPortalSSOException(FAILD_TO_CREATE_LEARNER_MSG);
        }
    }
    
    
}