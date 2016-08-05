/*
 * Controller of the page NewAuthorizationCodes
 * generates authorization code objects with the specified number and course, sends to email to the specified email address
 */
public class NewAuthorizationCodesController 
{
    public NewAuthorizationCodesController()
    {
        AccountId = ApexPages.currentPage().getParameters().get('id');       
        AmountOfCodes = 1;
        CourseCode = '';
        EMailAddress = '';
        TempCode = new AuthCode__c();
        CodeType = 'Customer';
    }
    
    public Id AccountId { get;  set; }
    public Integer AmountOfCodes { get;  set; }
    public String EmailAddress { get; set; }
    public String CourseCode { get; set; }
    public AuthCode__c TempCode { get; set; } //just for input the date
    public String CodeType { get; set; }
    
    //a method create authCode
    public pageReference createAuthorizationCode()
    {
        if(AmountOfCodes == null || AmountOfCodes == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The amount of codes should be large than 0.'));
            return null;
        }
        if(EmailAddress == null || EmailAddress == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The email address is invalid.'));
            return null;
        }
        if(CourseCode == null || CourseCode.length() != 4)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The course code should be 4 characters.'));
            return null;
        }
        if([select count() from Training_Course__c where Course_Code__c=:CourseCode] == 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid course code.'));
            return null;
        }
        
        List<AuthCode__c> results = new List<AuthCode__c>();
        for(Integer i = 0; i < AmountOfCodes; i++)
        {
            AuthCode__c authCode = new AuthCode__c(Account__c = AccountId, Course_Code__c = CourseCode, Expiration_Date__c=TempCode.Expiration_Date__c);
            results.add(authCode);
        }
        try
        {
            insert results;
        }
        catch(Exception error)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to created the authorization code'));
            return null;
        }  

        results = [select Id, Account__c, Authorization_Code__c from AuthCode__c where Id in :results];                
        String allCodes = '';
        for(AuthCode__c entry : results)
        {
            allCodes += entry.Authorization_Code__c + ',';
        }
        allCodes.substring(0, allCodes.length() - 1);
        PageReference pdfPage = (CodeType == 'Customer') ? Page.AuthorizationCodesTable : Page.AuthorizationCodesTablePartner;
        pdfPage.getParameters().put('authCodes', allCodes);
        String expDate = 
        pdfPage.getParameters().put('exp', formatDate(TempCode.Expiration_Date__c));
        if(!Test.isRunningTest())
        {
            Blob pdf = pdfPage.getContentAsPdf();
            String body = pdfPage.getContent().toString();
            SendEmail(EmailAddress, body, pdf);         
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Authorization Codes have been created and sent successfully!<script>window.location="/' + AccountId + '"</script>'));              
        return null;
    }
    
    @testVisible
    //send email with the specified address, body and attachment
    private void SendEmail(String toAddress, String body, Blob pdf)
    {
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        mail.setToAddresses(new String[] { toAddress });
        mail.setBccSender(false);
        mail.setSenderDisplayName('Silver Peak Training Team');
        mail.setReplyTo('noreply@silverpeak.com');
        mail.setSubject('Your authorization codes'); 
        mail.setHtmlBody(body);     

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('Authorization Codes.pdf');
        attachment.setBody(pdf);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        if(!Test.isRunningTest())
        {
        	Messaging.sendEmail(new Messaging.Singleemailmessage[] {mail});
        }
    }
    
    private String formatDate(Date d)
    {
        if(d != null)
        {
            return d.month() + '/' + d.day() + '/' + d.year();
        }
        return '';
    }
}