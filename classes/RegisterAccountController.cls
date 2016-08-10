/*
 * Controller of VF page BecomePartner
 *@changelog
 *21APR2016 - removed commented email domains used validation and updated error messaging
 */
public class RegisterAccountController 
{
    public Account acct { get; set; }
    public Boolean succeeded { get; set; }
    public Partner_Portal_Account_Profile_Address__c ppapa { get; set; } //just for data binding of the region/country fields
    public Contact  primaryContact { get; set; }
    public Contact  signatoryContact { get; set; }
    public Contact  marketingContact { get; set; }
    public String accountName { get; set; }
    public String pcLastName { get; set; }
    public String scLastName { get; set; }
    public String mcLastName { get; set; }
    public String errorMessage { get; set; }
    public Map<String,String> dataBinding { get; set; }
    private List<Contact> conList = new List<Contact>();

    public RegisterAccountController(ApexPages.StandardController stdController)
    {
        succeeded = false;
        ppapa = new Partner_Portal_Account_Profile_Address__c();
        primaryContact = new Contact();
        signatoryContact = new Contact();
        marketingContact = new Contact();
        errorMessage = '';
        dataBinding = new Map<String,String>{
            'pcEmail' => '',
            'scEmail' => '',
            'mcEmail' => '',
            'outside' => '',
            'inside' => '',
            'engineers' => '',
            'product' => '',
            'services' => '',
            'consulting' => ''
        };
        if(stdController != null)
        {
            this.acct = (Account)StdController.getRecord();
        }
    }

