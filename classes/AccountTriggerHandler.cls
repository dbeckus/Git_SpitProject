public class AccountTriggerHandler implements ITriggerHandler {
    List<Id> accNeedsPatchAssign = new List<Id>();
    List<Id> accNeedsTeamAssign  = new List<Id>();
    List<String> directorEmails = new List<String>();
    Map<Id, String> user2TREmail = new Map<Id, String>();
    public AccountTriggerHandler()
    {
        
    }
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for (Id accId : newItems.keyset())
            {
                Account newAccInfo= (Account)newItems.get(accId);
                Account oldAccInfo= (Account)oldItems.get(accId);
                if(!newAccInfo.Override_Service_Provider_Setting__c)
                {
                    if((oldAccInfo.ECSP__c!=newAccInfo.ECSP__c) || (oldAccInfo.Service_Provider_Account_Type__c !=newAccInfo.Service_Provider_Account_Type__c ||oldAccInfo.Service_Provider_Location__c!=newAccInfo.Service_Provider_Location__c || oldAccInfo.Service_Provider_Domain__c!=newAccInfo.Service_Provider_Domain__c||oldAccInfo.Service_Provider_Admin_User__c!=newAccInfo.Service_Provider_Admin_User__c))
                    {
                        if(newAccInfo.Cloud_Portal_Account_Id__c!=null || newAccInfo.Cloud_Portal_Account_Key__c!=null || newAccInfo.Cloud_Portal_Account_Name__c !=null || newAccInfo.Service_Provider_Contracted__c )
                        {
                            newAccInfo.addError('You cannot modify any fields in the service provider information section. Please contact service provider team.');
                        }
                        else
                        {
                            List<Asset> lstAssets=[Select Id from Asset where AccountId=:newAccInfo.Id and Status in ('Customer Evaluation','Customer Subscription Active')];
                            List<Request__c> lstPOCs =[Select Id from Request__c where Opportunity__r.AccountId=:newAccInfo.Id];
                            if((lstAssets!=null && lstAssets.size()>0) || (lstPOCs!=null && lstPOCs.size()>0) )
                            {
                                newAccInfo.addError('You cannot modify any fields in the service provider information section. Please contact service provider team.');
                            }
                            
                        }
                    }
                }
                if(!newAccInfo.Override_Service_Provider_Setting__c)
                {
                    if(!newAccInfo.ECSP__c && (oldAccInfo.Unity_Orch_Admin_User__c!=newAccInfo.Unity_Orch_Admin_User__c || oldAccInfo.Unity_Orch_Domain__c !=newAccInfo.Unity_Orch_Domain__c ||oldAccInfo.Unity_Orch_Location__c!=newAccInfo.Unity_Orch_Location__c))
                    {
                        if(newAccInfo.Cloud_Portal_Account_Id__c!=null || newAccInfo.Cloud_Portal_Account_Key__c!=null || newAccInfo.Cloud_Portal_Account_Name__c !=null)
                        {
                            newAccInfo.addError('You cannot modify any fields in the unity cloud orchestrator section. Please contact operations team.');
                        }
                        else
                        {
                            List<Asset> lstAssets=[Select Id from Asset where AccountId=:newAccInfo.Id and Status in ('Customer Evaluation','Customer Subscription Active') and Product2.Name like 'EC-ORCH-AAS%'];
                            List<Request__c> lstPOCs =[Select Id from Request__c where Opportunity__r.AccountId=:newAccInfo.Id and Is_Unity_Cloud_Orchestrator__c=true];
                            if((lstAssets!=null && lstAssets.size()>0) || (lstPOCs!=null && lstPOCs.size()>0) )
                            {
                                newAccInfo.addError('You cannot modify any fields in the unity cloud orchestrator section. Please contact operations team.');
                            }
                        }
                    }
                }
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        boolean isSynced=false;
        if(oldItems.size()>0)
        {
            for(Id accId:oldItems.keySet())
            {
                Account oldAccinfo= (Account)oldItems.get(accId);
                if(oldAccinfo.Cloud_Portal_Account_Id__c!=null ||oldAccinfo.Cloud_Portal_Account_Key__c!=null||oldAccinfo.Cloud_Portal_Account_Name__c!=null || oldAccinfo.Sync_with_Cloud_Portal__c )
                {
                    isSynced=true;
                }
                
                if(!isSynced && (oldAccinfo.Cloud_Portal_Account_Id__c==null ||oldAccinfo.Cloud_Portal_Account_Key__c==null||oldAccinfo.Cloud_Portal_Account_Name__c==null))
                {
                    List<Asset> lstAssets= [Select Id from Asset where AccountId=:oldAccinfo.Id and (Product2.Name like 'EC%' or Product2.Name like 'UNITY%' )];
                    if(lstAssets.size()>0)
                    {
                        isSynced=true;
                    } 
                }
                if(isSynced)
                {
                    oldAccinfo.addError('You cannot delete/merge this account as it is synced with cloud portal. Please contact salesforce administrator.');
                }
            }
        }
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        
        if(newItems!=null && newItems.size()>0)
        {
            for (Id accId : newItems.keyset())
            {
                Account newAccInfo= (Account)newItems.get(accId);
                if(newAccInfo.Patch__c == null)
                {
                    accNeedsPatchAssign.add(newAccInfo.Id);
                }
                else
                {
                    accNeedsTeamAssign.add(newAccInfo.Id);
                }
            }
            LinkAccountToPatch(accNeedsPatchAssign, accNeedsTeamAssign, null);
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        List<Account> lstPartnerAcctIds= new List<Account>();
        List<Id> setPortalUserAcctId= new List<Id>();
        Set<Id> setSelfRegAcctIds= new Set<Id>();
        Map<Id,string> oppTypeAccIds= new Map<Id,string>();
        List<Opportunity> lstOpportunity= new List<Opportunity>();
        List<Contract> lstContract= new List<Contract>();
        Set<Id> accPatchChanged = new Set<Id>();
        Map<Id,Account> mapContractAccIds = new Map<Id,Account>();
        Set<Id> ownerIds = new Set<Id>();
        List<Account> lstDevOps= new List<Account>();
        /* List<Id> capCreationAcctId= new List<Id>(); Cap Project */
        if(newItems!=null && newItems.size()>0)
        {
            lstOpportunity=[Select Id,AccountId,CloseDate,Fiscal_Quarter_Name__c,StageName,Type,Trigger_Assignment__c,Patch_Locked__c  from Opportunity where AccountId in:newItems.keyset()]; // Fetch All Opps 
            lstContract = [select Id,AccountId, Trigger_Notice__c,Include_For_Notice__c from Contract where AccountId in:newItems.keyset()];// FetchAllContracts
            for (Id accId : newItems.keyset())
            {
                Account newAccInfo= (Account)newItems.get(accId);
                Account oldAccInfo= (Account)oldItems.get(accId);               
               
                if(newAccInfo.Partner_Application_Status__c == 'Approved' && oldAccInfo.Partner_Application_Status__c != 'Approved')
                {
                    lstPartnerAcctIds.add(new Account(Id=newAccInfo.Id,IsPartner=true));
                }
                if(newAccInfo.GEO_Supported__c != oldAccInfo.GEO_Supported__c)
                {
                    setPortalUserAcctId.add(newAccInfo.Id);
                }
                if(!newAccInfo.IsCustomerPortal && oldAccInfo.IsCustomerPortal)
                {
                    setSelfRegAcctIds.add(newAccInfo.Id);
                }   
                if(newAccInfo.First_Asset_Quarter__c!=oldAccInfo.First_Asset_Quarter__c)
                {
                    oppTypeAccIds.put(newAccInfo.Id,newAccInfo.First_Asset_Quarter__c);
                }
                if(newAccInfo.Patch_Locked__c == false)
                {
                    PatchRuleEngineBase.Target target = PatchRuleHelper.getTarget(newAccInfo);
                    PatchRuleEngineBase.Target oldTarget = PatchRuleHelper.getTarget(oldAccInfo);
                    if(newAccInfo.Trigger_Assignment__c || !PatchRuleHelper.isSameTarget(target, oldTarget))
                    {
                        accNeedsPatchAssign.add(newAccInfo.Id);
                    }
                }
                if(newAccInfo.Patch__c != oldAccInfo.Patch__c || newAccInfo.Trigger_Assignment__c)
                {
                    accNeedsTeamAssign.add(newAccInfo.Id);
                }
                if(newAccInfo.ECSP__c && (newAccInfo.Service_Provider_Account_Type__c=='Perpetual-Orchestrator SP' || newAccInfo.Service_Provider_Account_Type__c=='EC-SP-Metered +Orch-SP' || newAccInfo.Service_Provider_Account_Type__c=='EC-SP-Term +Orch-SP'))
                {
                    if(oldAccInfo.Cloud_Portal_Account_Key__c==null && newAccInfo.Cloud_Portal_Account_Key__c!=null && oldAccInfo.Cloud_Portal_Account_Name__c==null && newAccInfo.Cloud_Portal_Account_Name__c!=null)
                    {
                        lstDevOps.add(newAccInfo);
                    }
                }
                ownerIds.add(newAccInfo.OwnerId);
                if(newAccInfo.SendExpirationEmail__c == true && oldAccInfo.SendExpirationEmail__c == false)
                {
                    mapContractAccIds.put(newAccInfo.Id,newAccInfo);
                }
               /*  if(newAccInfo.IsCap__c!= oldAccInfo.IsCap__c && newAccInfo.IsCap__c== TRUE )
                {
                    capCreationAcctId.add(newAccInfo.Id);
                }  Cap Project */
            }
            LinkAccountToPatch(accNeedsPatchAssign, accNeedsTeamAssign, lstOpportunity);
            UpdateOppTypeforAccount(oppTypeAccIds,lstOpportunity);
            SetAccountAsPartner(lstPartnerAcctIds);
            EnforcePortalUserGroup(setPortalUserAcctId);
            DisableSelfRegForAccount(setSelfRegAcctIds);
            SendEmailToDevOps(lstDevOps);
            SendEmailsForContractExpiration(mapContractAccIds,ownerIds,lstContract);
            /* CreateCapAndCapCases(capCreationAcctId); Cap Project */
        }
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
    
    private void SendEmailToDevOps(List<Account> lstAcct )
    {
        for(Account newAccInfo: lstAcct)
        {
            String templateString='Please find the details to create MTO instance. \n\n Service Provider Domain : {0}\n\r Service Provider Location: {1}\n\r Service Provider Admin User: {2}\n\r';
            String[] arguments = new String[] {newAccInfo.Service_Provider_Domain__c,newAccInfo.Service_Provider_Location__c,newAccInfo.Service_Provider_Admin_User__c};
                string bodyText= string.format(templateString,arguments);
            //Send Email to DevOps Team
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            List<OrgWideEmailAddress> addresses = [select Id from OrgWideEmailAddress where Address='notifications@silver-peak.com' limit 1];
            if(addresses.size() > 0)
            {
                message.setOrgWideEmailAddressId(addresses[0].Id);
            }
            message.toAddresses = new String[] {'devopshelp@silver-peak.com','notifications@silver-peak.com'};
                message.subject = 'Please create MTO instance for this account '+ newAccInfo.Cloud_Portal_Account_Name__c;
            message.plainTextBody = bodyText;
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: '
                             + results[0].errors[0].message);
            }
        }
    }
    
 /* private void CreateCapAndCapCases(List<Id> setAcctIds)
 {
   Cap__c cap = new Cap__c();
   List<Cap_Case__c> lstCapCase = new List<cap_Case__c>();
   List<Case> lstAscCases = [Select Id, ClosedDate, CaseNumber, LastUpdateNote__c  from Case where 
                                       RecordtypeId IN ('012500000005AuO','012500000005Aui') AND ClosedDate = NULL
                                       AND AccountId =:setAcctIds]; 
  if(setAcctIds!=null && setAcctIds.size()>0)
  {
  for(Id item: setAcctIds)
   {
    cap.Account_Name__c = setAcctIds[0]; 
    cap.Status__c       = 'Open';
   }
    insert cap;

  if(lstAscCases.size()>0)
  {
     for(Case c : lstAscCases)
     {    
       Cap_Case__c cCase    = new Cap_Case__c();
       cCase.Cap_Name__c    = cap.Id;
       cCase.Case_Number__c = c.Id;       
       lstCapCase.add(cCase); 
     }
   }
       if (lstCapCase.size()> 0)  
       insert lstCapCase; 
  } 
 } Cap Project */
    
    private void SendEmailsForContractExpiration(Map<Id,Account> mapAcct,Set<Id> ownerIds,List<Contract> lstContracts)
    {
        List<Contract> lstContractToUpdate= new List<Contract>();
        List<Account> lstAccountToUpdate= new List<Account>();
        
        if(mapAcct!=null && mapAcct.size()>0)
        {
            if(ownerIds!=null && ownerIds.size()>0)
            {
                for(User usr : [select Id, Default_TR__c, Default_TR__r.Email from User where Id in :ownerIds and IsActive=true])
                {
                    if(usr.Default_TR__c != null)
                    {
                        user2TREmail.put(usr.Id, usr.Default_TR__r.Email);
                    }
                }
                for(User usr :[select Id, Email from User where UserRole.Name='Director of Customer Service' and UserType='Standard' and IsActive=true])
                {
                    directorEmails.add(usr.Email);
                }
            }
            for(Id item:mapAcct.keySet())
            {
                Boolean t90Sent = false, t60Sent = false, t0Sent = false;
                Account acc=mapAcct.get(item);
                if(lstContracts!=null && lstContracts.size()>0)
                {
                    for(Contract ct : lstContracts)
                    {
                        if(ct.AccountId==item && ct.Trigger_Notice__c!=null && ct.Include_For_Notice__c==1)
                        {
                            if(ct.Trigger_Notice__c == 'T90')
                            {
                                if(!t90Sent)
                                {
                                    t90Sent = true;
                                    sendT90Emails(acc);
                                }
                            }
                            else if(ct.Trigger_Notice__c == 'T60')
                            {
                                if(!t60Sent)
                                {
                                    t60Sent = true;
                                    sendT60Emails(acc);
                                }
                            }
                            else if(ct.Trigger_Notice__c == 'T0')
                            {
                                if(!t0Sent)
                                {
                                    t0Sent = true;
                                    sendT0Emails(acc);
                                }
                            }
                        }
                    }
                }
                
                if(acc.SendExpirationEmail__c == true)
                {
                    try
                    {
                        lstAccountToUpdate.add( new Account(Id=acc.Id, SendExpirationEmail__c=false));
                        for(Contract ct : lstContracts)
                        {
                            if(ct.AccountId==item && ct.Trigger_Notice__c!=null && ct.Include_For_Notice__c==1)
                            {
                                lstContractToUpdate.add( new Contract(Id=ct.Id,Trigger_Notice__c = null)); 
                            }
                            
                        }
                        
                    }
                    catch(Exception ex)
                    {
                        acc.addError(ex.getMessage());
                    }
                }
                
                break;
            }
            if(lstContractToUpdate.size()>0)
            {
                update lstContractToUpdate;
            }
            if(lstAccountToUpdate.size()>0)
            {
                update lstAccountToUpdate;
            }
        }
        
    }
    private void LinkAccountToPatch(List<Id> accPatchIds, List<Id> accTeamIds,List<Opportunity> lstOpp)
    {
        List<Opportunity> lstFinalOpps = new List<Opportunity>();
        if(accPatchIds!=null && accPatchIds.size() > 0)
        {
            PatchRuleHelper.assignPatch(accPatchIds);
        }
        if(accTeamIds!=null && accTeamIds.size() > 0)
        {
            PatchRuleHelper.assignTeamMembers(accTeamIds);
        }
        for(Id accId:accPatchIds)
        {
            if(lstOpp!=null && lstOpp.size()>0)
            {
                for(Opportunity opp:lstOpp)
                {
                    if(opp.AccountId==accId && !opp.Patch_Locked__c && !opp.StageName.contains('Closed'))
                    {
                        lstFinalOpps.add(new Opportunity(Id=opp.Id,Trigger_Assignment__c =true));
                    }
                }
            }
        }
        if(lstFinalOpps.size()>0)
        { 
            update lstFinalOpps;
        } 
    }
    private void UpdateOppTypeforAccount(Map<Id,string> mapOppType, List<Opportunity> lstOpp)
    {
        List<Opportunity> allOppsToUpdate= new List<Opportunity>();
        if(mapOppType!=null && mapOppType.size()>0)
        {
            for(Id accId :mapOppType.keySet())
            {
                if(lstOpp!=null && lstOpp.size()>0)
                {
                    for(Opportunity opp : lstOpp)
                    {
                        if(opp.AccountId==accId && opp.StageName!='Closed Dead' && opp.StageName!='Closed Deleted'&& opp.StageName!='Closed Lost')
                        {
                            if(opp.Type==null|| opp.Type=='New Business'|| opp.Type=='Follow on Business')
                            {
                                string type='New Business';
                                string recordTypeId='012500000005bUW';
                                if(mapOppType.get(accId)!=null && opp.Fiscal_Quarter_Name__c!=mapOppType.get(accId))
                                {
                                    type='Follow on Business';
                                    recordTypeId='012500000005bUb';
                                }
                                opp.Type= type;
                                opp.RecordTypeId=recordTypeId;
                                allOppsToUpdate.add(opp);
                            }
                        }
                    }
                }
            }
        }
        if(allOppsToUpdate.size()>0)
        {
            update allOppsToUpdate;
        }
    }
    private void DisableSelfRegForAccount(Set<Id> accIds)
    {
        if(accIds.size()>0)
        {
            List<Contact> lstCon=[Select Id from Contact where AccountId in: accIds and CanAllowPortalSelfReg=true];
            Set<Id> conIds= new Set<Id>();
            for(Contact con: lstCon)
            {
                conIds.add(con.Id);
            }
            ContactOwnershipHelper.DisableAllowSelfReg(conIds);
        }
    }
    private void EnforcePortalUserGroup(List<Id> setAcctIds)
    {
        if(setAcctIds.size() > 0)
        {
            PartnerPortalUserSharingBatch job = new PartnerPortalUserSharingBatch(setAcctIds);
            Database.executeBatch(job);
        }
    }
    private void SetAccountAsPartner(List<Account> lstAcctInfo)
    {
        if(lstAcctInfo.size() > 0)
        {
            try
            {
                update lstAcctInfo; 
            }
            catch(Exception ex)
            {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toaddress = New String[] {UserInfo.getUserEmail()};
                    email.setPlainTextBody('UpdateAccountIsPartner Error:' + ex.getMessage() );
                email.setToAddresses(toaddress);
                Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});
            }
        }
    }
    //sends T90 email to account owner and cc to notification@sp
    private void sendT90Emails(Account acc)
    {
        Id t90Template = [select Id from EmailTemplate where DeveloperName='Contract_Fulfilment_T_90' limit 1].Id;
        Id orgWideId = getOrgWideId();
        Contact recipient = createTempContact(acc.OwnerId, acc.Id);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(t90Template);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(recipient.Id);
        List<String> recipients = new List<String> { 'notifications@silver-peak.com','renewals@silver-peak.com' };
            if(user2TREmail.containsKey(acc.OwnerId))
        {
            recipients.add(user2TREmail.get(acc.OwnerId));
        }
        mail.setccAddresses(recipients);
        mail.setWhatId(acc.Id);
        mail.setUseSignature(false);
        if(orgWideId != null)
        {
            mail.setOrgWideEmailAddressId(orgWideId);
        }
        Messaging.sendEmail(new Messaging.Email[] { mail });
        delete recipient;
    }
    
    //sends T60 email to account owner and cc to customer signed by and notifications@sp
    private void sendT60Emails(Account acc)
    {
        Id t60Template = [select Id from EmailTemplate where DeveloperName='Contract_Fulfilment_T_60' limit 1].Id;
        Id orgWideId = getOrgWideId();
        Set<String> customerEmails = new Set<String>();
        List<Messaging.Email> mails = new List<Messaging.Email>();
        Contact recipient = createTempContact(acc.OwnerId, acc.Id);
        
        for(Contract ct : getExpiredContracts(acc.Id, 'T60'))
        {
            if(ct.CustomerSigned.Email != null)
            {
                customerEmails.add(ct.CustomerSigned.Email);
            }
            if(ct.Customer_Addl_Notices__r.Email != null)
            {
                customerEmails.add(ct.Customer_Addl_Notices__r.Email);
            }
            if(ct.Customer_Addl_Notices_2__r.Email != null)
            {
                customerEmails.add(ct.Customer_Addl_Notices_2__r.Email);
            }
        }
        if(customerEmails.size() > 0)
        {
            if(user2TREmail.containsKey(acc.OwnerId))
            {
                customerEmails.add(user2TREmail.get(acc.OwnerId));
            }
            customerEmails.add('notifications@silver-peak.com');
            customerEmails.add('renewals@silver-peak.com');
            List<String> ccAddresses = new List<String>();
            ccAddresses.addAll(customerEmails);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(t60Template);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(recipient.Id);
            mail.setccAddresses(ccAddresses);
            mail.setWhatId(acc.Id);
            mail.setUseSignature(false);
            if(orgWideId != null)
            {
                mail.setOrgWideEmailAddressId(orgWideId);
            }
            Messaging.sendEmail(new List<Messaging.EMail> { mail });
        }
        delete recipient;
    }
    
    //sends T0 email to contract signed contact and cc to account owner and notifications@sp
    private void sendT0Emails(Account acc)
    {
        Id expirationTemplate = [select Id from EmailTemplate where DeveloperName='Contract_Expiration' limit 1].Id;
        Id orgWideId = getOrgWideId();
        List<Messaging.Email> mails = new List<Messaging.Email>();
        for(Contract ct : getExpiredContracts(acc.Id, 'T0'))
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(expirationTemplate);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(ct.CustomerSignedId);
            List<String> recipients = new List<String> { getUserEmail(acc.OwnerId), 'notifications@silver-peak.com','renewals@silver-peak.com' };
                if(ct.Customer_Addl_Notices__r.Email != null)
            {
                recipients.add(ct.Customer_Addl_Notices__r.Email);
            }
            if(ct.Customer_Addl_Notices_2__r.Email != null)
            {
                recipients.add(ct.Customer_Addl_Notices_2__r.Email);
            }
            if(user2TREmail.containsKey(acc.OwnerId))
            {
                recipients.add(user2TREmail.get(acc.OwnerId));
            }
            recipients.addAll(directorEmails);
            mail.setccAddresses(recipients);
            mail.setWhatId(ct.Id);
            mail.setUseSignature(false);
            if(orgWideId != null)
            {
                mail.setOrgWideEmailAddressId(orgWideId);
            }
            mails.add(mail);
        }
        if(mails.size() > 0)
        {
            Messaging.sendEmail(mails);
        }
    }
    
    private Contact createTempContact(Id userId, Id accountId)
    {
        User usr = [select Id, LastName, FirstName, Email from User where Id=:userId limit 1];
        Contact ct = new Contact(FirstName=usr.FirstName, LastName=usr.LastName, Email=usr.Email, AccountId=accountId);
        insert ct;
        return ct;
    }
    
    private String getUserEmail(Id userId)
    {
        User usr = [select Id, Email from User where Id=:userId limit 1];
        return usr.Email;
    }
    
    private List<Contract> getExpiredContracts(Id accountId, String triggerNotice)
    {
        return [select Id, CustomerSignedId, CustomerSigned.Email, Customer_Addl_Notices__r.Email, Customer_Addl_Notices_2__r.Email from Contract where AccountId=:accountId and Trigger_Notice__c=:triggerNotice and Include_For_Notice__c=1];
    }
    
    private Id getOrgWideId()
    {
        List<OrgWideEmailAddress> addresses = [select Id from OrgWideEmailAddress where Address='notifications@silver-peak.com' limit 1];
        if(addresses.size() > 0)
        {
            return addresses[0].Id;
        }
        else
        {
            return null;
        }
    }
    
}