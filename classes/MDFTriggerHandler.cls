public class MDFTriggerHandler implements ITriggerHandler{
    private string MDFRecordTypeId=null;
    private string OtherRecordTypeId =null;
    Map<Id, Account> moreAccounts=null;
    Map<Id, Contact> moreContacts=null;
    Account loggedInUserAccount=null;
    Contact loggedInUserContact=null;
    public MDFTriggerHandler()
    {
        if(SilverPeakutils.IsProduction())
        {
            MDFRecordTypeId= '012500000005btC';
            OtherRecordTypeId= '01238000000EBSY';
        }
        else
        {
            List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType = 'Purchasing_Request__c' and Name = 'MDF Request' limit 1];
            MDFRecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
            List<RecordType> otherMDFRecordType = [select Id from RecordType where SobjectType = 'MDF_Request__c' and Name = 'Others' limit 1];
            OtherRecordTypeId = (otherMDFRecordType.size() > 0) ? otherMDFRecordType[0].Id : null;         
        }
        
    }
    public Boolean IsDisabled()
    {
         if (Trigger_Settings__c.getvalues('AllTriggers')!=null && Trigger_Settings__c.getvalues('AllTriggers').Disabled__c==true)
            return true;
        else
            return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        
        List<Purchasing_Request__c> purchaseRequests = new List<Purchasing_Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            User currentUser = [select Id, ContactId from User where Id = :UserInfo.getUserId() limit 1];
            List<Contact> contacts = [select Id, AccountId, Account.OwnerId, Account.Owner.GEO_Region__c, Account.Patch__c, Account.Patch__r.CSM__c, Account.Patch__r.CSM__r.GEO_Region__c, Account.Patch__r.Owner__r.GEO_Region__c, Account.Patch__r.RSM__c, Account.Patch__r.RSM__r.GEO_Region__c from Contact where Id = :currentUser.ContactId limit 1];
            loggedInUserAccount = (contacts.size() > 0) ? contacts[0].Account : null;
            loggedInUserContact = (contacts.size() > 0) ? contacts[0] : null;
            moreAccounts = getAccounts(newItems);
            moreContacts = getContacts(newItems);
            List<MDF_Request__c> lstMDF=( List<MDF_Request__c> )newItems;
            for(MDF_Request__c mdfReq:lstMDF)
            {
                if(mdfReq.RecordTypeId != OtherRecordTypeId)
                {   
                    Purchasing_Request__c purchaseRequest = new Purchasing_Request__c(RecordTypeId = MDFRecordTypeId);
                    purchaseRequests.add(purchaseRequest);
                    if(mdfReq.Account__c == null)
                    {
                        //MDF created by portal user
                        UpdateAcctGEO(mdfReq,loggedInUserContact,loggedInUserAccount);
                    }
                    else
                    {
                        //MDF created by internal user
                        Account acc = moreAccounts.get(mdfReq.Account__c);
                        Contact ct = moreContacts.get(mdfReq.Contact__c);
                        UpdateAcctGEO(mdfReq,ct,acc);
                    }
                }
            }
            insert purchaseRequests;
            if(purchaseRequests != null && purchaseRequests.size()>0)
            {
                AssociateMDFWithPurchaseRequest(newItems,purchaseRequests);
            }
        }        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for(Id mdfId:newItems.keyset())
            {
                MDF_Request__c newMDF = (MDF_Request__c)newItems.get(mdfId);
                MDF_Request__c oldMDF = (MDF_Request__c)oldItems.get(mdfId);
                if(isApproval(newMDF.Approval_Status_Hidden__c) && !isApproval(oldMDF.Approval_Status_Hidden__c))
                {
                    if(newMDF.Purchasing_Request__c!=null && newMDF.Purchasing_Request_First_Approver__c == null)
                    {
                        newMDF.addError('You cannot approve this MDF before the budget owner is set up on the related Purchase Request.');
                        
                    }
                    if(newMDF.Purchasing_Request__c!=null && newMDF.Purchasing_Request_Line_Added__c==0)
                    {
                        newMDF.addError('You cannot approve this MDF before any PR line is entered on the related Purchase Request.');
                    }
                }
            }
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
        if(oldItems.size()>0)
        {
            for(Id assetId:oldItems.keySet())
            {
                
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        List<MDF_Request__c>lstRequests= new List<MDF_Request__c>();
        Set<Id> accountIds = new Set<Id>();
        List<MDF_Request__c> lstMDF= new List<MDF_Request__c>();
        List<MDF_Request__c> lstCSMShare= new List<MDF_Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id mdfId : newItems.keyset())
            {
                MDF_Request__c mdf= (MDF_Request__c)newItems.get(mdfId);
                if(mdf.RecordTypeId != OtherRecordTypeId)
                {
                    accountIds.add(mdf.Account__c);
                    
                    if(mdf.Is_Portal_Request__c)
                        lstRequests.add(mdf);
                    if(mdf.Account__c!=null)
                    {
                        lstMDF.add(mdf);
                    }
                }
                if(mdf.CSM__c!=null || mdf.OwnerId!=null || mdf.RSM__c!=null)
                {
                    lstCSMShare.add(mdf);
                }
                
            }
            if(!SilverPeakUtils.BypassingTriggers)
            {
                AutoSubmitMDFRequest(lstRequests);
            }
            UpdatePurchasingRequest(Trigger.NewMap.values());
            ShareMDFToPartner(lstMDF);
            CopyMdfToAccount(accountIds);
            ShareMDFToCSM(lstCSMShare);
        }
    }
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        System.debug('After Update');
        Set<Id> accountIds = new Set<Id>();
        List<MDF_Request__c> lstMDF= new List<MDF_Request__c>();
        Set<Id> setCampMdfIds = new Set<Id>();
        List<MDF_Request__c> lstEmailMDF= new List<MDF_Request__c>();
        List<MDF_Request__c> lstMDFPRApproval= new List<MDF_Request__c>();
        List<MDF_Request__c> lstCSMShare= new List<MDF_Request__c>();
        if(newItems!=null && newItems.size()>0)
        {
            boolean isBatchUpdate= newItems.size()>1;
            for (Id mdfId : newItems.keyset())
            {
                MDF_Request__c newMDF= (MDF_Request__c)newItems.get(mdfId);
                MDF_Request__c oldMDF= (MDF_Request__c)oldItems.get(mdfId);
                
                if(newMDF.Approval_Status__c == 'Approved' && oldMdf.Approval_Status__c != 'Approved' || oldMdf.Account__c != newMDF.Account__c)
                {
                    if(newMDF.Account__c!=null)
                        accountIds.add(newMDF.Account__c);
                }
                if(newMDF.Approval_Status__c == 'Approved' && newMDF.SendReminder__c == true && newMDf.MDF_Status__c == 'Past Due' && oldMDF.SendReminder__c==false)
                {
                    lstEmailMDF.add(newMDF);
                }
                if(newMDF.Approval_Status__c == 'Approved'&& oldMDF.Approval_Status__c != 'Approved' && newMDF.Campaign__c == null)
                {
                    setCampMdfIds.add(newMDF.Id);
                }
                if((newMDF.Account__c!=oldMDF.Account__c || newMDF.OwnerId!=oldMdf.OwnerId) && newMDF.RecordTypeId != OtherRecordTypeId)
                {
                    lstMDF.add(newMDF);
                }
                if(newMDF.Approval_Status_Hidden__c == 'Approved' && oldMDF.Approval_Status_Hidden__c != 'Approved')
                {
                    lstMDFPRApproval.add(newMDF);
                }
                if(newMDF.CSM__c!=oldMDF.CSM__c|| newMDF.OwnerId!=oldMDF.OwnerId || newMDF.RSM__c!=oldMDF.RSM__c)
                {
                    lstCSMShare.add(newMDF);
                }
            }
            
            CreateCampaignForMDF(setCampMdfIds);
            ShareMDFToPartner(lstMDF);
            ShareMDFToCSM(lstCSMShare);
            CopyMdfToAccount(accountIds);
            SubmitPR(lstMDFPRApproval);
            EmailMDF(lstEmailMDF);
            
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
        for(Id assetId : oldItems.keySet())
        {
            
        }
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null)
        {
            for(Id assetId : newItems.keySet())
            {
            }
        }
        
    }
    
    private void AssociateMDFWithPurchaseRequest(List<MDF_Request__c> lstMDF, List<Purchasing_Request__c> lstPR)
    {
        MDF_Request__c request;
        for(Integer i = 0; i < lstMDF.size(); i++)
        {
            request = lstMDF[i];
            if(request.Purchasing_Request__c == null)
            {
                request.Purchasing_Request__c = lstPR[i].Id;
            }
            
        }
    }
    private Map<Id, Account> getAccounts(List<MDF_Request__c> mdfs)
    {
        Set<Id> accIds = new Set<Id>();
        for(MDF_Request__c mdf : mdfs)
        {
            accIds.add(mdf.Account__c);
        }
        return new Map<Id, Account>([select Id, OwnerId, Owner.GEO_Region__c, Patch__c, Patch__r.CSM__c, Patch__r.CSM__r.GEO_Region__c, Patch__r.Owner__c, Patch__r.Owner__r.GEO_Region__c, Patch__r.RSM__c, Patch__r.RSM__r.GEO_Region__c from Account where Id in :accIds]);
    }
    
    private Map<Id, Contact> getContacts(List<MDF_Request__c> mdfs)
    {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> result = new Map<Id, Contact>();
        for(MDF_Request__c mdf : mdfs)
        {
            if(mdf.Contact__c != null)
            {
                result.put(mdf.Contact__c, new Contact(Id=mdf.Contact__c));
            }
        }
        return result;
    }
    private void UpdateAcctGEO(MDF_Request__c req,Contact ct,Account acc)
    {
        if(acc != null)
        {
            req.Account__c = acc.Id;
            req.CSM__c = acc.Patch__r.CSM__c;
            req.RSM__c = acc.Patch__r.RSM__c;
            //setting GEO to that of patch owner instead of CAM
            req.GEO__c = acc.Patch__r.Owner__r.GEO_Region__c;
            if(String.isBlank(req.GEO__c))
            {
                req.GEO__c = acc.Owner.GEO_Region__c;
            }
            if(String.isNotBlank(req.GEO__c))
            {
                String geo = req.GEO__c;
                String[] parts = geo.split('-');
                if(parts.size() >= 1)
                {
                    req.GEO__c = parts[0];
                }
            }
        }
        if(ct != null)
        {
            req.Submitter__c = ct.Id;
        }
    }
    private void UpdatePurchasingRequest(List<MDF_Request__c> lstMDFReq)
    {
        if(lstMDFReq!=null && lstMDFReq.size()>0)
        {
            List<MDF_Request__c> mdfs = [select Id, Purchasing_Request__c, Account__c, Account__r.Name, OwnerId, Owner.Name, Owner.Email, Company_Billing_Address__c, Remit_to_Address__c from MDF_Request__c where Id in :lstMDFReq and RecordTypeId != :OtherRecordTypeId];
            List<Purchasing_Request__c> requests = new List<Purchasing_Request__c>();
            for(MDF_Request__c mdf : mdfs)
            {
                Purchasing_Request__c request = new Purchasing_Request__c(Id=mdf.Purchasing_Request__c);
                request.Vendor_Name__c = mdf.Account__r.Name;
                request.Vendor_Contact__c = mdf.Owner.Name;
                request.Vendor_Email__c = mdf.Owner.Email;
                request.Vendor_Address__c = isBlankAddress(mdf.Remit_to_Address__c) ? mdf.Company_Billing_Address__c : mdf.Remit_to_Address__c;
                requests.add(request);
            }
            Database.update(requests, false);
        }
    }
    private Boolean isApproval(String text)
    {
        return String.isNotBlank(text) && (text.toLowerCase().contains('approved') || text.toLowerCase().contains('approval'));
    }
    private void AutoSubmitMDFRequest(List<MDF_Request__c> lstRequests)
    {
        if(lstRequests != null && lstRequests.size()>0)
        {
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for(MDF_Request__c item : lstRequests)
            {
                Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
                submitReq.setComments('Submitting request for approval.');
                submitReq.setObjectId(item.Id);
                //submitReq.setSubmitterId(UserInfo.getUserId());
                //submitReq.setProcessDefinitionNameOrId('New_MDF_Request');
                //submitReq.setSkipEntryCriteria(true);
                requests.add(submitReq);
            }
            try
            {
                List<Approval.ProcessResult> results = Approval.process(requests, false);
            }
            catch(Exception ex)
            {
                System.debug('An exception was thrown: ' + ex);
            }
        }
    }
    
    private void CopyMdfToAccount(Set<Id> accountIds)
    {
        List<Account> updatingAccounts = new List<Account>();
        if(accountIds.size() > 0)
        {
            List<AggregateResult> allMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds group by Account__c];
            List<AggregateResult> approvedMdfs = [select sum(Estimated_Silver_Peak_Amount__c) c, Account__c a from MDF_Request__c where Account__c in :accountIds and Approval_Status__c='Approved' group by Account__c];
            
            for(Id accId : accountIds)
            {
                updatingAccounts.add(new Account(Id=accId, Total_Requested_MDF__c=0, Total_Approved_MDF__c=0));
            }
            for(AggregateResult r :  allMdfs)
            {
                Id accId = (Id)r.get('a');
                Decimal amount = (Decimal)r.get('c');
                for(Account acc : updatingAccounts)
                {
                    if(acc.Id == accId)
                    {
                        acc.Total_Requested_MDF__c = amount;
                        break;
                    }
                }
            }
            for(AggregateResult r :  approvedMdfs)
            {
                Id accId = (Id)r.get('a');
                Decimal amount = (Decimal)r.get('c');
                for(Account acc : updatingAccounts)
                {
                    if(acc.Id == accId)
                    {
                        acc.Total_Approved_MDF__c = amount;
                        break;
                    }
                }
            }
        }
        if(updatingAccounts.size() > 0)
        {
            Database.update(updatingAccounts, false);
        }
    }
    
    private void ShareMDFToPartner(List<MDF_Request__c> needToShareMDFs)
    {
        if(needToShareMDFs!=null && needToShareMDFs.size() > 0)
        {
            ShareMDFToPartnerHelper.shareMDFs(needToShareMDFs);
        }
    }
    
    private void SubmitPR(List<MDF_Request__c> lstMDF)
    {
        if(lstMDF!=null && lstMDF.size()>0)
        {
            for(MDF_Request__c mdf:lstMDF)
            {
                if(mdf.Purchasing_Request__c != null)
                {
                    try
                    {
                        List<ProcessInstanceStep> mdfApprovalHistory = [select Id, ActorId from ProcessInstanceStep where ProcessInstance.TargetObjectId=:mdf.Id and StepStatus='Approved' order by CreatedDate limit 1];
                        List<ProcessInstance> prApproval = [select Id from ProcessInstance where TargetObjectId=:mdf.Purchasing_Request__c and Status in ('Started', 'Pending', 'Approved') limit 1];
                        if((mdfApprovalHistory.size() > 0 && prApproval.size() == 0) || Test.isRunningTest())
                        {
                            Approval.ProcessSubmitRequest process = new Approval.ProcessSubmitRequest();
                            process.setComments('Submit upon MDF approval.');
                            process.setObjectId(mdf.Purchasing_Request__c);
                            //just for testing
                            String submiter = Test.isRunningTest() ? UserInfo.getUserId() : mdfApprovalHistory[0].ActorId;
                            process.setSubmitterId(submiter);
                            Approval.ProcessResult result = Approval.process(process);
                            if(result.getInstanceStatus() != 'Pending')
                            {
                                mdf.addError('Failed to submit. The status is ' + result.getInstanceStatus());
                                SilverPeakUtils.logException('Failed to submit Purchase Request. [Id=' + mdf.Purchasing_Request__c + ']');
                            }
                        }
                    }
                    catch(Exception ex)
                    {
                        mdf.addError(ex.getMessage());
                        SilverPeakUtils.logException(ex);
                    }
                }
                else
                {
                    SilverPeakUtils.logException('MDF is approved, but it does not have a related PR to submit. [Id=' + mdf.Id + ']');
                }
            }
        }
        
    }
    
    private void ShareMDFToCSM(List<MDF_Request__c> needToShareMDFs)
    {
        List<MDF_Request__Share> lstMDFShare= new List<MDF_Request__Share>();
        if(needToShareMDFs.size()>0 && needToShareMDFs != null)
        {
            for(MDF_Request__c mdf:needToShareMDFs)
            {
                MDF_Request__Share mdfShare = new MDF_Request__Share(ParentId = mdf.Id, UserOrGroupId = mdf.CSM__c, AccessLevel = 'Edit');
                lstMDFShare.add(mdfShare);
            }
            Database.Insert(lstMDFShare,false);
        }
    }
    
    
    
    
    private Boolean isBlankAddress(String address)
    {
        if(String.isBlank(address))
        {
            return true;
        }
        return String.isBlank(address.replaceAll('[,\\s\\r\\n]', ''));
    }
    private void CreateCampaignForMDF(Set<Id> setMDFIds)
    {
        if(!setMDFIds.isEmpty())
        {
            List<MDF_Request__c> mdfs = [Select Id, Campaign__c, Activity_Date__c, Event_Campaign_Name__c, Event_Location_City__c, Type_of_Program__c, GEO__c, Account__r.Name  from MDF_Request__c where Id in: setMDFIds];
            Map<MDF_Request__c,Campaign> mdfAndCampaign = new Map<MDF_Request__c, Campaign>();
            for(MDF_Request__c mdf : mdfs)
            {
                MDFAndCampaign.put(mdf, new Campaign(Name = getCampaignName(mdf)));
            }
            try
            {
                insert mdfAndCampaign.values();
                for(MDF_Request__c mdf : mdfAndCampaign.keySet())
                {
                    mdf.Campaign__c = mdfAndCampaign.get(mdf).Id;
                }
                upsert new List<MDF_Request__c>(MDFAndCampaign.keySet());
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex);
            }
        }
    }
    private void EmailMDF(List<MDF_Request__c> lstMDfReq)
    {
        if(!lstMDfReq.isEmpty())
        {
            List<MDF_Request__c> mdfs = [Select Id, Name, Owner.Name,Owner.FirstName, Owner.Email, Owner.Profile.Name, Contact__c, Contact__r.Name,Contact__r.FirstName, Contact__r.Email from MDF_Request__c where Id in: lstMDfReq];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> et = [Select Id, Name, Body, HtmlValue,Subject from EmailTemplate where DeveloperName like '%New_MDF_Approved_Post_Event%' limit 1];
            List<OrgWideEmailAddress> orgWideEmail = [Select Id from OrgWideEmailAddress where DisplayName = 'Silver Peak Channel Team' LIMIT 1];
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for(Attachment attach : [select Id, Name, Body from Attachment where parentId = :et[0].Id])
            {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(attach.Name);
                efa.setBody(attach.Body);
                fileAttachments.add(efa);
            }
            
            if(!et.isEmpty())
            {
                String url;
                for(MDF_Request__c mdf : mdfs )
                {
                    url = SendMdfUrlToClientController.encryptParameter(mdf.Id);
                    String recipient = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Email;
                    mail.setToAddresses(new String[] {recipient});
                    //mail.setSenderDisplayName('The Silver Peak Team');
                    mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
                    mail.setSubject(mergeEmail(et[0].Subject, mdf, url));
                    mail.setPlainTextBody(mergeEmail(et[0].Body, mdf, url));
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    
                    if(!fileAttachments.IsEmpty())
                    {
                        mail.setFileAttachments(fileAttachments);
                    }
                    mails.add(mail);
                }
                Messaging.sendEmail(mails);
            }
        }
    }
    
    private String mergeEmail(String originalValue, MDF_Request__c mdf, String encryptedLink)
    {
        String recipientName = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.FirstName : mdf.Contact__r.FirstName;
        return originalValue.replace('{!MDF_Request__c.Owner.Name}', recipientName).replace('{!MDF_Request__c.OwnerFirstName}', recipientName).replace('{!MDF_Request__c.Link}','https://partners.silver-peak.com/s/MarketingFundsAnonymous?id=' + encryptedLink).replace('{!MDF_Request__c.Name}', mdf.Name);
    }
    
    private String getCampaignName(MDF_Request__c mdf)
    {
        if(mdf != null)
        {
            String fyfq = getQuarter(mdf.Activity_Date__c);
            String geo = mdf.GEO__c == 'NAM' ? 'AMER' : mdf.GEO__c;
            String activityDate = (mdf.Activity_Date__c == null) ? '' : ((mdf.Activity_Date__c.month() < 10 ? '0' + mdf.Activity_Date__c.month() : '' + mdf.Activity_Date__c.month()) + '' + (mdf.Activity_Date__c.day() < 10 ? '0' + mdf.Activity_Date__c.day() : '' + mdf.Activity_Date__c.day()) + '' + (String.valueOf(mdf.Activity_Date__c.year()).right(2)));
                String campaignName = truncateString(fyfq, 6) + '_' + truncateString(activityDate, 6) + '_' + truncateString(geo, 5) + '_' + truncateString(mdf.Type_Of_Program__c, 15) + '_' + truncateString(mdf.Event_Campaign_Name__c, 15) + '_' + truncateString(mdf.Account__r.Name, 15) + '_' + truncateString(mdf.Event_Location_City__c, 12);
            return campaignName.length() > 80 ? campaignName.substring(0, 80) : campaignName;
        }
        else
        {
            return null;
        }
    }
    
    private String truncateString(String value, Integer length)
    {
        if(value == null)
        {
            value = '';
        }
        if(value.length() > length)
        {
            value = value.replaceAll(' ', '');
            if(value.length() > length)
            {
                value = value.substring(0, length);
            }
        }
        return value;
    }
    
    private String getQuarter(Date d)
    {
        if(d != null)
        {
            Integer month = d.month();
            String FY = 'FY' + String.valueOf((month >= 8) ? d.year() + 1 : d.year()).subString(2,4);
            String FQ = 'Q' + (Integer)Math.ceil((month >= 8 ? month -7 : month + 5) /3.0);
            return FY + FQ;
        }
        else
        {
            return '';
        }
    }
}