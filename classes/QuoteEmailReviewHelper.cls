public class QuoteEmailReviewHelper {
    
    public static void SendEmailForECApproval(Quote__c quoteDtl)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setTargetObjectId(quoteDtl.PreparedFor__c);
        mail.setSubject('Edge Connect Quote '+quoteDtl.Name+ ' for review.');
        string Url = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+quoteDtl.Id;
        mail.setPlainTextBody('This quote has Edge connect products and needs your review.'+
                              'Once the review is complete, please check the EC Approval on the quote.'+
                              'Please find the link: '+ Url );
        mail.setSaveAsActivity(false);           
        mail.setToAddresses(new String[] {'SalesOps@Silver-Peak.com'});
        mail.setUseSignature(false);
      
        Messaging.sendEmail(new Messaging.Email[] {mail});
    }
    
    
    public static boolean IsECApprovalRequired(Quote__c quoteDtl)
        {
        List<Quote_Line__c> quotedtls=null;
        if(quoteDtl!=null)
        {
            quotedtls= [Select Id, Product__r.Name from Quote_Line__c where Quote__c=:quoteDtl.Id and Product__r.Name like 'EC%' ];
        }
        if(quotedtls!=null && quotedtls.size()>0)
        {
            return true;
        }
        return false;
    }
    
    
}