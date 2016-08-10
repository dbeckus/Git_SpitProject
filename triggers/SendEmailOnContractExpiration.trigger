/*
 * Sends the contract expiration emails
 * It doesn't support mass update
 */
trigger SendEmailOnContractExpiration on Account (after update) 
{
    Map<Id, String> user2TREmail = new Map<Id, String>();
    Set<Id> ownerIds = new Set<Id>();
    List<String> directorEmails = new List<String>();
    
    for(Account acc : Trigger.new)
    {
        ownerIds.add(acc.OwnerId);
    }
    for(User usr : [select Id, Default_TR__c, Default_TR__r.Email from User where Id in :ownerIds])
    {
        if(usr.Default_TR__c != null)
        {
            user2TREmail.put(usr.Id, usr.Default_TR__r.Email);
        }
    }
    for(User usr : [select Id, Email from User where UserRole.Name='Director of Customer Service' and IsActive=true])
    {
        directorEmails.add(usr.Email);
    }
    
    for(Account acc : Trigger.new)
    {
        Boolean t90Sent = false, t60Sent = false, t0Sent = false;
        Account oldAcc = Trigger.oldMap.get(acc.Id);
        if(acc.SendExpirationEmail__c == true && oldAcc.SendExpirationEmail__c == false)
        {
            List<Contract> contracts = [select Id, Trigger_Notice__c from Contract where AccountId=:acc.Id and Trigger_Notice__c!=null and Include_For_Notice__c=1];
            for(Contract ct : contracts)
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
            if(acc.SendExpirationEmail__c == true)
            {
                try
                {
                    update new Account(Id=acc.Id, SendExpirationEmail__c=false);
                    for(Contract ct : contracts)
                    {
                        ct.Trigger_Notice__c = null;
                    }
                    update contracts;
                }
                catch(Exception ex)
                {
                    acc.addError(ex.getMessage());
                }
            }
        }
        break;
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