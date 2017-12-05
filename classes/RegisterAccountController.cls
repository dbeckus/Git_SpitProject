/*
 * Controller of VF page BecomePartner
 *
 *@changelog
 *21APR2016: Daniel - Created, removed commented email domains used validation and updated error messaging
 *10JUN2016: Andy Getz - set account partner type to resellers and set GEO Supported to selection from region field
 *07NOV2016: Jimmy Li - set contact lead cource to Partner Portal, at line 104, 109 and 116.
 *09NOV2016: Daniel Wu - Disable submit button while the form is being submitted
 *22DEC2016: Zhong - updated 'illegal' to 'invalid'
 *12JAN2017: Daniel - updated: create Information card when matching account found.
 */
public class RegisterAccountController 
{
    public Account acct { get; set; }
    public Boolean succeeded { get; set; }
    public Partner_Portal_Account_Profile_Address__c ppapa { get; set; } //just for data binding of the region/country fields
    public Contact registerContact { get; set; }
    public Contact primaryContact { get; set; }
    public Contact signatoryContact { get; set; }
    public Contact marketingContact { get; set; }
    public String errorMessage { get; set; }
    public Map<String,String> dataBinding { get; set; }
    public Boolean isPrimaryPartner { get; set; }
    
    public RegisterAccountController(ApexPages.StandardController stdController)
    {
        isPrimaryPartner = false;
        succeeded = false;
        ppapa = new Partner_Portal_Account_Profile_Address__c();
        registerContact = new Contact();
        primaryContact = new Contact();
        signatoryContact = new Contact();
        marketingContact = new Contact();
        errorMessage = '';
        dataBinding = new Map<String,String>{
            'pcEmail' => '',
            'scEmail' => '',
            'mcEmail' => '',
            'rcEmail' => '',
            'outside' => '',
            'inside' => '',
            'engineers' => '',
            'product' => '',
            'services' => '',
            'consulting' => '',
            'accountName' => '',
            'rcLastName' => '',
            'pcLastName' => '',
            'scLastName' => '',
            'mcLastName' => ''
        };
        if(stdController != null)
        {
            this.acct = (Account)StdController.getRecord();
        }
    }

    public PageReference insertAccount()
    {
        errorMessage = '';
        if(acct.Are_you_the_primary_partner_contact__c != 'No')
        {
            dataBinding.put('pcEmail', dataBinding.get('rcEmail'));
            dataBinding.put('pcLastName', dataBinding.get('rcLastName'));
            primaryContact.FirstName = registerContact.FirstName;
            primaryContact.Title = registerContact.Title;
            primaryContact.Phone = registerContact.Phone;
            primaryContact.Business_Function__c= registerContact.Business_Function__c;
            primaryContact.Job_Role__c = registerContact.Job_Role__c;
        }
        if(validateSucceeded() == false)
        {
            return null;
        }
        if(!String.isBlank(ppapa.Region__c))
        {
            acct.Region__c = (String) ppapa.Region__c;
            acct.GEO_Supported__c = (String) ppapa.Region__c;
        }
        if(!String.isBlank(acct.Region__c))
        {
            acct.BillingCountry = (String) ppapa.Country__c;
        }
        acct.Name = dataBinding.get('accountName');
        primaryContact.LastName = dataBinding.get('pcLastName') ;
        signatoryContact.LastName = dataBinding.get('scLastName') ;
        marketingContact.LastName = dataBinding.get('mcLastName') ;
        registerContact.LastName = dataBinding.get('rcLastName') ;
        primaryContact.Email = dataBinding.get('pcEmail');
        signatoryContact.Email = dataBinding.get('scEmail');
        marketingContact.Email = dataBinding.get('mcEmail');
        registerContact.Email = dataBinding.get('rcEmail');
        fillAddress(primaryContact, acct);
        fillAddress(marketingContact, acct);
        fillAddress(signatoryContact, acct);
        fillAddress(registerContact, acct);
        acct.Number_of_sales_professionals_in_org__c = Integer.valueOf(dataBinding.get('outside'));
        acct.Professionals_in_your_org_Inside_Sales__c = Integer.valueOf(dataBinding.get('inside'));
        acct.Professionals_in_org__c = Integer.valueOf(dataBinding.get('engineers'));
        acct.business_is_Product_Sales__c = Integer.valueOf(dataBinding.get('product'));
        acct.business_is_Services_Sales__c = Integer.valueOf(dataBinding.get('services'));
        acct.business_is_Consulting_Sales__c = Integer.valueOf(dataBinding.get('consulting'));
        acct.Primary_Partner_Contact_E_Mail_Address__c = primaryContact.Email;
        acct.Partner_Signatory_Contact_E_Mail_Address__c = signatoryContact.Email;
        acct.Partner_Marketing_Contact_E_Mail_Address__c = marketingContact.Email;
        //setting account field for email template use
        //acct.Full_Name_Primary_Partner_Contact__c = primaryContact.FirstName + ' ' + primaryContact.LastName;
        acct.Type = 'Partner';
        acct.Reseller_Agreement_Acknowledged__c = true;
        acct.Partner_Type__c = 'Reseller';
        acct.Partner_Application_Status__c = 'Pending';
        acct.RecordTypeId = getRecordTypeId('Resellers');
        if(existingAccount(acct))
        {
            Information_Card__c ic = populateInfoCard(acct);
            savepoint sp = Database.setSavepoint();
            try
            {
                insert ic;
                ic = [select Id, PrimaryPartnerContact__c,SignatoryPartnerContact__c,MarketingPartnerContact__c,RegisteringUserContact__c from Information_Card__c where Id =: ic.Id];
                insertContacts(ic);
                ic.PrimaryPartnerContact__c = primaryContact.Id;
                if(String.isNotBlank(marketingContact.Id))
                {
                    ic.MarketingPartnerContact__c = marketingContact.Id;
                }
                if(String.isNotBlank(signatoryContact.Id))
                {
                    ic.SignatoryPartnerContact__c = signatoryContact.Id;
                }
                if(acct.Are_you_the_primary_partner_contact__c == 'No')
                {
                    if(String.isNotBlank(registerContact.Id))
                    {
                        ic.RegisteringUserContact__c = registerContact.Id;
                    }
                    else
                    {
                        if(registerContact.Email == primaryContact.Email)
                        {
                            ic.RegisteringUserContact__c = primaryContact.Id;
                        }
                        else if(registerContact.Email == signatoryContact.Email)
                        {
                            ic.RegisteringUserContact__c = signatoryContact.Id;
                        }
                        else
                        {
                            ic.RegisteringUserContact__c = marketingContact.Id;
                        }
                    }
                }
                else if(acct.Are_you_the_primary_partner_contact__c == 'Yes')
                {
                    ic.RegisteringUserContact__c = primaryContact.Id;
                }
                update ic;
                //submitToProcess(ic.Id);
                succeeded = true;
            }
            catch(Exception ex)
            {
                Database.rollback(sp);
                SilverPeakUtils.logException(ex); // log error when updated failed
                ApexPages.addMessages(ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getStackTraceString()));
            }
            return null;
        }
        SavePoint sp = Database.setSavepoint();
        
