/*
 * Controller class of VF pages related to MDF request
 */
public class PartnerPortalRequestMDFController
{
    public PartnerPortalRequestMDFController()
    {
        User currentUser = [select Id, ContactId from User where Id=:UserInfo.getUserId() limit 1];
        List<Contact> contacts = [select Id, Name, Email, Phone, AccountId, Account.Name, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry from Contact where Id=:currentUser.ContactId limit 1];
        currentContact = (contacts.size() > 0) ? contacts[0] : new Contact();
        Id currentAccountId = (contacts.size() > 0) ? contacts[0].AccountId : null;
        
        String requestId = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(requestId))
        {
            List<MDF_Request__c> requests = [select Id, Name, Purchasing_Request__c, Type_of_Program__c, Event_Campaign_Name__c, Location_of_Event__c, Activity_Date__c, Target_Audience_Profile__c, Industry_Vertical_Being_Targeted__c, Expected_Audience_Size__c, Expected_Number_of_Leads__c, Est_Value_of_Expected_Opportunities__c, 
                                            Addl_Vendor_1__c, Addl_Vendor_2__c, Addl_Vendor_3__c, Total_Estimated_Program_Costs__c, Estimated_Partner_Amount__c, Estimated_Silver_Peak_Amount__c, Estimated_Other_Vendor_s_Amount__c, post_event_follow_up_plan__c, Comments__c, Submitted_For__c, Submitter__r.AccountId,
                                            Marketing_Activity_Point_of_Contact_Nam__c, Marketing_Activity_PoC_Email__c, Accounting_PoC_Name__c, Accounting_PoC_Email__c, Remit_Address_1__c, Remit_Address_2__c, Remit_City__c, Remit_State__c, Remit_Zip_Postal_Code__c, Remit_Country__c, CreatedDate, CreatedbyId,
                                            Approval_Date__c, Approval_Status__c, Invoice_No__c, PO_No__c, Quarterly_Marketing_Plan__c, Fast_Start_Marketing_Program__c, Partner_at_Platinum_Level__c, Exception_Granted_Reason__c, Reason_Rejected__c, Activity_Complete__c, Result_Detail__c, 
                                            Total_Attendees__c, Total_Leads_Generated__c, Total_Qualified_Leads__c, Estimated_Pipeline_Value__c, Actual_Program_Cost__c, Actual_Partner_Cost__c, Requested_Reimbursement_Amount__c, Additional_Vendor_Cost_1__c, Additional_Vendor_Cost_2__c 
                                            from MDF_Request__c where Name=:requestId limit 1];
            request = (requests.size() > 0) ? requests[0] : new MDF_Request__c(Account__c=currentAccountId);
            initAttachments(request.Id);
        } 
        else
        {
            request = new MDF_Request__c(Account__c=currentAccountId);
            filterField = 'Activity_Date__c';
            filterValue = 'THIS_QUARTER';
            sortField = 'Activity_Date__c';
            search();
            initAttachments(null);
        }
    }
    
    public Contact currentContact { get; set; }
    public MDF_Request__c request { get; set; }
    public Attachment invoiceAttachment { get; set; }
    public Attachment proofAttachment { get; set; }
    public Attachment attlistAttachment { get; set; }
    public Attachment sampleAtachment { get; set; }
    public Attachment eventAttachment { get; set; }
    public Attachment addlAttachment1 { get; set; }
    public Attachment addlAttachment2 { get; set; }
    public Attachment addlAttachment3 { get; set; }
    
    public String keyword { get; set; }
    public String filterField { get; set; }
    public String filterValue { get; set; }
    public String sortField { get; set; }
    public List<MDF_Request__c> requests { get; private set; }
    
    public Boolean isInitial { get { return String.isBlank(request.Approval_Status__c) || request.Approval_Status__c == 'Unsubmitted'; }}
    public Boolean isSubmitted { get { return request.Approval_Status__c == 'Pending'; } }
    public Boolean isDenied { get { return request.Approval_Status__c == 'Denied'; } }
    public Boolean isApproved { get { return request.Approval_Status__c == 'Approved'; }}
    
    public PageReference authorize() 
    {
        User currentUser = [select Id, ContactId from User where Id=:UserInfo.getUserId() limit 1];
        List<Contact> contacts = [select Id, Name, Email, Phone, AccountId, Account.Name, Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry from Contact where Id=:currentUser.ContactId limit 1];
        currentContact = (contacts.size() > 0) ? contacts[0] : new Contact();
        
        if(request.Id != null && request.Submitter__r.AccountId != currentContact.AccountId && request.CreatedById != UserInfo.getUserId())
        {
            request = new MDF_Request__c();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'MDF does not exist or you are not authorized to view this record.'));
        }
        else
        {
            Database.insert(new MDF_Request__Share(ParentId=request.Id, UserOrGroupId=UserInfo.getUserId(), AccessLevel='Edit'), false);
        }
        return null;
    }
    
    public PageReference search()
    {
        try
        {
            if(String.isNotBlank(keyword) && keyword.length() >= 2)
            {
                String sosl = 'find :keyword returning MDF_Request__c(Id, Name, Type_of_Program__c, Activity_Complete__c, Approval_Status__c, Invoice_No__c, PO_No__c, Estimated_Silver_Peak_Amount__c, Activity_Date__c, Event_Campaign_Name__c where (Submitter__r.AccountId=\''+currentContact.AccountId+'\' or CreatedById=\''+UserInfo.getUserId()+'\') and ' + filterField +'=' + filterValue + ' order by ' + sortField + ' limit 1000)';
                requests = Search.query(sosl)[0];
            }
            else
            {
                String soql = 'select Id, Name, Type_of_Program__c, Activity_Complete__c, Approval_Status__c, Invoice_No__c, PO_No__c, Estimated_Silver_Peak_Amount__c, Activity_Date__c, Event_Campaign_Name__c from MDF_Request__c where (Submitter__r.AccountId=\''+currentContact.AccountId+'\' or CreatedById=\''+UserInfo.getUserId()+'\') and ';
                soql += filterField +'=' + filterValue;
                soql += ' order by ' + sortField;
                soql += ' limit 1000';
                requests = Database.query(soql);
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error occured while searching. Please retry.'));
        }
        return null;
    }
    
    public PageReference deleteAttachment()
    {
        String fileId = ApexPages.currentPage().getParameters().get('file');
        if(String.isNotBlank(fileId) && fileId instanceOf Id && fileId.startsWith('00P'))
        {
            try
            {
                delete new Attachment(Id=fileId);
                initAttachments(request.Id);
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    public PageReference save()
    {
        Boolean isSucceeded = true;
        SavePoint sp = Database.setSavePoint();
        try
        {
            saveRequestAndAttachments();
        }
        catch(Exception ex)
        {
            isSucceeded = false;
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
        
        //Send Email Notification when MDF is updated or attachments are uploaded.
        if(isApproved || isSubmitted)
        {
            isSucceeded = sendEmailNotification();
        }
        
        if(isSucceeded) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'MDF Request is saved. '));
        }
        return null;
    }
    
    public PageReference submit()
    {
        SavePoint sp = Database.setSavePoint();
        if(request.Id == null || request.Purchasing_Request__c == null)
        {
            try
            {
                saveRequestAndAttachments();
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                ApexPages.addMessages(ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getStackTraceString()));
                return null;
            }
        }
        
        try
        {
            updateCSM();
            Approval.ProcessSubmitRequest process = new Approval.ProcessSubmitRequest();
            process.setComments('Client submission');
            process.setObjectId(request.Id);
            Approval.ProcessResult result = Approval.process(process);
            if(result.getInstanceStatus() == 'Pending')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'MDF Request is submitted.'));
                return Page.PartnerPortalManageMDF;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, result.getInstanceStatus()));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to submit this request.'));
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    private void saveRequestAndAttachments()
    {
        if(request.Purchasing_Request__c == null)
        {
            List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType='Purchasing_Request__c' and Name='MDF Request' limit 1];
            Purchasing_Request__c purchase = new Purchasing_Request__c();
            purchase.RecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
            insert purchase;
            request.Purchasing_Request__c = purchase.Id;
        }
        upsert request;
        
        List<Attachment> attachments = new List<Attachment>();
        addAttachmentToList(invoiceAttachment, request.Id, attachments);
        addAttachmentToList(proofAttachment, request.Id, attachments);
        addAttachmentToList(attlistAttachment, request.Id, attachments);
        addAttachmentToList(sampleAtachment, request.Id, attachments);
        addAttachmentToList(eventAttachment, request.Id, attachments);
        addAttachmentToList(addlAttachment1, request.Id, attachments);
        addAttachmentToList(addlAttachment2, request.Id, attachments);
        addAttachmentToList(addlAttachment3, request.Id, attachments);
        if(attachments.size() > 0)
        {
            upsert attachments;
            initAttachments(request.Id);
        }
    }

    //Constant for sending email notification.
    static final String EMAIL_TEMPLATE_NAME = 'MDF_Update_Email';
    static final String ORG_WIDE_EMAILL_ADDRESS_NAME = 'Silver Peak Notifications';
    static final String TO_ADDRESS = 'marketingrequest@silver-peak.com';
    static final List<String> CC_ADDRESSES = new List<String> { 'amenjivar@silver-peak.com', 'sstrachman@silver-peak.com' };

    private Boolean sendEmailNotification()
    {
        Boolean isSucceeded = true;
        List<EmailTemplate> emailTemplates = [select Id from EmailTemplate where DeveloperName = :EMAIL_TEMPLATE_NAME];
        List<OrgWideEmailAddress> orgWideEmailAddresses = [select Id from OrgWideEmailAddress where DisplayName = :ORG_WIDE_EMAILL_ADDRESS_NAME];
        if(emailTemplates.size() > 0 && orgWideEmailAddresses.size() > 0) {
            Contact tempContact = new Contact(FirstName = 'Test', LastName = 'Contact', Email = TO_ADDRESS);
            insert tempContact; //For sending email.

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setOrgWideEmailAddressId(orgWideEmailAddresses[0].Id);
            mail.setTemplateId(emailTemplates[0].Id);
            mail.setCcAddresses(CC_ADDRESSES);
            mail.setWhatId(request.Id);
            mail.setTargetObjectId(tempContact.Id);
            mail.setSaveAsActivity(false);
            try
            {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
                isSucceeded = false;
            }
            delete tempContact;
        }
        return isSucceeded;
    }
    
    private void updateCSM()
    {
        List<Account> currentAccount = [select Id, OwnerId, Owner.GEO_Region__c, Patch__c, Patch__r.CSM__c, Patch__r.CSM__r.GEO_Region__c, Patch__r.RSM__c, Patch__r.RSM__r.GEO_Region__c from Account where Id=:currentContact.AccountId limit 1];
        if(currentAccount.size() > 0)
        {
            request.CSM__c = currentAccount[0].Patch__r.CSM__c;
            request.RSM__c = currentAccount[0].Patch__r.RSM__c;
            request.GEO__c = currentAccount[0].Patch__r.CSM__r.GEO_Region__c;
            if(request.CSM__c == null)
            {
                request.CSM__c = currentAccount[0].OwnerId;
            }
            if(request.RSM__c == null)
            {
                request.RSM__c = currentAccount[0].OwnerId;
            }
            if(String.isBlank(request.GEO__c))
            {
                request.GEO__c = currentAccount[0].Owner.GEO_Region__c;
            }
            if(String.isNotBlank(request.GEO__c))
            {
                String geo = request.GEO__c;
                String[] parts = geo.split('-');
                if(parts.size() >= 1)
                {
                    request.GEO__c = parts[0];
                }
            }
        }
        request.Submitter__c = currentContact.Id;
        upsert request;
        
    }
    
    private void addAttachmentToList(Attachment att, Id parentId, List<Attachment> atts)
    {
        if(att != null && att.ParentId == null)
        {
            att.ParentId = parentId;
        }
        if(att != null  && att.Id == null && att.Body != null)
        {
            atts.add(att.clone(false, false, false, false));
            att.Body = null;
        }
    }
    
    private void initAttachments(Id parentId)
    {
        invoiceAttachment = new Attachment(Name='Invoice and Receipt');
        proofAttachment = new Attachment(Name='Proof of Performance');
        attlistAttachment = new Attachment(Name='Attendance List');
        sampleAtachment = new Attachment(Name='Sample Ad');
        eventAttachment = new Attachment(Name='Event Photos');
        addlAttachment1 = new Attachment(Name='Addl1');
        addlAttachment2 = new Attachment(Name='Addl2');
        addlAttachment3 = new Attachment(Name='Addl3');
        if(parentId != null)
        {
            for(Attachment att : [select Id, Body, Name, ParentId from Attachment where ParentId=:parentId])
            {
                if(att.Name == 'Invoice and Receipt')
                {
                    invoiceAttachment = att;
                }
                else if(att.Name == 'Proof of Performance')
                {
                    proofAttachment = att;
                }
                else if(att.Name == 'Attendance List')
                {
                    attlistAttachment = att;
                }
                else if(att.Name == 'Sample Ad')
                {
                    sampleAtachment = att;
                }
                else if(att.Name == 'Event Photos')
                {
                    eventAttachment = att;
                }
                else
                {
                    if(addlAttachment1.Id == null)
                    {
                        addlAttachment1 = att;
                    }
                    else if(addlAttachment2.Id == null)
                    {
                        addlAttachment2 = att;
                    }
                    else if(addlAttachment3.Id == null)
                    {
                        addlAttachment3 = att;
                    }
                }
            }
        }
    }
    
}