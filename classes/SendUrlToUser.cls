/*
 * Controller of sendEmailToUser 
 * encrypt the MDF.ID + todey.format();
 * Send MDF URL Email to User
 */
public with sharing class SendUrlToUser
{   
    public String  mdfId { get; set; }
    public PageReference sendEmailToUser()
    {
        mdfId = ApexPages.currentPage().getParameters().get('id');
        if(mdfId instanceOf Id)
        {
            MDF_Request__c mdf = [Select Id, Name, Owner.Email, Owner.Name, Owner.Profile.Name, Contact__c, Contact__r.Name, Contact__r.Email from MDF_Request__c where Id =: mdfId limit 1 ][0];
            if(mdf.Owner.Profile.Name == '13g-SP Partner Community' || (String.isNotBlank(mdf.Contact__c) && String.isNotBlank(mdf.Contact__r.Email)))
            {
                Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), Blob.valueOf(mdf.Id + '|' + Date.today().format()));
                String url = EncodingUtil.base64Encode(cryptoData);
                List<EmailTemplate> et = [Select Id, Name, Subject, Body, HtmlValue from EmailTemplate where DeveloperName = 'Marketing_Fund_Request' limit 1];
                if(!et.isEmpty())
                {
                    String newHtmlBody = mergeEmail(et[0].Body, mdf, url);
                    String newSubject = mergeEmail(et[0].Subject, mdf, url);
                    //Send MDF URL Email to User
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String recipient = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Email;
                    mail.setToAddresses(new String[] {recipient});
                    //mail.setToAddresses(new List<String> {'daniel@snapbi.com'});
                    mail.setSenderDisplayName('The Silver Peak Team');
                    mail.setSubject(mergeEmail(et[0].Subject, mdf, url));
                    mail.setHtmlBody(mergeEmail(et[0].HtmlValue, mdf, url));
                    mail.setPlainTextBody(mergeEmail(et[0].Body, mdf, url));
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Send email successfully！It will jump back in two seconds.'));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'The Marketing Funds Url Email Template has not been find'));
                    mdfId = '';
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Your MDF owner pfofile must be 13g-SP Partner Community or your mdf must have a contact.Please check and retry '));
                mdfId = '';
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'The MDF Id is invalid'));
            mdfId = '';
        }
        return null;
    }
    
    private String mergeEmail(String originalValue, MDF_Request__c mdf, String encryptedLink)
    {
        String recipientName = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Name;
        return originalValue.replace('{!Mdf_Request__c.Owner.Name}', recipientName).replace('{!MDF_Request__c.Link}','https://partners.silver-peak.com/s/MarketingFundsAnonymous?id=' + encryptedLink).replace('{!MDF_Request__c.Name}', mdf.Name);
    }
}