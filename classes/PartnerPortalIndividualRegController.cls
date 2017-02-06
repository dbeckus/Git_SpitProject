/*
 * Controller of page PartnerPortalIndividualReg
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'Our records indicate that you already have partner portal access. Please click on the Forgot your Password link <a href="https://partners.silver-peak.com/PartnerLogin" style="font-size:100%;margin:0;text-decoration:underline">here</a>.'));
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
        }
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
                    return null;
                }
                else if(matchedAccounts.size() == 0)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'We did not find any matching partner in our system. Please make sure your email address is right.'));
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Thanks for the signing up. Your login is enabled. We will send you an email with your login account.'));
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
            System.assert(false, ex.getMessage());
        }
        return null;
    }
    
    private Boolean userIsExist()
    {
        String spName = Email + '.sp';
        Integer c = [select count() from User where IsActive=true and UserType='PowerPartner' and Username=:spName limit 1];
        return c > 0;
    }
    
    private List<Contact> findContacts()
    {
        return [select Id from Contact where (Account.Partner_Application_Status__c='Approved' or Account.IsPartner=true) and Email=:Email];
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
        String[] domains = domainStr.split('[,@\\s]');
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
}