    public PageReference insertAccount()
    {
        errorMessage = '';
        if(validateSucceeded() == false)
        {
            return null;
        }
        if(!String.isBlank(ppapa.Region__c))
        {
            acct.Region__c = (String) ppapa.Region__c;
        }
        if(!String.isBlank(acct.Region__c))
        {
            acct.BillingCountry = (String) ppapa.Country__c;
        }
        acct.Name = accountName;
        primaryContact.LastName = pcLastName;
        signatoryContact.LastName = scLastName;
        marketingContact.LastName = mcLastName;
        primaryContact.Email = dataBinding.get('pcEmail');
        signatoryContact.Email = dataBinding.get('scEmail');
        marketingContact.Email = dataBinding.get('mcEmail');
        fillAddress(primaryContact, acct);
        fillAddress(marketingContact, acct);
        fillAddress(signatoryContact, acct);
        acct.Number_of_sales_professionals_in_org__c = Integer.valueOf(dataBinding.get('outside'));
        acct.Professionals_in_your_org_Inside_Sales__c = Integer.valueOf(dataBinding.get('inside'));
        acct.Professionals_in_org__c = Integer.valueOf(dataBinding.get('engineers'));
        acct.business_is_Product_Sales__c = Integer.valueOf(dataBinding.get('product'));
        acct.business_is_Services_Sales__c = Integer.valueOf(dataBinding.get('services'));
        acct.business_is_Consulting_Sales__c = Integer.valueOf(dataBinding.get('consulting'));
        acct.Primary_Partner_Contact_E_Mail_Address__c = primaryContact.Email;
        //setting account field for email template use
        //acct.Full_Name_Primary_Partner_Contact__c = primaryContact.FirstName + ' ' + primaryContact.LastName;
        acct.Type = 'Partner';
        acct.Partner_Application_Status__c = 'Pending';
        acct.RecordTypeId = getRecordTypeId('Resellers');

        try
        {
            insert acct;
            Account acct1 = [select Id, Name, Patch__c from Account where Id =: acct.Id limit 1];
            List<Patch__c> patch = [select Id, CSM__c from Patch__c where Id =: acct1.Patch__c limit 1];
            if(patch.size() > 0)
            {
                acct1.CAM__c = patch[0].CSM__c;
                //adding owner assignment
                acct1.OwnerId = patch[0].CSM__c;
                update acct1;   
            }
            primaryContact.AccountId = acct1.Id;
            primaryContact.Primary_Account_Contact__c = true;
            conList.add(primaryContact);
            if(signatoryContact.Email != primaryContact.Email)
            {
                signatoryContact.AccountId = acct1.Id;
                conList.add(signatoryContact);
                acct1.Partner_Signatory_Contact_E_Mail_Address__c = signatoryContact.Email;
            }
            if((marketingContact.Email != primaryContact.Email) && (marketingContact.Email != signatoryContact.Email))
            {
                marketingContact.AccountId = acct1.Id;
                conList.add(marketingContact);
                acct1.Partner_Marketing_Contact_E_Mail_Address__c = marketingContact.Email;
            }
            if(conList.size() > 0)
            {
                insert conList;
                acct1.PrimaryPartnerContact__c = primaryContact.Id;
                acct1.SignatoryPartnerContact__c = signatoryContact.Id;
                acct1.MarketingPartnerContact__c = marketingContact.Id;
            }
            update acct1;
            succeeded = true; 
            submitAccout(acct1);            
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
        }
        return null;
    }
    private Boolean validateSucceeded(){
        String errorMessage1 = ' cannot be blank';
        String errorMessage2 = ' must contain only numbers';
        String errorMessage3 = ' must contain only letters';
        String errorMessage4 = errorMessage1 + ' and' + errorMessage3;
        String top3 = acct.TOP_3_industries__c;
        Boolean isPass = true;
        String regex = '([a-zA-Z0-9_\\-\\.]+)@(((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3}))';
        if(String.isBlank(accountName))
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
        }else if(!Pattern.matches('^@?[\\w\\d\\.\\-]+\\.[\\w\\d\\-]+$', acct.Email_Domain_Used__c.toLowerCase()))
        {
            errorMessage += ';:Email Domains Used must be a valid email domain. Ex @company.com.';
            acct.Email_Domain_Used__c.addError('Please enter a valid email domain. Ex: @company.com.');
            isPass = false;
        }
        else
        {
            acct.Email_Domain_Used__c = acct.Email_Domain_Used__c.startsWith('@') ? acct.Email_Domain_Used__c : '@' + acct.Email_Domain_Used__c;
            String domainPattern = '%' + acct.Email_Domain_Used__c + '%';
            List<Account> duplicateDomainAccts = [select Email_Domain_Used__c from Account where Email_Domain_Used__c like :domainPattern and Partner_Application_Status__c !='Denied'];
            if(duplicateDomainAccts.size() > 0)
            {
                Set<String> similarDomains = new Set<String>();
                for(Account duplicate : duplicateDomainAccts)
                {
                    similarDomains.addAll(duplicate.Email_Domain_Used__c.split('[;,\\s]'));
                }
                if(similarDomains.contains(acct.Email_Domain_Used__c))
                {
                    errorMessage += ';:Email Domains Used Duplicate domain found';
                    acct.Email_Domain_Used__c.addError('Duplicate domain found. If your company is an existing Silver Peak partner, please request a login.');
                    isPass = false;
                }
            }
            String domain = acct.Email_Domain_Used__c.replace('@','');
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
        /*if(String.isBlank(acct.Years_in_Business__c) || !acct.Years_in_Business__c.isNumeric() || (Integer.valueOf(acct.Years_in_Business__c) > 999 || Integer.valueOf(acct.Years_in_Business__c)<1 ))
        {
            errorMessage += ';:Years in Business' + errorMessage1 + errorMessage2 + ' from 1 to 999';
            acct.Years_in_Business__c.addError('Years in Business' + errorMessage1 + errorMessage2 + ' from 1 to 999');
            isPass = false;
        }*/
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
        Boolean firstNamePcMark = false;
        Boolean titlePcMark = false;
        Boolean phonePcMark = false;
        Boolean functionPcMark = false;
        Boolean rolePcMark = false;
        if(String.isBlank(primaryContact.FirstName))
        {
            firstNamePcMark = true;
            primaryContact.FirstName.addError('Primary Partner Contact First Name' + errorMessage1);
            errorMessage += ';:Primary Partner Contact First Name' + errorMessage1;
            isPass = false;
        }else if(!primaryContact.FirstName.isAlphaSpace())
        {
            firstNamePcMark = true;
            primaryContact.FirstName.addError('Primary Partner Contact First Name' + errorMessage3);
            errorMessage += ';:Primary Partner Contact First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(pcLastName))
        {
            errorMessage += ';pcLastName:Primary Partner Contact Last Name' + errorMessage1;
            isPass = false;
        }else if(!pcLastName.isAlphaSpace())
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
            errorMessage += ';pcEmail:Primary Partner Contact Email is illegal';
            isPass = false;
        }
        if(String.isBlank(primaryContact.Title))
        {
            titlePcMark = true;
            primaryContact.Title.addError('Primary Partner Contact Job Title' + errorMessage1);
            errorMessage += ';:Primary Partner Contact Job Title' + errorMessage1;
            isPass = false;
        }else if(!primaryContact.Title.isAlphaSpace())
        {
            titlePcMark = true;
            primaryContact.Title.addError('Primary Partner Contact Job Title' + errorMessage3);
            errorMessage += ';:Primary Partner Contact Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(primaryContact.Phone))
        {
            phonePcMark = true;
            primaryContact.Phone.addError('Primary Partner Contact Telephone' + errorMessage1);
            errorMessage += ';:Primary Partner Contact Telephone' + errorMessage1;
            isPass = false;
        }else if(!primaryContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            phonePcMark = true;
            primaryContact.Phone.addError('Primary Partner Contact Telephone' + errorMessage2);
            errorMessage += ';:Primary Partner Contact Telephone' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(primaryContact.Business_Function__c))
        {
            functionPcMark = true;
            primaryContact.Business_Function__c.addError('Primary Partner Contact Business Function' + errorMessage1);
            errorMessage += ';:Primary Partner Contact Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(primaryContact.Job_Role__c))
        {
            rolePcMark = true;
            primaryContact.Job_Role__c.addError('Primary Partner Contact Job Role' + errorMessage1);
            errorMessage += ';:Primary Partner Contact Job Role' + errorMessage1;
            isPass = false;
        }
        //validation for Partner Signatory Contact
        Boolean firstNameScMark = false;
        Boolean titleScMark = false;
        Boolean phoneScMark = false;
        Boolean functionScMark = false;
        Boolean roleScMark = false;
        if(String.isBlank(signatoryContact.FirstName))
        {
            firstNameScMark = true;
            signatoryContact.FirstName.addError('Partner Signatory Contact First Name' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact First Name' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.FirstName.isAlphaSpace())
        {
            firstNameScMark = true;
            signatoryContact.FirstName.addError('Partner Signatory Contact First Name' + errorMessage3);
            errorMessage += ';:Partner Signatory Contact First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(scLastName))
        {
            errorMessage += ';scLastName:Partner Signatory Contact Last Name' + errorMessage1;
            isPass = false;
        }else if(!scLastName.isAlphaSpace())
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
            errorMessage += ';scEmail:Partner Signatory Contact Email is illegal';
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Title))
        {
            titleScMark = true;
            signatoryContact.Title.addError('Partner Signatory Contact Job Title' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Job Title' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.Title.isAlphaSpace())
        {
            titleScMark = true;
            signatoryContact.Title.addError('Partner Signatory Contact Job Title' + errorMessage3);
            errorMessage += ';:Partner Signatory Contact Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Phone))
        {
            phoneScMark = true;
            signatoryContact.Phone.addError('Partner Signatory Contact Contact Telephone' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Telephone' + errorMessage1;
            isPass = false;
        }else if(!signatoryContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            phoneScMark = true;
            signatoryContact.Phone.addError('Partner Signatory Contact Contact Telephone' + errorMessage2);
            errorMessage += ';:Partner Signatory Contact Telephone' + errorMessage2;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Business_Function__c))
        {
            functionScMark = true;
            signatoryContact.Business_Function__c.addError('Partner Signatory Contact Business Function' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(signatoryContact.Job_Role__c))
        {
            roleScMark = true;
            signatoryContact.Job_Role__c.addError('Partner Signatory Contact Job Role' + errorMessage1);
            errorMessage += ';:Partner Signatory Contact Job Role' + errorMessage1;
            isPass = false;
        }
        //validation for Partner Marketing Contact
        Boolean firstNameMcMark = false;
        Boolean titleMcMark = false;
        Boolean phoneMcMark = false;
        Boolean functionMcMark = false;
        Boolean roleMcMark = false;
        if(String.isBlank(marketingContact.FirstName))
        {
            firstNameMcMark = true;
            marketingContact.FirstName.addError('First Name' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact First Name' + errorMessage1;
            isPass = false;
        }else if(!marketingContact.FirstName.isAlphaSpace())
        {
            firstNameMcMark = true;
            marketingContact.FirstName.addError('First Name' + errorMessage3);
            errorMessage += ';:Partner Marketing Contact First Name' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(mcLastName))
        {
            errorMessage += ';mcLastName: Partner Marketing Contact Last Name' + errorMessage1;
            isPass = false;
        }else if(!mcLastName.isAlphaSpace())
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
            errorMessage += ';mcEmail:Partner Marketing Contact Email Illegal';
            isPass = false;
        }
        if(String.isBlank(marketingContact.Title))
        {
            titleMcMark = true;
            marketingContact.Title.addError('Job Title' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Job Title' + errorMessage1;
            isPass = false;
        }else if(!marketingContact.Title.isAlphaSpace())
        {
            titleMcMark = true;
            marketingContact.Title.addError('Job Title' + errorMessage3);
            errorMessage += ';:Partner Marketing Contact Job Title' + errorMessage3;
            isPass = false;
        }
        if(String.isBlank(marketingContact.Phone))
        {
            phoneMcMark = true;
            marketingContact.Phone.addError('Contact Telephone' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Telephone' + errorMessage1;
            isPass = false;
        }else if(!marketingContact.Phone.remove('(').remove(')').remove('-').remove(' ').isNumeric())
        {
            phoneMcMark = true;
            marketingContact.Phone.addError('Contact Telephone' + errorMessage2);
            errorMessage += ';:Partner Marketing Contact Telephone' + errorMessage2;
            isPass = false;
        }        
        if(String.isBlank(marketingContact.Business_Function__c))
        {
            functionMcMark = true;
            marketingContact.Business_Function__c.addError('Business Function' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Business Function' + errorMessage1;
            isPass = false;
        }
        if(String.isBlank(marketingContact.Job_Role__c))
        {
            roleMcMark = true;
            marketingContact.Job_Role__c.addError('Job Role' + errorMessage1);
            errorMessage += ';:Partner Marketing Contact Job Role' + errorMessage1;
            isPass = false;
        }
        /*if(firstNamePcMark)
        {
            errorMessage += ';:Primary Partner Contact First Name' + errorMessage4;
        }
        if(firstNameScMark)
        {
            errorMessage += ';:Partner Signatory Contact First Name' + errorMessage4;
        }
        if(firstNameMcMark)
        {
            errorMessage += ';:Partner Marketing Contact First Name' + errorMessage4;
        }
        if(titlePcMark)
        {
            errorMessage += ';:Primary Partner Contact Job Title' + errorMessage4;
        }
        if(titleScMark)
        {
            errorMessage += ';:Partner Signatory Contact Job Title' + errorMessage4;
        }
        if(titleMcMark)
        {
            errorMessage += ';:Partner Marketing Contact Job Title' + errorMessage4;
        }
        if(phonePcMark)
        {
            errorMessage += ';:Primary Partner Contact Telephone' + errorMessage1 + errorMessage2;
        }
        if(phoneScMark)
        {
            errorMessage += ';:Partner Signatory Contact Telephone' + errorMessage1 + errorMessage2;
        }
        if(phoneMcMark)
        {
            errorMessage += ';:Partner Marketing Contact Telephone' + errorMessage1 + errorMessage2;
        }
        if(functionPcMark)
        {
            errorMessage += ';:Primary Partner Contact Business Function' + errorMessage4;
        }
        if(functionScMark)
        {
            errorMessage += ';:Partner Signatory Contact Business Function' + errorMessage4;
        }
        if(functionMcMark)
        {
            errorMessage += ';:Partner Marketing Contact Business Function' + errorMessage4;
        }
        if(rolePcMark)
        {
            errorMessage += ';:Primary Partner Contact Job Role' + errorMessage1;
        }
        if(roleScMark)
        {
            errorMessage += ';:Partner Signatory Contact Job Role' + errorMessage1;
        }
        if(roleMcMark)
        {
            errorMessage += ';:Partner Marketing Contact Job Role' + errorMessage1;
        }*/
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
        }else if(!acct.Tax_ID_Number__c.isNumeric())
        {
            errorMessage += ';:Tax ID Number' + errorMessage2;
            acct.Tax_ID_Number__c.addError('Tax ID Number' + errorMessage2);
            isPass = false;
        }
        errorMessage.removeStart(';');
        return isPass;
    }
    public void submitAccout(Account newAccount)
    {
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(newAccount.Id);
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
}