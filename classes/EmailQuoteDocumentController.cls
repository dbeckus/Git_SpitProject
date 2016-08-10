/*
* Controller of page EmailQuoteDocument
*/
public with sharing class EmailQuoteDocumentController 
{
    private Quote__c quote;
    
    public EmailQuoteDocumentController(ApexPages.StandardController controller) 
    {
        quote = (Quote__c)controller.getRecord();
        //ECApprovalRequired=false;
        ccAddr = UserInfo.getUserEmail();
        subject = 'Quote for ' + quote.Opportunity__r.Account.Name;
       
    }
    /*
    public PageReference SendForReview()
    {
        Quote__c quoteDtl=[Select Id,Name,EC_Approval__c,PreparedFor__c,PreparedFor__r.Email,Approval_Required__c,Approval_Made__c from Quote__c where Id=:quote.Id ];
        if(quoteDtl!=null && !quoteDtl.EC_Approval__c  && !quoteDtl.Approval_Made__c  && QuoteEmailReviewHelper.IsECApprovalRequired(quoteDtl))
        {
            if(quoteDtl.Approval_Required__c==0)
            {
                ECApprovalRequired=true;
                SendEmailForECApproval(quoteDtl);
            }
        }
     
        return null;
    }*/
    public String ccAddr { get; set; }
    //public boolean ECApprovalRequired { get; set; }
    public String OutputMessage { get; set; }
    public String subject { get; set; }
    public String body { get; set; }
    
    /*
    private void SendEmailForECApproval(Quote__c quoteDtl)
    {
        try
        {
            QuoteEmailReviewHelper.SendEmailForECApproval(quoteDtl);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An email has been sent to "Sales Operations" for EC Approval review. <script>setTimeout("top.close()", 3000)</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
    }*/
    public PageReference send()
    {
        Messaging.SingleemailMessage email = new Messaging.SingleEmailMessage();
        email.setTargetObjectId(quote.PreparedFor__c);
        if(ccAddr != null)
        {
            String[] addresses = ccAddr.split('[,;]');
            if(addresses.size() > 0)
            {
                email.setCcAddresses(addresses);
            }
        }
        email.setSubject(subject);
        email.setPlainTextBody(body);
        try
        {
            PageReference downloadPdf = new PageReference('/apex/quotepdf?id='+quote.Id);
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setBody(downloadPdf.getContent());
            attachment.setContentType('application/pdf');
            String attachmentName = (quote.Opportunity__r.Account.Name == null) ? 'Quote.pdf' : 'Quote for ' + quote.Opportunity__r.Account.Name + '.pdf';
            attachment.setFilename(attachmentName);
            email.setFileAttachments(new List<Messaging.EmailFileAttachment> {attachment});
            Messaging.sendEmail(new List<Messaging.Email> { email });
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'An email was sent. <script>setTimeout("top.close()", 3000)</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
}