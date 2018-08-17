/*
* Controller of page SelfRegister, SelfRegisterCase
*/
public class SelfRegisterController 
{
    public SelfRegisterController()
    {
        succeeded = false;
        Subject = 'Request Support Center Access';
    }
    
    public String FullName { get; set; }
    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String PhoneNumber { get; set; }
    public String CompanyName { get; set; }
    public String ContactCountry { get; set; }
    public String Email { get; set; }
    public String SerialNumber { get; set; }
    public String Subject { get; set; }
    public Boolean Succeeded { get; set; }
    
    public PageReference submit()
    {
        if(!isValid())
        {
            return null;
        }
        parseContactName(FullName);
        Contact contact = findContact(Email);
        Asset asset = findAsset(SerialNumber);
        if(asset == null || contact == null)
        {
            try
            {
                if(contact == null && asset == null)
                {
                    List<Account> accs = [select Id from Account where Name='Email Support Contacts' limit 1];
                    if(accs.size() > 0)
                    {
                        contact = createContact(accs[0].Id);
                        createCase(contact, asset);
                    }
                }
                else if(contact == null && asset != null)
                {
                    contact = createContact(asset.AccountId);
                    SendNotificationEmailToShipmentTeam(contact);
                    //grantTheContact(contact);
                }
                else if(contact != null && asset == null)
                {
                    createCase(contact, asset);
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Your request was submitted.'));
                Succeeded = true;
            }
            catch(DmlException ex)
            {
                ApexPages.addMessages(ex);
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Error occured on registering, please contact the admin.'));
            }
        }
        else
        {
            try
            {
                //grantTheContact(contact);
                SendNotificationEmailToShipmentTeam(contact);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Registration succeeded.'));
                Succeeded = true;
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Error occured on registering, please contact the admin.'));
            }
        }
        return null;
    }
    
    private Boolean isValid()
    {
        Boolean result = true;
        if(FullName == null || FullName == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Name: Value is required.'));
        }
        if(Email == null || Email == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Email: Value is required.'));
        }
        if(PhoneNumber == null || PhoneNumber == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Phone: Value is required.'));
        }
        if(ContactCountry == null || ContactCountry == '--None--')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Country: Value is required.'));
        } 
        if(CompanyName == null || CompanyName == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Company: Value is required.'));
        }
        if(SerialNumber == null || SerialNumber == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Serial Number: Value is required.'));
        }
        if(Subject == null || Subject == '')
        {
            result = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Subject: Value is required.'));
        }
        return result;
    }
    
    //locates a contact with the specified email. One and only one contact should be found.
    private Contact findContact(String emailAddress)
    {
        List<Contact> cts = [select Id, AccountId, CanAllowPortalSelfReg from Contact where Email=:emailAddress];
        if(cts.size() == 1)
        {
            return cts[0];
        }
        else
        {
            return null;
        }
    }
    private static boolean SendNotificationEmailToShipmentTeam(Contact contactInfo)
    {
        if(contactInfo!=null)
        {
            Contact result=[Select Id, FirstName,LastName,Account.Name from Contact where Id=:contactInfo.Id];
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Action required: Request Support Access Check Self Registration box.');
            string datastring='Please grant customer portal access to this contact: ' + result.firstName+' '+ result.LastName +' on this account: '+ result.Account.Name;
            mail.setPlainTextBody(datastring);
            mail.setToAddresses(getMailAddresses());
            mail.setCCAddresses( new String[]{'notifications@silver-peak.com'});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        return true;
    }
    
    private static List<String> getMailAddresses()
    {
        List<String> mailList = new List<String>();
        List<String> mailAddresses = new List<String>(); 
        
        Group g = [SELECT (select userOrGroupId from groupMembers) FROM group WHERE name like 'Operations_Only'];
        for (GroupMember gm : g.groupMembers) 
        {
            mailList.add(gm.userOrGroupId);
        }
        User[] usr = [SELECT email FROM user WHERE id IN :mailList];
        for(User u : usr) 
        {
            if(u.email!=null)
            {mailAddresses.add(u.email);}
            
        } 
        return mailAddresses;
    }
    private void createCase(Contact ct, Asset asset)
    {
        List<RecordType> types = [select Id from RecordType where Name='Incoming Email' and SObjectType='Case' limit 1];
        Id recordTypeId = (types.size() > 0) ? types[0].Id : null;
        Id assetId = (asset == null) ? null : asset.Id;
        Case newCase = new Case(Subject=Subject, ContactId=ct.Id, AssetId=assetId, AccountId=ct.AccountId, RecordTypeId=recordTypeId, Status='Qualifying', Type='Incoming Email');
        newCase.Description = 'Request Support Center Access \r\n' +
            'Contact Name: ' + FullName + '\r\n' +
            'Email: ' + Email + '\r\n' +
            'Phone: ' + PhoneNumber + '\r\n' +
            'Company: ' + CompanyName + '\r\n' +
            'SN: ' + SerialNumber + '\r\n';
        insert newCase;
    }
    
    private void grantTheContact(Contact contact)
    {
        contact.CanAllowPortalSelfReg = true;
        update contact;
    }
    
    private void parseContactName(String contactName)
    {
        if(contactName != null)
        {
            contactName = contactName.trim();
            Integer position = contactName.lastIndexOf(' ');
            if(position >= 0)
            {
                FirstName = contactName.substring(0, position);
                LastName = contactName.substring(position + 1);
            }
            else
            {
                LastName = contactName;
            }
        }
    }
    
    public List<SelectOption> getCountryPicklistValues()
    {
        List<SelectOption> lstCountryValues = new List<SelectOption>();
        lstCountryValues.add(new SelectOption('','--None--'));
        Schema.DescribeFieldResult fieldResult = Contact.Country_Picklist__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple)
        {
            lstCountryValues.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return lstCountryValues;
    }
    
    private Contact createContact(Id accountId)
    {
        Contact ct = new Contact(FirstName=FirstName, LastName=LastName, Email=Email, Phone=PhoneNumber, AccountId=accountId, Country_Picklist__c =ContactCountry, LeadSource='Customer Service');
        insert ct;
        return ct;
    }
    
    private Asset findAsset(String sn)
    {
        if(sn != null)
        {
            sn = sn.replaceAll('[\\.\\-]', '');
        }
        List<Asset> assets = [select Id, AccountId from Asset where SerialNumber=:sn and Entitled_for_RMA__c=1 limit 1];
        if(assets.size() > 0)
        {
            return assets[0];
        }
        else
        {
            return null;
        }
    }
    
    @isTest
    static void testSelfRegisterController()
    {
        Contact ct = new Contact(FirstName='Test', LastName='Acme', Email='existing@testacme.com');
        insert ct;
        
        SelfRegisterController controller = new SelfRegisterController();
        controller.submit();
        
        controller.FullName = 'Test Acme';
        controller.Email = 'existing@testacme.com';
        controller.PhoneNumber = '1';
        controller.CompanyName = '1';
        controller.SerialNumber = '1';
        controller.ContactCountry = 'United States';
        controller.submit();
        
        controller = new SelfRegisterController();
        controller.FullName = 'None Existing Contact';
        controller.Email = 'nonexisting@testacme.com';
        controller.PhoneNumber = '1';
        controller.CompanyName = '1';
        controller.SerialNumber = '1';
        controller.ContactCountry = 'United States';
        controller.submit();
    }
}