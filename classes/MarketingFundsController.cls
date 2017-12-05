/*
*  Controller of VF Page MarketingFunds
*  05AUG2016 @Author SNAPBI
*  @Changelog
*  01DEC2016 Daniel - update: add upload large file(exceed 4.3M) functionality.
*  02AUG2017 Daniel - update: update attached file to Amazon S3 file and create a record in SFDC
*  07Sep2017 Daniel - update: add edit functionality.
*  17OCT2017 Daniel - update: add verification for this page and controller.
*/
global without Sharing class MarketingFundsController
{
    public MDF_Request__c request { get; set; }
    public String accountList { get; set; }
    public String eventAgenda { get; set; }
    public String invoice { get; set; }
    public List<String> proofs { get; set; }
    public String attendance { get; set;}
    public String EventMaterials {get; set; }
    public String eventDetails {get; set; }
    public Partner_Account_Profile__c  pap1 { get; set; } //just for data binding of the region/country fields
    public String userProfile { get; set; }
    public Boolean completedMDF { get; set; }
    public Boolean editable { get; set; }
    public Boolean resultEditable { get; set; }
    
    private double estimatedAmount;
    public MarketingFundsController()
    {
        eventDetails = '';
        userProfile = '';
        String requestId = apexPages.currentPage().getParameters().get('id');
        proofs = new List<String>();
        completedMDF = false;
        request = getMDF(requestId);
        EventMaterials = getEventMaterials();
        pap1 = new Partner_Account_Profile__c();
        String profileId = UserInfo.getProfileId();
        List<profile> pro = [Select Id, Name from profile where Id =: profileId];
        if(pro.size() > 0)
        {
            if(pro[0].Name == 'Silver Peak Partner Community Profile')
            {
                String anRequestId = isAnonymousUser();
                if(String.isNotBlank(anRequestId)){
                    userProfile = 'siteUser';
					request = getMDF(anRequestId);
                }
                else 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'The page you requested has expired, or the record has been submitted. If you have any questions, please contact us at channel@silver-peak.com.'));
                }
            }
            else
            {
                if(String.isBlank(request.Id) || checkMFRVisibility(request.Id, userInfo.getUserId()))
                {
                    if(pro[0].Name == '13g-SP Partner Community')
                    {
                        userProfile = 'loginUser';
                    }
                    else
                    {
                        userProfile = 'otherUser';
                    }
                    if(String.isNotBlank(request.Id))
                    {
                        getFile(request.Id);
                    }
                }
                else
                {
                    request = new MDF_Request__c();
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Invilid url. If you have any questions, please contact us at channel@silver-peak.com.'));
                }
            }
        }
        if(String.isNotBlank(request.Id) && String.isNotBlank(request.Event_Materials_Requested__c))
        {
            eventDetails = request.Event_Materials_Requested__c.replaceAll('\r\n',';');
        }
        editable = String.isBlank(request.Id) || (userProfile == 'siteUser' && request.Approval_Status__c == 'Unsubmitted');
        resultEditable = request.Approval_Status__c == 'Approved' && !request.Activity_Complete__c;
        pap1.Country__c = String.isBlank(request.Event_Location_Country__c) ? '' : request.Event_Location_Country__c;
        pap1.State__c = String.isBlank(request.Event_Location_State__c) ? '' : request.Event_Location_State__c;
        if(String.isNotBlank(request.Id) && request.Activity_Complete__c != true)
        {
			 estimatedAmount = request.Estimated_Silver_Peak_Amount__c;
        }
        system.debug(estimatedAmount);
    }
    
    public String getAWSConfig()
    {
        AWSConfig__c config = AWSConfig__c.getInstance('Default');
        if(config != null)
        {
            return JSON.serialize(config);
        }
        return '';
    }
    
    public PageReference saveMDF()
    {
        if(!validateFileds())
        {
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(String.isBlank(request.OwnerId))
            {
                request.OwnerId = UserInfo.getUserId();   
            }
            if(String.isNotBlank(eventDetails))
            {
                request.Event_Materials_Requested__c = eventDetails.replaceAll(';', '\r\n');
            }
            //binding data from Partner_Portal_Account_Profile_Address__c to MDF_Reqeust__c
            if(String.isNotBlank(pap1.Country__c))
            {
                request.Event_Location_Country__c = pap1.Country__c;
            }
            if(String.isNotBlank(pap1.State__c))
            {
                request.Event_Location_State__c = pap1.State__c;
            }
            //
            if(String.isNotBlank(request.Id) && Approval.isLocked(request.Id))
            {
            	Approval.UnlockResult result = Approval.Unlock(request.Id);
                upsert request;
                Approval.LockResult resule = Approval.lock(request.Id);
            }
            else
            {
                upsert request;
            }
            if(request.Approval_Status__c == 'Unsubmitted' || String.isBlank(request.Approval_Status__c))
            {
            	submitMDFToProcess(request.Id);   
            }
            request = getMDF(request.Id);
            //TODO:
            If(rejectPRprocess(request))
            {
				submitMDFToProcess(request.Purchasing_Request__c);
            }
            completedMDF = true;
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            completedMDF = false;
			SilverPeakUtils.logException(ex);
            ApexPages.AddMessages(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getStackTraceString()));
        }
        return null;
    }
    
    public PageReference editMDF()
    {
        system.debug(estimatedAmount);
        editable = true;
        return null;
    }

    public PageReference editMDFResult()
    {
        resultEditable = true;
        return null;
    }

    public Boolean validateFileds()
    {
        Boolean isPassed = true;
        if(request.Type_of_Program__c == 'Enablement')
        {
            if(String.isBlank(request.Event_Location_City__c))
            {
                isPassed = false;
                request.Event_Location_City__c.addError('City cannot be blank');
            }
            if(String.isBlank(pap1.Country__c))
            {
                isPassed = false;
                pap1.Country__c.addError('Country cannot be blank');
            }
            if(String.isBlank(pap1.State__c))
            {
                isPassed = false;
                pap1.State__c.addError('State cannot be blank');
            }
            if(String.isBlank(request.Event_Location_Zip__c))
            {
                isPassed = false;
                request.Event_Location_Zip__c.addError('Postal Code cannot be blank');
            }
        }
        else
        {   
            if(request.Expected_Audience_Size__c == null)
            {
                isPassed = false;
                request.Expected_Audience_Size__c.addError('Expected Audience Size cannot be blank');
            }
            if(request.Expected_Number_of_Leads__c == null)
            {
                isPassed = false;
                request.Expected_Number_of_Leads__c.addError('Expected number of Leads cannot be blank');
            }
            if(request.Expected_Audience_Size__c != null && request.Expected_Number_of_Leads__c != null && request.Expected_Number_of_Leads__c > request.Expected_Audience_Size__c)
            {
                isPassed = false;
                request.Expected_Number_of_Leads__c.addError('Expected number of Leads not to exceed the expected audience size');
            }
            if(request.Est_Value_of_Expected_Opportunities__c == null)
            {
                isPassed = false;
                request.Est_Value_of_Expected_Opportunities__c.addError('Estimated Value of Opportunities cannot be blank');
            }
            if(String.isBlank(request.Silver_Peak_Speaking_Opportunity__c))
            {
                isPassed = false;
                request.Silver_Peak_Speaking_Opportunity__c.addError('Silver Peak Speaking Opportunities cannot be blank');
            }
            else if(request.Silver_Peak_Speaking_Opportunity__c == 'Yes')
            {
                if(String.isBlank(request.Speaking_Opportunity_Duration__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Duration__c.addError('Duration cannot be blank');
                }
                if(String.isBlank(request.Speaking_Opportunity_Type__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Type__c.addError('Type cannot be blank');
                }
                if(String.isBlank(request.Speaking_Opportunity_Abstract__c))
                {
                    isPassed = false;
                    request.Speaking_Opportunity_Abstract__c.addError('Abstract cannot be blank');
                }
            }
            if(String.isBlank(request.Event_Location_City__c))
            {
                isPassed = false;
                request.Event_Location_City__c.addError('Event City cannot be blank');
            }
            if(String.isBlank(pap1.Country__c))
            {
                isPassed = false;
                pap1.Country__c.addError('Event Country cannot be blank');
            }
            if(String.isBlank(pap1.State__c))
            {
                isPassed = false;
                pap1.State__c.addError('Event State cannot be blank');
            }
            if(String.isBlank(request.Event_Location_Zip__c))
            {
                isPassed = false;
                request.Event_Location_Zip__c.addError('Postal Code cannot be blank');
            }
        }
        return isPassed;
    }
    
    private MDF_Request__c getMDF(String requetId)
    {
        List<String> fields = new List<String>(MDF_Request__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ' select ' + String.join(fields, ',')
            + ' from MDF_Request__c'
            + ' where Id=:requetId limit 1';
        List<MDF_Request__c> requests = Database.query(soql);
        return requests.size() == 1 ? requests[0] : new MDF_Request__c();
    }
    
    public void submitMDFToProcess(Id requestId)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
        req.setObjectId(requestId);
        Approval.ProcessResult result = Approval.Process(req);
    }
    
    public String getEventMaterials()
    {
        String eventMaterials = '';
        
        Schema.DescribeFieldResult fieldResult = MDF_Request__c.Event_Materials__c .getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            eventMaterials += f.getValue() + ';';
        }
        return eventMaterials.removeEnd(';');
    }
    
    public String isAnonymousUser()
    {   
        String c = apexPages.currentPage().getParameters().get('id');   
        if(String.isNotBlank(c))
        {
            String url = '';
            try
            {
                //replace $ with +
                url = Crypto.decryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), EncodingUtil.base64Decode(c.replace('$','+'))).toString();
            }
            catch(Exception ex)
            {
                return null;
            }
            String [] idAndDate = url.split('\\|');
            if(idAndDate.size() == 2)
            {
                try{
                    String[] urlDate = idAndDate[1].split('\\/');
                    String year = urlDate[2];
                    string month = urlDate[0];
                    String day = urlDate[1];
                    date d = date.valueOf(year + '-' + month + '-' + day);
                    return d.daysBetween(date.today()) <= 3?  idAndDate[0] : null;
                }
                catch(Exception ex)
                {
                    return null;
                }
            }
            else
            {
                return null;
            }
        }
        else
        {
            return null;
        }
    }
    
    public void getFile (String requestId)
    {
        for(Ensemblestorage__EnsembleFile__c file : [Select Id, Name, file_type__c from Ensemblestorage__EnsembleFile__c where Funding_Requests__c =: requestId])
        {
            if(file.file_type__c.containsIgnoreCase('Target Account'))
            {
                accountList = file.Name;
            }
            else if(file.file_type__c.containsIgnoreCase('Event Agenda'))
            {
                eventAgenda = file.Name;
            }
            else if(file.file_type__c.containsIgnoreCase('invoice'))
            {
                invoice = file.Name;
            }
            else if(file.file_type__c.containsIgnoreCase('proof'))
            {
                proofs.add(file.Name);
            }
            else if(file.file_type__c.containsIgnoreCase('Attendance List'))
            {
                attendance = file.Name;
            }
        }
    }
    
    global class MDF
    {
        public String Total_Attendees { get; set; }
        public String Event_Results_Opportunities { get; set;}
        public String Total_Qualified_Leads { get; set; }
        public String Estimated_Pipeline_Value { get; set; }
        public String Result_Detail { get; set; }
        public String Requested_Reimbursement_Amount { get; set; }
        public String Topic_Course { get; set; }
        public String Number_of_Certifications { get; set; }
        public Integer invoice { get; set; }
        public Integer proof { get; set; }
        public Integer attendance { get; set; }
    }
    
    global class AWSResponse
    {
        public String FileName { get; set; }
        public String S3Key { get; set; }
        public Decimal FileSize { get; set; }
        public String S3Bucket { get; set; }
        public String FileType { get; set; }
    }


    @RemoteAction
    global static String linkFileToMFR(AWSResponse UploadResponse, String mdfId, Boolean allUploaded, Boolean deleteProofs)
    {
        Ensemblestorage__EnsembleFile__c newFile = new Ensemblestorage__EnsembleFile__c();
        //AWSResponse response = (AWSResponse)JSON.deserialize(UploadResponse, AWSResponse.class);
        newFile.Name = UploadResponse.FileName;
        newFile.Ensemblestorage__FullName__c = UploadResponse.FileName;
        newFile.Ensemblestorage__S3Key__c = UploadResponse.S3Key;
        newFile.Ensemblestorage__Size__c = UploadResponse.FileSize;
        newFile.Ensemblestorage__S3Bucket__c = UploadResponse.S3Bucket;
        newFile.file_type__c = UploadResponse.FileType;
        newFile.Funding_Requests__c = mdfId;
        try
        {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.AllowFieldTruncation = true;
            newFile.setOptions(dml);
            insert newFile;
            if(newFile.file_type__c != 'Proof of Performance' || deleteProofs)
            {
                deleteFileinSFDC(mdfId, newFile.file_type__c, newFile.Id);
            }
            if(allUploaded)
            {
                MDF_Request__c mdf = [Select Id, Approval_Status__c from MDF_Request__c where Id =: mdfId];
                if(mdf.Approval_Status__c == 'Approved')
                {
                    mdf.Activity_Complete__c = true;
                    mdf.Feedback_Complete__c = true;
                    update mdf;
                }
                return 'allUploaded';
            }
            return 'successUploadedOne';
        }
        catch(Exception ex)
        {
            return 'Exception ' + ex.getMessage();
        }
    }
	
    private static void deleteFileinSFDC(String mdfId, String fileType, String newFileId)
    {
        List<Ensemblestorage__EnsembleFile__c> files = [Select Id from Ensemblestorage__EnsembleFile__c where Id !=: newFileId and Funding_Requests__c =: mdfId and file_type__c =: fileType];
        if(!files.isEmpty())
        {
            delete files;
        }
    }
    
    @RemoteAction
    global static String updateMDF(MDF mdf,String requestId)
    {
        SavePoint sp = Database.setSavepoint();
        if(String.isNotBlank(requestId))
        {
            MDF_Request__c req = [Select Id,Type_of_Program__c from MDF_Request__c where Id =: requestId];
            String errorMsg = validateMDF(mdf, req);
            if(String.isNotBlank(errorMsg))
            {
                return 'Error' + errorMsg;       
            }
            else
            {
                try
                {
                    upsert convertMDF(mdf, req);
                    return  convertMDF(mdf, req).Id;
                }
                catch(Exception ex)
                {
                    Database.rollback(sp);
                    ApexPages.addMessages(ex);
                    return 'exception' + ex.getMessage();
                } 
            } 
        }
        else
        {
            return 'Error: requestId is null';
        }
    }
    
    private static MDF_Request__c convertMDF(MDF mdf, MDF_Request__c request)
    {
        if(request.Type_of_Program__c != 'Enablement')
        {
            request.Event_Results_Opportunities__c = Decimal.valueOf(mdf.Event_Results_Opportunities);
            request.Total_Qualified_Leads__c = Decimal.valueOf(mdf.Total_Qualified_Leads);
            request.Estimated_Pipeline_Value__c = Decimal.valueOf(mdf.Estimated_Pipeline_Value);
        }
        else
        {
            request.Topic_Course__c = mdf.Topic_Course;
            request.Number_of_Certifications__c = Decimal.valueOf(mdf.Number_of_Certifications);
        }
        request.Total_Attendees__c = Decimal.valueOf(mdf.Total_Attendees);
        request.Result_Detail__c = mdf.Result_Detail;
        request.Requested_Reimbursement_Amount__c = Decimal.valueOf(mdf.Requested_Reimbursement_Amount);
        return request;
    }
    
    private static String validateMDF(MDF mdf, MDF_Request__c request)
    {
        String errorMsg = '';
        String reminderMsg = 'Invalid number;';
        String reminderCur = 'Invalid currency;';
        if(request.Type_of_Program__c != 'Enablement')
        {
            errorMsg = handleNumber(mdf.Event_Results_Opportunities, 'opportunities', reminderMsg) + handleNumber(mdf.Total_Qualified_Leads, 'leads', reminderMsg) + handleNumber(mdf.Estimated_Pipeline_Value, 'pipeline', reminderCur);
        }
        else
        {
            errorMsg = String.isBlank(mdf.Topic_Course) ? 'topic:Cannot be blank;' : '' + handleNumber(mdf.Number_of_Certifications, 'certifications', reminderMsg);
        }
        errorMsg += String.isBlank(mdf.Result_Detail) ? 'result:Cannot be blank;' : '' + handleNumber(mdf.Total_Attendees, 'attendees', reminderMsg) + handleNumber(mdf.Requested_Reimbursement_Amount, 'amount', reminderCur);
        return errorMsg;
    }
    
    private static String handleNumber(String num, String elem, String reminder)
    {
        if(String.isBlank(num) || num == 'undifined')
        {
            return elem + ':' + 'Cannot be blank;';
        }
        else
        {
            try
            {
                Decimal d = Decimal.valueOf(num);
                return '';
            }
            catch(Exception ex)
            {
                return elem + ':' + reminder;
            }
        }
    }
    
    private static String haneldNumber(Integer num, String elem)
    {
        return num > 0 ? '' : elem + ':Cannot be blank;';
    }
    
    private Boolean rejectPRprocess(MDF_Request__c request)
    {
        if(estimatedAmount != null && request.Purchasing_Request__c != null && request.Estimated_Silver_Peak_Amount__c > estimatedAmount)
        {
            Boolean prSubmitted = false;
            for(Integer i = 0; i < 4; i++)
            {
                list<ProcessInstanceWorkitem> piws = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: request.Purchasing_Request__c];
                if(!piws.isEmpty())
                {
                    Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                    pwr.setWorkitemId(piws[0].Id);
                    pwr.setComments('The Estimated Silver Peak Amount of related funding request has been increased');
                    pwr.setAction('Reject');
                    Approval.ProcessResult result = Approval.process(pwr);
                    prSubmitted = true;
                }
                else
                {
                    break;
                }
            }
            return prSubmitted;
        }
        return false;
    }

    private Boolean checkMFRVisibility(String mfrId, String userId)
    {
        List<MDF_Request__c> mfrs = [Select Id, OwnerId from MDF_Request__c where Id =: mfrId];
        if(!mfrs.isEmpty())
        {
            return mfrs[0].ownerId == userId;
        }
        return false;
    }
}