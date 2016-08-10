public without sharing class PartnerPortalSSOStub
{
    private static final String FAILD_TO_CREATE_DEPARTMENT_MSG = 'Failed to create a department, please contact your system administrator.';
    private static final String FAILD_TO_CREATE_LEARNER_MSG = 'Failed to create your leaner account, please contact your system administrator.';
    private static final String INVALID_CONTACT_MSG = 'Contact without account.';
    private static final String DEFAULT_PARENT_DEPARTMENT_ID = '85750';

    private static String ssoBase = 'http://training.silver-peak.com/get.ashx?method=sso';
    private static String adminId = 'training@silver-peak.com';
    private static String adminKey = 'f1698f6ec979bf9fe3a16c62732cfff0';
    private static String httpLoginBase='https://silverpeaksystems-migration.sandbox.myabsorb.com/api/Rest/v1/Authenticate?username=prane@silver-peak.com&password=test@2505&privateKey=a750ad20-34ff-4f05-a292-8a227c323441';
    public static String getToken()
    {
        webservicesAbsorbtrainingCom.Main2Soap soapClient = new webservicesAbsorbtrainingCom.Main2Soap();
        String token = soapClient.DoLogin(adminId, hashAdminKey());
        return token;
    }
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
                token = getToken();
            }
            String departmentId;
            //Boolean departmentValid = validateDepartment(currentAccount, token);
            Partner_Account_Profile__c deptProfile = validateDepartment(currentAccount, token);
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
                String studentId = createLearner(currentContact, departmentId, username, token);
                
                // updates the student country and student location.
                updateLearner(studentId, currentAccount.BillingCountry, currentAccount.GEO_Supported__c, token);
                
                // writes LMS username back to SF contact. 
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
                upsert contactProfile;
            }
            
            /* To avoid dml operation before call out.*/
            // Writes lms department id back to account profile.
            //if(!departmentValid)
            if(deptProfile.Id == null)
            {
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
                upsert accountProfile;
            }
            return ssoBase + '&SSOID=' + username + '&SSOKey=' + md5Hash(username);

        }
        else
        {
            return null;
        }
    }

    public static String md5Hash(String value)
    {
        return EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(value + adminKey)));
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
        return accountProfile;
    }
    /*
    private static Boolean validateDepartment(Account currentAccount, String token)
    {
        Boolean result;
        //Account currentAccount = [select Id, Name, Description, BillingCity, ParentId, (select Id, LmsDepartmentName__c, LmsDepartmentId__c from Partner_Accounts_Profile__r) from Account where Id = :departmentId];
        String departmentName = currentAccount.Name;
        if(currentAccount != null && currentAccount.Partner_Accounts_Profile__r != null 
            && currentAccount.Partner_Accounts_Profile__r.size() > 0)
        {
            if(String.isNotBlank(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c))
            {
                return validateDepartmentById(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c, token);
            }
            else if(String.isNotBlank(currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentName__c))
            {
                departmentName = currentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentName__c;
            }
        }

        result = validateDepartmentByName(departmentName, token);
        return result;
    }
    */
    private static Boolean validateDepartmentById(String departmentId, String token)
    {
        try
        {
            HPartnerPortalGetDepartmentsApi getDepartmentApi = new HPartnerPortalGetDepartmentsApi(departmentId, token);
            getDepartmentApi.execute();
            return getDepartmentApi.isSucceed;    
        }
        catch(Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }    
        return false;
    }

    private static HPartnerPortalGetDepartmentsApi validateDepartmentByName(String departmentName, String token)
    {
        try
        {
            //Map<String, String> params = new Map<String, String>{'departmentname'=>departmentName};
            HPartnerPortalGetDepartmentsApi getDepartmentsApi = new HPartnerPortalGetDepartmentsApi(token, departmentName);
            getDepartmentsApi.execute();
            return getDepartmentsApi;   
        }
        catch(Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }
    }
    /*
    private static Boolean validateDepartmentByName(String departmentName, String token)
    {
        try
        {
            Map<String, String> params = new Map<String, String>{'departmentname'=>departmentName};
            PartnerPortalGetDepartmentsApi getDepartmentsApi = new PartnerPortalGetDepartmentsApi(token, params);
            getDepartmentsApi.execute();
            return getDepartmentsApi.isSucceed;   
        }
        catch(Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }
        return false;
    }
    */
    private static String createDepartment(Account currentAccount, Account parentAccount, String token)
    {
        Map<String, String> departmentParams = new Map<String, String>();
        departmentParams.put('name', currentAccount.Name);
        //departmentParams.put('notes', currentAccount.Description);
        departmentParams.put('locations', currentAccount.BillingCity);
        //departmentParams.put('token', token);
        
        if(parentAccount != null && parentAccount.Partner_Accounts_Profile__r != null && parentAccount.Partner_Accounts_Profile__r.size() > 0 && String.isNotBlank(parentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c))
        {
            departmentParams.put('parentDeptId', parentAccount.Partner_Accounts_Profile__r[0].LmsDepartmentId__c);
        }
        else
        {
            departmentParams.put('parentDeptId', DEFAULT_PARENT_DEPARTMENT_ID);
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

    private static Boolean validateLearner(String username, String token)
    {
        try
        {
            //Map<String, String> studentParams = new Map<String, String>{'username'=>username};
            HPartnerPortalGetStudentsApi getStudentsApi = new HPartnerPortalGetStudentsApi(token, username);
            getStudentsApi.execute();
            return getStudentsApi.isSucceed;
        }
        catch (Exception ex)
        {
            throw new PartnerPortalSSOException(ex.getMessage());
        }
        return false;
    }

    private static String createLearner(Contact currentContact, String departmentId, String username, String token)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('username', username);
        studentParams.put('firstName', currentContact.FirstName);
        studentParams.put('lastName', currentContact.LastName);
        studentParams.put('JobTitle', currentContact.Title);
        studentParams.put('emailAddress', username);
        studentParams.put('departmentId', departmentId);
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

    private static void updateLearner(String studentId, String country, String location, String token)
    {
        Map<String, String> studentParams = new Map<String, String>();
        studentParams.put('studentId', studentId);
        //studentParams.put('Country', country);
        studentParams.put('Location', location);
 		HPartnerPortalUpdateLearnerApi updateLearnerApi = new HPartnerPortalUpdateLearnerApi(studentParams, token);
        updateLearnerApi.execute();
        if(!updateLearnerApi.isSucceed)
        {
            throw new PartnerPortalSSOException(FAILD_TO_CREATE_LEARNER_MSG);
        }
    }

    private static String hashAdminKey()
    {
        return md5Hash(adminId);
    }
}