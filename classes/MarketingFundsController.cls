/*
*  Controller of VF Page MarketingFunds
*  05AUG2016 @Author Daniel Wu
*  @Changelog
*  01DEC2016 Daniel - update: add upload large file(exceed 4.3M) functionality.
*/
global with sharing class MarketingFundsController 
{
    public MDF_Request__c request { get; set; }
    Public Attachment accountAttachment { get; set; }
    public Attachment eventAgendaAttachment { get; set; }
    public ContentDocumentLink invoice { get; set; }
    public List<ContentDocumentLink> proofs { get; set; }
    public ContentDocumentLink attendance { get; set;}
    public String EventMaterials {get; set; }
    public String eventDetails {get; set; }
    public Partner_Account_Profile__c  pap1 { get; set; } //just for data binding of the region/country fields
    public String userProfile { get; set; }
    
    public MarketingFundsController()
    {
        eventDetails = '';
        userProfile = '';
        String requestId = apexPages.currentPage().getParameters().get('id');
        accountAttachment = new Attachment();
        eventAgendaAttachment = new Attachment();
        invoice = new ContentDocumentLink();
        proofs = new List<ContentDocumentLink>();
        attendance = new ContentDocumentLink();
        request = new MDF_Request__c();
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
                    getAttcahment(anRequestId);
                }
                else 
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'The page you requested has expired, or the record has been submitted. If you have any questions, please contact us at channel@silver-peak.com.'));
                }
            }
            else if(pro[0].Name == '13g-SP Partner Community')
            {
                userProfile = 'loginUser';
                getAttcahment(requestId);
            }
            else
            {
                getAttcahment(requestId);
                userProfile = 'otherUser';
            }
            if(request.Activity_Complete__c == true)
            {
                getFile(request.Id);
            }
        }
        if(String.isNotBlank(request.Id) && String.isNotBlank(request.Event_Materials_Requested__c))
        {
            eventDetails = request.Event_Materials_Requested__c.replaceAll('\r\n',';');
        }
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
            upsert request;
            submitMDFToProcess(request.Id);
            request = getMDF(request.Id);
            if(request.Type_of_Program__c != 'Enablement')
            {
                if(String.isBlank(accountAttachment.ParentId)){
                    accountAttachment.ParentId = request.Id;
                }
                accountAttachment.Description = 'Target Account List';
                if(String.isBlank(eventAgendaAttachment.ParentId))
                {
                    eventAgendaAttachment.ParentId = request.Id;
                }
                eventAgendaAttachment.Description = 'Event Agenda';
                upsert accountAttachment;
                if(eventAgendaAttachment.Body != null)
                {
                    upsert eventAgendaAttachment;
                }
                accountAttachment = new Attachment(Id=accountAttachment.Id, Name=accountAttachment.Name);
                eventAgendaAttachment =new Attachment(Id=accountAttachment.Id, Name=accountAttachment.Name);
            }
            String reminder = userProfile == 'siteUser' ? 'Thank you for submitting your Marketing Fund request. We will review your submission and contact you shortly.' : 
            'Thank you for submitting your Marketing Fund request. We will review your submission and contact you shortly. To check the status of your request, please click the Track Requests tab above.'
                + '<br/><a style="color:#0000ee;margin:0;font-size:100%;" href="/s" target="_top">Click here to go back the home page </a> <br/> <a style="color:#0000ee;margin:0;font-size:100%;"href="/s/MarketingFunds" target="_top">Click here to submit another Marketing Fund request</a>';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,reminder));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.AddMessages(ex);
        }
        return null;
    }
    /*
    public PageReference saveApprovedMDF()
    {
        SavePoint sp = Database.setSavepoint();
        if(request.Approval_Status__c=='Approved')
        {
            request.Activity_Complete__c = true;
            request.Feedback_Complete__c = true;
        }
        try
        {
            upsert request;
            uploadFiles();
            String reminder = userProfile == 'siteUser' ? 'Thank you for submitting your activity results.' : 
            'Thank you for submitting your activity results.';
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,reminder));
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.AddMessages(ex);
        }
        return null;
    }
    */
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
            if(accountAttachment.Body == null)
            {
                accountAttachment.name.addError('Target Account List cannot be blank');
                isPassed = false;
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
                url = Crypto.decryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), EncodingUtil.base64Decode(c.replaceAll(' ','\\+'))).toString();
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
                    return d.daysBetween(date.today()) <= 3 ?  idAndDate[0] : null;
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
    
    public void getAttcahment (String requestId)
    {
        if(requestId instanceOf Id)
        {
            request = getMDF(requestId);
            if(request.Type_of_Program__c !='Enablement')
            {
                List<Attachment> atts = [Select Id, Name, Body, Description, ParentId  from Attachment where ParentId =:request.Id];
                if(!atts.isEmpty())
                {
                    for(Attachment att : atts)
                    {
                        if(att.Description == 'Target Account List')
                        {
                            accountAttachment = att;
                        }
                        else if(att.Description == 'Event Agenda')
                        {
                            eventAgendaAttachment = att;
                        }
                    }
                }
            }
        }
    }
    
    public void getFile (String requestId)
    {
        List<ContentDocumentLink> cdLinks = [Select Id, ContentDocumentId, ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId  from COntentDocumentLink where LinkedEntityId =: requestId];
        if(!cdLinks.isEmpty())
        {
            for(ContentDocumentLink cdLink : cdLinks)
            {
                if(cdLink.ContentDocument.Description != null && cdLink.ContentDocument.Description.toLowerCase().contains('invoice'))
                {
                    invoice = cdLink;
                }
                else if(cdLink.ContentDocument.Description != null && cdLink.ContentDocument.Description.toLowerCase().contains('proof'))
                {
                    proofs.add(cdLink);
                }
                else if(cdLink.ContentDocument.Description != null && cdLink.ContentDocument.Description.toLowerCase().contains('attendance'))
                {
                    attendance = cdLink;
                }
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
    
    global static MDF_Request__c convertMDF(MDF mdf, MDF_Request__c request)
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
    
    @RemoteAction
    global static String uploadFile(String fileBody, String fileName, String fileId, String requestId, String fileDescription, Boolean fileUploadCompleted)
    {
        if(String.isNotBlank(fileBody))
        {
            SavePoint sp = Database.setSavepoint();
            ContentVersion cv = getDocument(fileId);
            String newBody = cv.VersionData == null ? '' : EncodingUtil.base64Encode(cv.VersionData);
            newBody += fileBody;
            cv.VersionData = EncodingUtil.base64Decode(newBody);
            cv.Title = fileName;
            try
            {
                Boolean existedLink = false;
                if(String.isBlank(cv.Id))
                {
                    cv.PathOnClient = fileName;
                    cv.IsMajorVersion = false;
                    cv.Description = fileDescription;
                    existedLink = true;
                }
                upsert cv;
                ContentVersion newCv = [Select Id, ContentDocumentId from ContentVersion where Id =: cv.Id];
                if(existedLink == true)
                {
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = newCv.ContentDocumentId, LinkedEntityId = requestId,ShareType='V');
                    insert cdl;
                }
                if(fileUploadCompleted == true)
                {
                    MDF_Request__c mdf = [Select Id from MDF_Request__c where Id =: requestId];
                    mdf.Activity_Complete__c = true;
                    mdf.Feedback_Complete__c = true;
                    update mdf;
                }
                return cv.Id;
            }
            catch(Exception ex)
            {   
                Database.rollback(sp);
                return 'Exception ' + ex.getMessage();
            }
        }
        else 
        {
            return 'File body was null';
        }
    }
    
    @RemoteAction
    global static String linkFileToMFR(String mfrId, String cvId, Boolean fileUploadCompleted)
    {
        savepoint sp = Database.setSavepoint();
        List<ContentVersion> cv = [Select Id, ContentDocumentId from ContentVersion where Id =: cvId limit 1];
        if(!cv.isEmpty())
        {
            ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId = cv[0].ContentDocumentId, LinkedEntityId = mfrId, ShareType='V');
            try
            {
                insert cdl;
                if(fileUploadCompleted == true)
                {
                    MDF_Request__c mdf = [Select Id from MDF_Request__c where Id =: mfrId];
                    mdf.Activity_Complete__c = true;
                    mdf.Feedback_Complete__c = true;
                    update mdf;
                }
                return 'success';
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                return 'exception:' + ex.getMessage();
            }
        }
        return null;
    }
    
    global static ContentVersion getDocument(String fileId)
    {
        List<ContentVersion> cvs = [Select Id, VersionData, Title from ContentVersion where Id =: fileId];
        if(cvs.isEmpty())
        {
            return new ContentVersion();
        }
        else
        {
            return cvs[0];
        }
    }
    
    global static String validateMDF(MDF mdf, MDF_Request__c request)
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
        //errorMsg += haneldNumber(mdf.invoice, 'invoice') + haneldNumber(mdf.proof, 'proof') + haneldNumber(mdf.attendance, 'attendance');
        return errorMsg;
    }
    
    global static String handleNumber(String num, String elem, String reminder)
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
    
    global static String haneldNumber(Integer num, String elem)
    {
        return num > 0 ? '' : elem + ':Cannot be blank;';
    }
}