        try
        {
            insert acct;
            Account acct1 = [select Id, Name, Patch__c, CAM__c, OwnerId, Partner_Signatory_Contact_E_Mail_Address__c, Partner_Marketing_Contact_E_Mail_Address__c,PrimaryPartnerContact__c,SignatoryPartnerContact__c,MarketingPartnerContact__c,RegisteringUserContact__c from Account where Id =: acct.Id limit 1];
            List<Patch__c> patch = [select Id, CSM__c from Patch__c where Id =: acct1.Patch__c limit 1];
            if(patch.size() > 0)
            {
                acct1.CAM__c = patch[0].CSM__c;
                //adding owner assignment
                if(String.isNotBlank(patch[0].CSM__c))
                {
                    acct1.OwnerId = patch[0].CSM__c; 
                }
            }
            insertContacts(acct1);
            acct1.PrimaryPartnerContact__c = primaryContact.Id;
            acct1.SignatoryPartnerContact__c = String.isBlank(signatoryContact.Id) ? primaryContact.Id : signatoryContact.Id;
            if(String.isNotBlank(marketingContact.Id))
            {
                acct1.MarketingPartnerContact__c = marketingContact.Id;
            }
            else
            {
                if(acct1.Partner_Marketing_Contact_E_Mail_Address__c == acct1.Primary_Partner_Contact_E_Mail_Address__c)
                {
                    acct1.MarketingPartnerContact__c = primaryContact.Id;
                }
                else
                {
                    acct1.MarketingPartnerContact__c = signatoryContact.Id;
                }
            }
            if(acct.Are_you_the_primary_partner_contact__c == 'No')
            {
                if(String.isNotBlank(registerContact.Id))
                {
                    acct1.RegisteringUserContact__c = registerContact.Id;
                }
                else
                {
                    if(registerContact.Email == primaryContact.Email)
                    {
                        acct1.RegisteringUserContact__c = primaryContact.Id;
                    }
                    else if(registerContact.Email == signatoryContact.Email)
                    {
                        acct1.RegisteringUserContact__c = signatoryContact.Id;
                    }
                    else
                    {
                        acct1.RegisteringUserContact__c = marketingContact.Id;
                    }
                }
            }
            else if(acct.Are_you_the_primary_partner_contact__c == 'Yes')
            {
                acct1.RegisteringUserContact__c = primaryContact.Id;
            }
            update acct1;
            succeeded = true; 
            submitToProcess(acct1.Id);
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            SilverPeakUtils.logException(ex); // log error when exception occur.
            acct.Id = null;
            ApexPages.addMessages(ex);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getStackTraceString()));
        }
        return null;
    }
    
    private Boolean validateSucceeded()
    {
        String errorMessage1 = ' cannot be blank';
        String errorMessage2 = ' must contain only numbers';
        String errorMessage3 = ' must contain only letters';
        String errorMessage4 = errorMessage1 + ' and' + errorMessage3;
        String top3 = acct.TOP_3_industries__c;
        Boolean isPass = true;
        String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';
        if(String.isBlank(dataBinding.get('accountName')))
        {
            errorMessage += ';accountName:Company Name ' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(acct.BillingStreet))
        {
            errorMessage += ';:Street Address' + errorMessage1;
            acct.BillingStreet.addError('Street Address' + errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.BillingCity))
        {
            errorMessage += ';:City' + errorMessage1;
            acct.BillingCity.addError('City' + errorMessage1);
            isPass = false;
        }else if(!acct.BillingCity.isAlphaSpace())
        {
            errorMessage += ';:City' + errorMessage3;
            acct.BillingCity.addError('City' + errorMessage3);
            isPass = false;
        }
        if(String.isBlank(acct.BillingState))
        {
            errorMessage += ';:State/Province' + errorMessage1;
            acct.BillingState.addError('State/Province' + errorMessage1);
            isPass = false;
        }else if(!acct.BillingState.isAlphaSpace())
        {
            errorMessage += ';:State/Province' + errorMessage3;
            acct.BillingState.addError('State/Province' + errorMessage3);
            isPass = false;
        } 
        if(String.isBlank(acct.BillingPostalCode))
        {
            errorMessage += ';:Zip/Postal Code' + errorMessage1;
            acct.BillingPostalCode.addError('Zip/Postal Code' +errorMessage1);
            isPass = false;
        }
        if(String.isBlank(ppapa.Region__c))
        {
            errorMessage += ';:Region' + errorMessage1;
            ppapa.Region__c.addError('Region' + errorMessage1);
            isPass = false;
        }
        if(String.isBlank(ppapa.Country__c))
        {
            errorMessage += ';:Country' + errorMessage1;
            ppapa.Country__c.addError('Country' + errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Website))
        {
            errorMessage += ';:Website' + errorMessage1;
            acct.Website.addError('Website' + errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Email_Domain_Used__c))
        {
            errorMessage += ';:Email Domains Used' + errorMessage1;
            acct.Email_Domain_Used__c.addError('Email Domains Used' + errorMessage1);
            isPass = false;
        }/*else if(!Pattern.matches('^@?[\\w\\d\\.\\-]+\\.[\\w\\d\\-]+$', acct.Email_Domain_Used__c.toLowerCase()))
        {
            errorMessage += ';:Email Domains Used must be a valid email domain. Ex @company.com.';
            acct.Email_Domain_Used__c.addError('Please enter a valid email domain. Ex: @company.com.');
            isPass = false;
        }*/
        else if(!(Pattern.matches('^@?[\\w\\d\\.\\-]+\\.[\\w\\d\\-]+$', acct.Email_Domain_Used__c.toLowerCase()) || Pattern.matches(regex, acct.Email_Domain_Used__c.toLowerCase())))
        {
            errorMessage += ';:Email Domains Used must be a valid email domain. Ex @company.com.';
            acct.Email_Domain_Used__c.addError('Please enter a valid email domain. Ex: @company.com.');
            isPass = false;
        }
        else
        {
            //.replace('@','')
            String domain = acct.Email_Domain_Used__c;
            if(domain.contains('@'))
            {
				String[] domainArr = domain.split('@');
                domain = domainArr[1];
                acct.Email_Domain_Used__c = '@' + domain;
            }
            Integer count2 = [select count() from BlacklistedDomains__c where Domain__c =: domain ];
            if(count2 > 0)
            {
                errorMessage += ';:Email Domains Used - Please use the domain of your business email address. If you’ve reached this message in error, please email us at channel@silver-peak.com.';
                acct.Email_Domain_Used__c.addError('Please use the domain of your business email address. If you’ve reached this message in error, please email us at channel@silver-peak.com.');
                isPass = false;
            }
            if(!String.isBlank(dataBinding.get('pcEmail')) && Pattern.matches(regex, dataBinding.get('pcEmail')) && !dataBinding.get('pcEmail').endsWith(acct.Email_Domain_Used__c))
            {
                errorMessage += ';pcEmail:Primary Contact Email Domain must match the company’s domain';
                isPass = false;
            }
            if(!String.isBlank(dataBinding.get('rcEmail')) && Pattern.matches(regex, dataBinding.get('rcEmail')) && !dataBinding.get('rcEmail').endsWith(acct.Email_Domain_Used__c))
            {
                errorMessage += ';rcEmail:Your Email Domain must match the company’s domain';
                isPass = false;
            }
            if(!String.isBlank(dataBinding.get('scEmail')) && Pattern.matches(regex, dataBinding.get('scEmail')) && !dataBinding.get('scEmail').endsWith(acct.Email_Domain_Used__c))
            {
                errorMessage += ';scEmail:Signatory Contact Email Domain must match the company’s domain';
                isPass = false;
            }
            if(!String.isBlank(dataBinding.get('mcEmail')) && Pattern.matches(regex, dataBinding.get('mcEmail')) && !dataBinding.get('mcEmail').endsWith(acct.Email_Domain_Used__c))
            {
                errorMessage += ';mcEmail:Marketing Contact Email Domain must match the company’s domain';
                isPass = false;
            }
        }
        //validation for acct.Phone
        if(String.isBlank(acct.Phone))
        { 
            errorMessage += ';:Company Phone' + errorMessage1;
            acct.Phone.addError('Company Phone' + errorMessage1);
            isPass = false;
        }else if(!acct.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        { 
            errorMessage += ';:Company Phone' + errorMessage2;
            acct.Phone.addError('Company Phone' + errorMessage2);
            isPass = false;
        }
        //validation for acct.Years_in_Business__c
        if(String.isBlank(acct.Years_in_Business__c))
        {
            errorMessage += ';:Years in Business' + errorMessage1;
            acct.Years_in_Business__c.addError('Years in Business' + errorMessage1);
            isPass = false;
        }else if(!acct.Years_in_Business__c.isNumeric() || (Integer.valueOf(acct.Years_in_Business__c) > 999 || Integer.valueOf(acct.Years_in_Business__c)<1 ))
        {
            errorMessage += ';:Years in Business' + errorMessage2 + ' from 1 to 999';
            acct.Years_in_Business__c.addError('Years in Business' + errorMessage2 + ' from 1 to 999');
            isPass = false;
        }
        //validation for Primary Partner Contact
        if(String.isBlank(acct.Are_you_the_primary_partner_contact__c))
        {
            acct.Are_you_the_primary_partner_contact__c.addError('Are you the primary partner contact' + errorMessage1);
            errorMessage += ';:Are you the primary partner contact' + errorMessage1;
        }
        else if(acct.Are_you_the_primary_partner_contact__c == 'No')
        {
            if(String.isBlank(primaryContact.FirstName))
            {
                primaryContact.FirstName.addError('Primary Partner Contact First Name' + errorMessage1);
                errorMessage += ';:Primary Partner Contact First Name' + errorMessage1;
                isPass = false;
            }else if(!primaryContact.FirstName.isAlphaSpace())
            {
                primaryContact.FirstName.addError('Primary Partner Contact First Name' + errorMessage3);
                errorMessage += ';:Primary Partner Contact First Name' + errorMessage3;
                isPass = false;
            }
            if(String.isBlank(dataBinding.get('pcLastName')))
            {
                errorMessage += ';pcLastName:Primary Partner Contact Last Name' + errorMessage1;
                isPass = false;
            }else if(!dataBinding.get('pcLastName').isAlphaSpace())
            {
                errorMessage += ';pcLastName:Primary Partner Contact Last Name' + errorMessage3;
                isPass = false;
            }
            if(String.isBlank(dataBinding.get('pcEmail')))
            {
                errorMessage += ';pcEmail:Primary Partner Contact Email' + errorMessage1;
                isPass = false;
            }else if(!Pattern.matches(regex, dataBinding.get('pcEmail')))
            {
                errorMessage += ';pcEmail:Primary Partner Contact Email is invalid';
                isPass = false;
            }
            if(String.isBlank(primaryContact.Title))
            {
                primaryContact.Title.addError('Primary Partner Contact Job Title' + errorMessage1);
                errorMessage += ';:Primary Partner Contact Job Title' + errorMessage1;
                isPass = false;
            }else if(!primaryContact.Title.isAlphaSpace())
            {
                primaryContact.Title.addError('Primary Partner Contact Job Title' + errorMessage3);
                errorMessage += ';:Primary Partner Contact Job Title' + errorMessage3;
                isPass = false;
            }
            if(String.isBlank(primaryContact.Phone))
            {
                primaryContact.Phone.addError('Primary Partner Contact Telephone' + errorMessage1);
                errorMessage += ';:Primary Partner Contact Telephone' + errorMessage1;
                isPass = false;
            }else if(!primaryContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
            {
                primaryContact.Phone.addError('Primary Partner Contact Telephone' + errorMessage2);
                errorMessage += ';:Primary Partner Contact Telephone' + errorMessage2;
                isPass = false;
            }
            if(String.isBlank(primaryContact.Business_Function__c))
            {
                primaryContact.Business_Function__c.addError('Primary Partner Contact Business Function' + errorMessage1);
                errorMessage += ';:Primary Partner Contact Business Function' + errorMessage1;
                isPass = false;
            }
            if(String.isBlank(primaryContact.Job_Role__c))
            {
                primaryContact.Job_Role__c.addError('Primary Partner Contact Job Role' + errorMessage1);
                errorMessage += ';:Primary Partner Contact Job Role' + errorMessage1;
                isPass = false;
            }
        }
        
        //validation for Register Contact
        if(String.isBlank(registerContact.FirstName))
        {
            registerContact.FirstName.addError('Your First Name' + errorMessage1);
            errorMessage += ';:Your First Name' + errorMessage1;
            isPass = false;
        }else if(!registerContact.FirstName.isAlphaSpace())
        {
            primaryContact.FirstName.addError('Your First Name' + errorMessage3);
            errorMessage += ';:Your First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('rcLastName')))
        {
            errorMessage += ';rcLastName:Your Last Name' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('rcLastName').isAlphaSpace())
        {
            errorMessage += ';rcLastName:Your Last Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('rcEmail')))
        {
            errorMessage += ';rcEmail:Your Email' + errorMessage1;
            isPass = false;
        }else if(!Pattern.matches(regex, dataBinding.get('rcEmail')))
        {
            errorMessage += ';rcEmail:Your Email is invalid';
            isPass = false;
        }
        if(String.isBlank(registerContact.Title))
        {
            registerContact.Title.addError('Your Job Title' + errorMessage1);
            errorMessage += ';:Your Job Title' + errorMessage1;
            isPass = false;
        }else if(!registerContact.Title.isAlphaSpace())
        {
            registerContact.Title.addError('Your Job Title' + errorMessage3);
            errorMessage += ';:Your Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(registerContact.Phone))
        {
            registerContact.Phone.addError('Your Telephone' + errorMessage1);
            errorMessage += ';:Your Telephone' + errorMessage1;
            isPass = false;
        }else if(!registerContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            registerContact.Phone.addError('Your Telephone' + errorMessage2);
            errorMessage += ';:Your Telephone' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(registerContact.Business_Function__c))
        {
            registerContact.Business_Function__c.addError('Your Business Function' + errorMessage1);
            errorMessage += ';:Your Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(registerContact.Job_Role__c))
        {
            registerContact.Job_Role__c.addError('Your Job Role' + errorMessage1);
            errorMessage += ';:Your Job Role' + errorMessage1;
            isPass = false;
        }
        //validation for Partner Signatory Contact
        if(String.isBlank(signatoryContact.FirstName))
        {
            signatoryContact.FirstName.addError('Partner Signatory Contact First Name' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact First Name' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.FirstName.isAlphaSpace())
        {
            signatoryContact.FirstName.addError('Partner Signatory Contact First Name' + errorMessage3);
            errorMessage += ';:Partner Signatory Contact First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('scLastName')))
        {
            errorMessage += ';scLastName:Partner Signatory Contact Last Name' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('scLastName').isAlphaSpace())
        {
            errorMessage += ';scLastName:Partner Signatory Contact Last Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('scEmail')))
        {
            errorMessage += ';scEmail:Partner Signatory Contact Email' + errorMessage1;
            isPass = false;
        }else if(!Pattern.matches(regex, dataBinding.get('scEmail')))
        {
            errorMessage += ';scEmail:Partner Signatory Contact Email is invalid';
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Title))
        {
            signatoryContact.Title.addError('Partner Signatory Contact Job Title' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Job Title' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.Title.isAlphaSpace())
        {
            signatoryContact.Title.addError('Partner Signatory Contact Job Title' + errorMessage3);
            errorMessage += ';:Partner Signatory Contact Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Phone))
        {
            signatoryContact.Phone.addError('Partner Signatory Contact Contact Telephone' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Telephone' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            signatoryContact.Phone.addError('Partner Signatory Contact Contact Telephone' + errorMessage2);
            errorMessage += ';:Partner Signatory Contact Telephone' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Business_Function__c))
        {
            signatoryContact.Business_Function__c.addError('Partner Signatory Contact Business Function' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Job_Role__c))
        {
            signatoryContact.Job_Role__c.addError('Partner Signatory Contact Job Role' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Job Role' + errorMessage1;
            isPass = false;
        }
        
        //validation for Partner Marketing Contact
        if(String.isBlank(marketingContact.FirstName))
        {
            marketingContact.FirstName.addError('Partner Marketing Contact First Name' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact First Name' + errorMessage1;
            isPass = false;
        }else if(!marketingContact.FirstName.isAlphaSpace())
        {
            marketingContact.FirstName.addError('Partner Marketing Contact First Name' + errorMessage3);
            errorMessage += ';:Partner Marketing Contact First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('mcLastName')))
        {
            errorMessage += ';mcLastName: Partner Marketing Contact Last Name' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('mcLastName').isAlphaSpace())
        {
            errorMessage += ';mcLastName: Partner Marketing Contact Last Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('mcEmail')))
        {
            errorMessage += ';mcEmail:Partner Marketing Contact Email' + errorMessage1;
            isPass = false;
        }else if(!Pattern.matches(regex, dataBinding.get('mcEmail')))
        {
            errorMessage += ';mcEmail:Partner Marketing Contact Email invalid';
            isPass = false;
        }
        if(String.isBlank(marketingContact.Title))
        {
            marketingContact.Title.addError('Partner Marketing Contact Job Title' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Job Title' + errorMessage1;
            isPass = false;
        }
        else if(!marketingContact.Title.isAlphaSpace())
        {
            marketingContact.Title.addError('Partner Marketing Contact Job Title' + errorMessage3);
            errorMessage += ';:Partner Marketing Contact Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(marketingContact.Phone))
        {
            marketingContact.Phone.addError('Partner Marketing Contact Contact Telephone' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Telephone' + errorMessage1;
            isPass = false;
        }
        else if(!marketingContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            marketingContact.Phone.addError('Partner Marketing Contact Contact Telephone' + errorMessage2);
            errorMessage += ';:Partner Marketing Contact Telephone' + errorMessage2;
            isPass = false;
        }        
        if(String.isBlank(marketingContact.Business_Function__c))
        {
            marketingContact.Business_Function__c.addError('Partner Marketing Contact Business Function' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(marketingContact.Job_Role__c))
        {
            marketingContact.Job_Role__c.addError('Partner Marketing Contact Job Role' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Job Role' + errorMessage1;
            isPass = false;
        }
        // validation for other
        if(String.isBlank(acct.Silver_Peak_oppo_pend__c))
        {
            errorMessage += ';:Silver Peak opportunity pending' + errorMessage1;
            acct.Silver_Peak_oppo_pend__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.total_annual_sales_revenues_last_year__c))
        {
            errorMessage += ';:Total annual revenues last year' + errorMessage1;
            acct.total_annual_sales_revenues_last_year__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Number_of_employees_in_your_organization__c))
        {
            errorMessage += ';:Number of employees in your organization' + errorMessage1;
            acct.Number_of_employees_in_your_organization__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('outside')))
        {
            errorMessage += ';outside:Outside Sales' + errorMessage1;
            acct.Number_of_sales_professionals_in_org__c.addError('Outside Sales' + errorMessage1);
            isPass = false;
        }else if(!dataBinding.get('outside').isNumeric())
        {
            errorMessage += ';outside:Outside Sales' + errorMessage2;
            acct.Number_of_sales_professionals_in_org__c.addError('Outside Sales' + errorMessage2);
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('inside')))
        {
            errorMessage += ';inside:Inside Sales' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('inside').isNumeric())
        {
            errorMessage += ';inside:Inside Sales' + errorMessage2;
            isPass = false;
        }
        /*if(String.isBlank(dataBinding.get('engineers')) || !dataBinding.get('engineers').isNumeric())
        {
            errorMessage += ';engineers:Sales Engineers' + errorMessage1 + errorMessage2;
            isPass = false;
        }*/
        if(String.isBlank(dataBinding.get('engineers')))
        {
            errorMessage += ';engineers:Sales Engineers' + errorMessage1;
            isPass = false;
        } else if(!dataBinding.get('engineers').isNumeric())
        {
            errorMessage += ';engineers:Sales Engineers' + errorMessage2;
            isPass = false;
        }
        //validation for acct.TOP_3_industries__c
        if(String.isBlank(acct.TOP_3_industries__c) || (top3.length() - top3.remove(';').length()) != 2)
        {
            errorMessage += ';:TOP 3 industries' + errorMessage1 + ' and must select 3 selections';
            acct.TOP_3_industries__c.addError('TOP 3 industries' + errorMessage1 + ' and must select 3 selections');
            isPass = false;
        }
        //validation for acct.business_is_Product_Sales__c
        Boolean salesMark = true;
        if(String.isBlank(dataBinding.get('product')))
        {
            salesMark = false;
            errorMessage += ';product:Product Sales' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('product').isNumeric())
        {
            salesMark = false;
            errorMessage += ';product:Product Sales' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('services')))
        {
            salesMark = false;
            errorMessage += ';services:Services Sales' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('services').isNumeric())
        {
            salesMark = false;
            errorMessage += ';services:Services Sales' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(dataBinding.get('consulting')))
        {
            salesMark = false;
            errorMessage += ';consulting:Consulting Sales' + errorMessage1;
            isPass = false;
        }else if(!dataBinding.get('consulting').isNumeric())
        {
            salesMark = false;
            errorMessage += ';consulting:Consulting Sales' + errorMessage2;
            isPass = false;
        }
        if(salesMark && (Integer.valueOf(dataBinding.get('product')) + Integer.valueOf(dataBinding.get('services')) + Integer.valueOf(dataBinding.get('consulting')) != 100))
        {
            errorMessage += ';product:Product Sales (Product + Service + Consulting must equal 100%);services:Service Sales (Product + Service + Consulting must equal 100%);consulting:Consulting Sales (Product + Service + Consulting must equal 100%)';
            isPass = false;
        }
        if(String.isBlank(acct.Own_brand_of_professional_services__c))
        {
            errorMessage += ';:Own brand of professional services' + errorMessage1;
            acct.Own_brand_of_professional_services__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Provide_technical_support__c))
        {
            errorMessage += ';:Provide technical support' + errorMessage1;
            acct.Provide_technical_support__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Primary_target_market_size__c))
        {
            errorMessage += ';:Primary target market size' + errorMessage1;
            acct.Primary_target_market_size__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Marketting_Oferrings__c))
        {            
            errorMessage += ';:Marketing Oferrings' + errorMessage1;
            acct.Marketting_Oferrings__c.addError(errorMessage1);
            isPass = false;
        }
        if(String.isBlank(acct.Are_you_an_authorized_partner_of__c))
        {
            errorMessage += ';:Are you an authorized partner partner' + errorMessage1;
            acct.Are_you_an_authorized_partner_of__c.addError(errorMessage1);
            isPass = false;
        }
        //validation for acct.Distributor_of_Choice__c
        if(String.isBlank(acct.Distributor_of_Choice__c))
        {
            errorMessage += ';:Distributor of Choice' + errorMessage1;
            acct.Distributor_of_Choice__c.addError(errorMessage1);
            isPass = false;
        }else if(!acct.Distributor_of_Choice__c.isAlphaSpace())
        {
            errorMessage += ';:Distributor of Choice' + errorMessage3;
            acct.Distributor_of_Choice__c.addError(errorMessage3);
            isPass = false;
        }
        if(String.isBlank(acct.Integrate_cloudsolutions_with_vendors__c))
        {
            errorMessage += ';:Integrate cloud solutions with vendors' + errorMessage1;
            acct.Integrate_cloudsolutions_with_vendors__c.addError(errorMessage1);
            isPass = false;
        }
        else if(acct.Integrate_cloudsolutions_with_vendors__c == 'Yes')
        {
            if(String.isBlank(acct.Please_Name_the_Vendors__c))
            {
                errorMessage += ';:Which vendor you integrate cloud solutions with' + errorMessage1;
                acct.Please_Name_the_Vendors__c.addError(errorMessage1);
                isPass = false;
            } 
        }
        //validation for acct.Tax_ID_Number__c
        if(String.isBlank(acct.Tax_ID_Number__c))
        {
            errorMessage += ';:Tax ID Number' + errorMessage1;
            acct.Tax_ID_Number__c.addError('Tax ID Number' + errorMessage1);
            isPass = false;
        }
        errorMessage.removeStart(';');
        return isPass;
    }
    public void submitToProcess(Id objId)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(objId);
        Approval.ProcessResult result = Approval.Process(req);
    }
    
    private Id getRecordTypeId(String recordTypeName)
    {
        Map<String, Schema.RecordTypeInfo> recordTypes = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(recordTypes.get(recordTypeName) != null)
        {
            Id recordTypeId = recordTypes.get(recordTypeName).getRecordTypeId();
            return recordTypeId;
        }
        else
        {
            return null;
        }
    }
    
    private void fillAddress(Contact ct, Account acct)
    {
        ct.MailingCountry = acct.BillingCountry;
        ct.MailingState = acct.BillingState;
        ct.MailingCity = acct.BillingCity;
        ct.MailingPostalCode = acct.BillingPostalCode;
        ct.MailingStreet = acct.BillingStreet;
    }
    
    private Boolean existingAccount(Account acct)
    {
        acct.Email_Domain_Used__c = acct.Email_Domain_Used__c.startsWith('@') ? acct.Email_Domain_Used__c : '@' + acct.Email_Domain_Used__c;
        String domainPattern = '%' + acct.Email_Domain_Used__c + '%';
        List<Account> duplicateDomainAccts = [select Id, Email_Domain_Used__c, ParentId from Account where Email_Domain_Used__c like :domainPattern and Partner_Application_Status__c !='Denied' ORDER BY ParentId NULLS FIRST LIMIT 1];
        if(duplicateDomainAccts.size() > 0)
        {
            Map<string, Id> domain2Id = new Map<String, Id>();
            for(Account duplicate : duplicateDomainAccts)
            {
                for(String domain : duplicate.Email_Domain_Used__c.split('[;,\\s]'))
                {
                    domain2Id.put(domain, duplicate.Id);
                }
            }
            if(domain2Id.keySet().contains(acct.Email_Domain_Used__c))
            {
                acct.Id = domain2Id.get(acct.Email_Domain_Used__c);
                return true;
            }
        }
        return false;
    }
    
    private Information_Card__c populateInfoCard(Account acct)
    {
        Information_Card__c ic = new Information_Card__c();
        ic.Number_of_Matching_Accounts__c = [select count() from Account where Email_Domain_Used__c like :acct.Email_Domain_Used__c and Partner_Application_Status__c !='Denied'];
        ic.business_is_Consulting_Sales__c = acct.business_is_Consulting_Sales__c;
        ic.business_is_Product_Sales__c = acct.business_is_Product_Sales__c;
        ic.business_is_Services_Sales__c = acct.business_is_Services_Sales__c;
        ic.Account__c = acct.Id;
        ic.Account_CAM__c = [Select Id, CAM__c from Account where Id =: acct.Id].CAM__c;
        ic.Are_you_an_authorized_partner_of__c = acct.Are_you_an_authorized_partner_of__c;
        ic.Billing_City__c = acct.BillingCity;
        ic.Billing_Country__c = acct.BillingCountry;
        ic.Billing_Postal_Code__c = acct.BillingPostalCode;
        ic.Billing_State__c = acct.BillingState;
        ic.Billing_Street__c = acct.BillingStreet;
        ic.Company_Name__c = acct.Name;
        ic.Distributor_of_Choice__c = acct.Distributor_of_Choice__c;
        ic.Email_Domain_Used__c = acct.Email_Domain_Used__c;
        ic.Integrate_Cloud_Solutions_with_Vendors__c = acct.Integrate_cloudsolutions_with_vendors__c;
        ic.Marketing_Offerings__c = acct.Marketting_Oferrings__c;
        ic.Number_of_employees_in_your_organization__c = acct.Number_of_employees_in_your_organization__c;
        ic.Own_brand_of_professional_services__c = acct.Own_brand_of_professional_services__c;
        ic.Phone__c = acct.Phone;
        ic.Please_Name_the_Vendors__c = acct.Please_Name_the_Vendors__c;
        ic.Primary_target_market_size__c = acct.Primary_target_market_size__c;
        ic.Professionals_in_your_org_Inside_Sales__c = acct.Professionals_in_your_org_Inside_Sales__c;
        ic.Number_of_sales_professionals_in_org__c = acct.Number_of_sales_professionals_in_org__c;
        ic.Professionals_in_org__c = acct.Professionals_in_org__c;
        ic.Provide_technical_support__c = acct.Provide_technical_support__c;
        ic.Region__c = acct.Region__c;
        ic.Silver_Peak_opportunity_pending__c = acct.Silver_Peak_oppo_pend__c;
        ic.Tax_ID_Number__c = acct.Tax_ID_Number__c;
        ic.TOP_3_industries__c = acct.TOP_3_industries__c;
        ic.Total_annual_sales_revenues_last_year__c = acct.total_annual_sales_revenues_last_year__c;
        ic.Website__c = acct.Website;
        ic.Years_in_Business__c = acct.Years_in_Business__c;
        return ic;
    }
    
    private void insertContacts(sObject obj)
    {
        List<Contact> conList = new List<Contact>();
        primaryContact.Primary_Account_Contact__c = true;
        primaryContact.LeadSource = 'Partner Portal';//
        primaryContact.Id = null;
        conList.add(primaryContact);
        if(signatoryContact.Email != primaryContact.Email)
        {
            signatoryContact.LeadSource = 'Partner Portal';//
            signatoryContact.Id = null;
            conList.add(signatoryContact);
        }
        if((marketingContact.Email != primaryContact.Email) && (marketingContact.Email != signatoryContact.Email))
        {
            marketingContact.LeadSource = 'Partner Portal';//
            marketingContact.Id = null;
            conList.add(marketingContact);
        }
        if((registerContact.Email != primaryContact.Email) && (registerContact.Email != signatoryContact.Email) && (registerContact.Email != marketingContact.Email))
        {
            registerContact.LeadSource = 'Partner Portal';
            registerContact.Id = null;
            conList.add(registerContact);
        }
        if(conList.size() > 0)
        {
            if(obj instanceof Information_Card__c)
            {
                for(Contact con : conList)
                {
                    con.Info_Card__c = obj.Id;
                }
            }
            else if(obj instanceof Account)
            {
                for(Contact con : conList)
                {
                    con.AccountId = obj.Id;
                }
            }
        }
        insert conList;
    }
}