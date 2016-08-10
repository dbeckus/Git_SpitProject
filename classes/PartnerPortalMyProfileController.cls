public with sharing class PartnerPortalMyProfileController 
{ 
    public PartnerPortalMyProfileController(ApexPages.StandardController controller) 
    {   
        MyProfile = [select Id, ContactId, Contact.AccountId, FirstName, LastName, UserName, Title, Email, Phone, Fax, MobilePhone, Street,
                                City, State, PostalCode, Country, Department, ManagerId from User where Id = :UserInfo.getUserId() limit 1];
        List<Partner_Contact_Profile__c> extras = [select Id, Job_Function__c, Birth_Date__c, Reports_To__c, Industry_Certifications_Held__c, Skype_Name__c, IM_Name__c, Dell_Segment__c from Partner_Contact_Profile__c where Contact__c=:MyProfile.ContactId limit 1];
        if(extras.size() > 0)
        {
            MyProfileExtra = extras[0];
        }
        else
        {
            MyProfileExtra = new Partner_Contact_Profile__c(Contact__c=MyProfile.ContactId);
        }
        List<Partner_Account_Profile__c> extraAccounts = [select Id, Account__r.Owner.Name, Address__c, Address_2__c, City__c, Postal_Code__c, Phone__c, Fax__c, Company_Legal_Name__c, Email_Domains_Used__c, Doing_Business_As__c, Tax_ID_Type__c, Tax_ID_Type_Other__c, Tax_ID_Number__c, Years_in_Business__c, Number_of_Employees__c, Number_of_Sales_Engineers__c, Number_of_Sales_Representatives__c, Company_Revenue__c, WAN_Optimization__c, Virtualization__c, Data_Center_Solutions__c, Security__c, Storage__c, Unified_Communications_VOIP__c, Wireless_WAN_LAN__c, Other__c, Revenue_Other__c, Go_To_Market_Sales_Model__c, Go_To_Market_Sales_Model_Other__c,Marketing_Segments_Served__c, Product_Categories_Sold__c, Silver_Peak_Products_Sold__c, Applications__c, Professional_Services_Offered__c, Channel_Programs_Participated__c, Channel_Programs_Participated_Other__c, Silver_Peak_Competencies__c, Provide_Professional_Services__c, Provide_Managed_Services__c from Partner_Account_Profile__c where Account__c=:MyProfile.Contact.AccountId limit 1];
        if(extraAccounts.size() > 0)
        {
            AccountProfile = extraAccounts[0];
        }
        else
        {
            AccountProfile = new Partner_Account_Profile__c();
        }
        AccountAddresses = new Map<String, Partner_Portal_Account_Profile_Address__c> {
            'Branch' => new Partner_Portal_Account_Profile_Address__c(), 
            'Headquarter' => new Partner_Portal_Account_Profile_Address__c(),
            'Primary HQ Contact' => new Partner_Portal_Account_Profile_Address__c(),
            'Primary Technical Contact' => new Partner_Portal_Account_Profile_Address__c(),
            'Primary Marketing Contact' => new Partner_Portal_Account_Profile_Address__c(),
            'CEO/General Manager' => new Partner_Portal_Account_Profile_Address__c(),
            'Primary Sales Contact' => new Partner_Portal_Account_Profile_Address__c()
        }; 
        for(Partner_Portal_Account_Profile_Address__c add : [select Id, Type__c, First_name__c, Last_Name__c, Address_1__c, Address_2__c, City__c, Country__c, State__c, Postal_Code__c, Email__c, Phone__c, Fax__c from Partner_Portal_Account_Profile_Address__c where Partner_Account_Profile__c=:AccountProfile.Id])
        {
            AccountAddresses.put(add.Type__c, add);
        }
        TemporaryAddress = new Partner_Account_Profile__c(Country__c=MyProfile.Country);
    }

    public User MyProfile { get; set; }    
    public Partner_Contact_Profile__c MyProfileExtra { get; set; }
    public Partner_Account_Profile__c AccountProfile { get; set; }
    public Map<String, Partner_Portal_Account_Profile_Address__c> AccountAddresses { get; set; }
    public Partner_Account_Profile__c TemporaryAddress { get; set; }  /* On the my profile page, used for dependency picklist */
    public Boolean UpdateProfileSucceeded { get; private set; }

    public PageReference updateProfile()
    {
        try
        {
            MyProfile.Country = TemporaryAddress.Country__c;
            MyProfile.Username = MyProfile.Email + '.sp';   //avoid duplicate name in other org
            update MyProfile;
            UpdateProfileSucceeded = true;
        }
        catch(Exception ex)
        {
            UpdateProfileSucceeded = false;
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference updateProfileExtra()
    {
        List<Contact> contacts = [select FirstName, LastName, Title, Email, Phone, Fax, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, Department, Birthdate from Contact where Id = :MyProfile.ContactId];
        if(contacts.size() > 0)
        {
            Contact myContact = new Contact(Id = MyProfile.ContactId);
            myContact.FirstName = MyProfile.FirstName;
            myContact.LastName = MyProfile.LastName;
            myContact.Title = MyProfile.Title;
            myContact.Email = MyProfile.Email;
            myContact.Phone = MyProfile.Phone;
            myContact.Fax = MyProfile.Fax;
            myContact.MobilePhone = MyProfile.MobilePhone;
            myContact.MailingStreet = MyProfile.Street;
            myContact.MailingCity = MyProfile.City;
            myContact.MailingState = MyProfile.State;
            myContact.MailingPostalCode = MyProfile.PostalCode;
            myContact.MailingCountry = MyProfile.Country;
            myContact.Department = MyProfile.Department;
            myContact.Birthdate = MyProfileExtra.Birth_Date__c;
                    
            try
            {
                update myContact;
                upsert MyProfileExtra;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Profile has been updated. If you updated your email address, please use the new email to login.'));
    
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }

    @isTest
    static void test1()
    {
        PartnerPortalMyProfileController controller = new PartnerPortalMyProfileController(new ApexPages.StandardController(new User(Id=UserInfo.getUserId())));
        controller.updateProfileExtra();
    }
    
    @isTest
    static void test2()
    {
        PartnerPortalMyProfileController controller = new PartnerPortalMyProfileController(new ApexPages.StandardController(new User(Id=UserInfo.getUserId())));
        controller.updateProfile();
    }
}