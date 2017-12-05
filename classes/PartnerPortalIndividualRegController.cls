/*
 * Controller of page PartnerPortalIndividualReg
 * Change Log:
 * 2017-03-07: SnapBI-Andy: updated user messaging per client request
 * 2017-06-05: Added language for success message
 * 2017-08-03: Updated by Jimmy Li, added method to skip steps if the contact already have a portal user related
 * 2017-09-30: Updated by Jimmy Li. Updated logic if the contact has a user related.
 * 2017-10-23: Updated by Jimmy Li. Remove email notification when multiple accounts/users macthed, only sends email when multiple conatcts matched.
 */
public without sharing class PartnerPortalIndividualRegController
{
    private Id PartnerPortalProfileId;
    
    public PartnerPortalIndividualRegController()
    {
        MultipleAccounts = new List<SelectOption>();
        List<Profile> profiles = [select Id from Profile where Name='13g-SP Partner Community' limit 1];
        PartnerPortalProfileId = (profiles.size() > 0) ? profiles[0].Id : null;
        TemporaryAddress = new Partner_Account_Profile__c();
        NewUserProfile = new Partner_Contact_Profile__c();
        finished = false;
    }
    
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Title { get; set; }
    public String CompanyName { get; set; }
    public String Email { get; set; }
    public String Phone { get; set; }
    public String State { get; set; }
    public String City { get; set; }
    public String ZipCode { get; set; }
    //adding checkbox to track partner portal T & C agreement
    public Boolean PortalTC { get; set; }
    public Partner_Contact_Profile__c NewUserProfile { get; set; }
    public Partner_Account_Profile__c TemporaryAddress { get; set; }  /* For dependent picklists on page */
    
    public Id SelectedAccountId { get; set; }
    public Id ExistingContactId { get; set; }
    public List<SelectOption> MultipleAccounts { get; set; }
    
    public Boolean finished { get; set; }
    
    public PageReference save()
    {
        if(userIsExist())
        {
            //Error Scenario 1
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Our records indicate that you already have partner portal access. Please click <a href="https://partners.silver-peak.com/PartnerPortalForgotPassword" style="font-size:100%;margin:0;text-decoration:underline">here</a> to reset your password.'));
            return null;
        }
        if(PortalTC == FALSE)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must agree to the terms and conditions to proceed.'));
            return null;
        }
        List<Contact> matchedContacts = findContacts();
        if(matchedContacts.size() == 1)
        {
            ExistingContactId = matchedContacts[0].Id;
            //Added at 2017-08-03
            if(hasRelatedUser(ExistingContactId))
            {
                ExistingContactId = null;
                /*Added at 2017-09-30: if this emal also related to a customer user, send email to SP for a double check. 'pchavez@silver-peak.com','channel@silver-peak.com'
                sendNotifications('Notification: The New Partner Portal User Also Has Customer Portal Access - Request Partner Portal Access',
                    '\r\n The user\'s email also associated to a another user.',
                    true, 'Notification: We also found another user has been related to your email address - Request Partner Portal Access',
                    'Please double check your account.', new String[]{Email});
                /Added ends at 2017-09-30 [removed at 2017-10-23] */
            }//<== Added ends at 2017-08-03
        }else if(matchedContacts.size() > 0)//Added at 2017-09-30, if multiple contacts are matched, prevent the login process and sends an email to alieen as notification
        {
            String contactList = '';
            for(Contact ctc : matchedContacts)
            {
                contactList += ctc.Name +'\r\n';
            }//updated at 2017-10-23
            sendNotifications('Notification: Multiple Contacts Found - Request Partner Portal Access',
                    'Below are the list of matched contacts:\r\n\r\n'+contactList, false, '', '', null);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Sorry, We found multiple records based on the information you provided. Please verifiy the form or contact your account manager.'));
            return null;
        }//ends

        if(ExistingContactId == null)
        {
            if(SelectedAccountId == null)
            {
                List<Account> matchedAccounts = findAccounts();
                if(matchedAccounts.size() == 1)
                {
                    SelectedAccountId = matchedAccounts[0].Id;
                }
                else if(matchedAccounts.size() > 1)
                {
                    MultipleAccounts.clear();
                    MultipleAccounts.add(new SelectOption('', ' - Select Your Company -'));
                    for(Account acc : matchedAccounts)
                    {
                        MultipleAccounts.add(new SelectOption(acc.Id, acc.Name));
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'We found multiple records matching your company, please choose one.'));
                    /*Added at 2017-09-30 [removed at 2017-10-23]
                    sendNotifications('Notification: A Partner Portal User Activeted With Multiple Accounts Matched - Request Partner Portal Access',
                    '', false, '', '', null);//ends*/

                    return null;
                }
                else if(matchedAccounts.size() == 0)
                {
                    //Error Scenario 3
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'We did not find any matching partner in our system. Please make sure your email address is correct or submit a partner application form <a href="https://partners.silver-peak.com/s/BecomePartner" style="font-size:100%;margin:0;text-decoration:underline" target="null">here</a>.'));
                    return null;
                }
            }
        }
        SavePoint sp = Database.setSavepoint();
        try
        {
            upsertContact();
            createUser();
            finished = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Thanks for the signing up. Your login is enabled. We will send you an email with your login account. If you do not receive an email in a few minutes, please check your spam folder.'));
        }
        catch(Exception ex)
        {
            ExistingContactId = null;
            SelectedAccountId = null;
            MultipleAccounts = new List<SelectOption>();
            NewUserProfile = NewUserProfile.clone(false, false, false, false);
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Failed to process your request. Please contact your account manager.'));
            ApexPages.addMessages(ex);
            //Added at 2017-09-30
            sendErrorNotification(ex.getMessage()+'\r\n'+ex.getStackTraceString());
        }
        return null;
    }
    
    private Boolean userIsExist()
    {
        String spName = Email + '.sp';
        Integer c = [select count() from User where IsActive=true and UserType='PowerPartner' and Username=:spName limit 1];
        return c > 0;
    }
    
    //Added at 2017-08-03, to find out if this contact allready regitered as a customer user before
    private Boolean hasRelatedUser(Id ctcId)
    {
        Integer count = [select count() from User where IsActive=true and ContactId = :ctcId];
        return count > 0;
    }//<== Added ends
    
    private List<Contact> findContacts()
    {
        return [select Id, Name from Contact where (Account.Partner_Application_Status__c='Approved' or Account.IsPartner=true) and Email=:Email];
    }

    
    private List<Account> findAccounts()
    {
        String domain = getEmailDomain(Email);
        String pattern = '%' + domain + '%';
        List<Id> emailMatchedAccounts = new List<Id>();
        for(Account acct : [select Id, Email_Domain_Used__c from Account where Email_Domain_Used__c != null and Email_Domain_Used__c like :pattern and (Partner_Application_Status__c='Approved' or IsPartner=true)])
        {
            if(domainIsMatched(acct.Email_Domain_Used__c, domain))
            {
                emailMatchedAccounts.add(acct.Id);
            }
        }
        return [select Id, Name from Account where Id in :emailMatchedAccounts];
    }
    
    private void upsertContact()
    {
        Contact newUser = new Contact(Id=ExistingContactId);
        if(SelectedAccountId != null)
        {
            newUser.AccountId = SelectedAccountId;
            List<Account> ownerAccounts = [select Id, OwnerId from Account where Id=:SelectedAccountId limit 1];
            newUser.OwnerId = (ownerAccounts.size() > 0) ? ownerAccounts[0].OwnerId : null;
        }
        newUser.FirstName = FirstName;
        newUser.LastName = LastName;
        newUser.Title = Title;
        newUser.Email = Email;
        newUser.Phone = Phone;
        newUser.MailingCountry = TemporaryAddress.Country__c;
        newUser.MailingState = State;
        newUser.MailingCity = City;
        newUser.MailingPostalCode = ZipCode;
        newUser.LeadSource = 'Partner Portal';
        //adding checkbox to track partner portal T & C agreement
        newUser.PortalTermsandConditionsAgreement__c = PortalTC;
        upsert newUser;
        System.debug(newUser);
        
        NewUserProfile.Contact__c = newUser.Id;
        upsert NewUserProfile;
        
        ExistingContactId = newUser.Id;
    }
    
    private void createUser()
    {
        //append .sp to email as username in case of duplicate name in other org
        User newUser = new User(FirstName=FirstName, 
                                LastName=LastName, 
                                Email=Email, 
                                Username=Email + '.sp', 
                                ProfileId=PartnerPortalProfileId, 
                                ContactId=ExistingContactId,
                                Alias=FirstName.left(7) + LastName.left(1),
                                TimeZoneSidKey='America/Tijuana',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='ISO-8859-1',
                                LanguageLocaleKey='en_US',
                                Country = TemporaryAddress.Country__c,
                                State = State,
                                City = City,
                                PostalCode = ZipCode,
                                Phone = Phone
                                );
        insert newUser;
    }
    
    private Boolean domainIsMatched(String domainStr, String domain)
    {
        domainStr = (domainStr == null) ? '' : domainStr;
        domain = (domain == null) ? '' : domain;
        String[] domains = domainStr.split('[,;@\\s]');
        for(String d : domains)
        {
            if(domain.toLowerCase() == d.toLowerCase())
            {
                return true;
            }
        }
        return false;
    }
    
    private static String getEmailDomain(String email)
    {
        if(email == null)
        {
            email = '';
        }
        if(email.indexOf('@') >= 0)
        {
            return email.substring(email.indexOf('@')+1);
        }
        else
        {
            return '';
        }
    }

    //Added at 2017-09-30
    private String buildEmailMessageWithRequest()
    {
        String message = '';
        message += 'Below are the request details:\r\n\r\n';
        message += 'First Name: '+FirstName+'\r\n';
        message += 'Last Name: '+LastName+'\r\n';
        message += 'Title: '+Title+'\r\n';
        message += 'Company Name: '+CompanyName+'\r\n';
        message += 'Email: '+Email+'\r\n';
        message += 'Phone: '+Phone+'\r\n';
        message += 'State: '+State+'\r\n';
        message += 'City: '+City+'\r\n';
        message += 'ZipCode: '+ZipCode+'\r\n';
        message += 'Email Opt-In: '+((NewUserProfile.Email_Opt_In__c)?'TRUE':'FALSE')+'\r\n\r\n';
        return message;
    }

    private Messaging.SingleEmailMessage buildEmail(String subject, String body, String endMessage, List<String> toAddresses)
    {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setSubject(subject);
        email.setPlainTextBody(body+endMessage);
        email.setSaveAsActivity(false);
        return email;
    }

    private void sendErrorNotification(String content)
    {
        Messaging.sendEmail(new List<Messaging.Email> { buildEmail('Silver Peak: Error Occured on Partner Portal Reg Page',content, '', new String[]{'silverpeak@snapbi.com'}) });
    }

    private void sendNotifications(String subject, String spEndBody, Boolean sentToUser, String userSubject, String userEndBody,  List<String> userToAddresses)
    {
        List<Messaging.Email> emails = new List<Messaging.Email>();
        String body = buildEmailMessageWithRequest();
        emails.add(buildEmail(subject, body, spEndBody, new String[] {'pchavez@silver-peak.com','channel@silver-peak.com'}));//'pchavez@silver-peak.com','channel@silver-peak.com'
        if(sentToUser == true){ emails.add(buildEmail(userSubject, body, userEndBody, userToAddresses)); }
        Messaging.sendEmail(emails);
    }
    //Ends
}