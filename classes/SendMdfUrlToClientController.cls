/*
 * Controller of sendEmailToUser 
 * encrypt the MDF.ID + todey.format();
 * Send MDF URL Email to User
 */
public with sharing class SendMdfUrlToClientController
{   
    public String  mdfId { get; set; }
    public PageReference SendMdfUrlToClient()
    {
        mdfId = ApexPages.currentPage().getParameters().get('id');
        if(mdfId instanceOf Id)
        {
            MDF_Request__c mdf = [Select Id, Name, Owner.Email, Owner.Name, Owner.FirstName, Owner.Profile.Name, Contact__c, Contact__r.Name, Contact__r.FirstName, Contact__r.Email from MDF_Request__c where Id =: mdfId limit 1 ][0];
            if(mdf.Owner.Profile.Name == '13g-SP Partner Community' || (String.isNotBlank(mdf.Contact__c) && String.isNotBlank(mdf.Contact__r.Email)))
            {
                String url = encryptParameter(mdf.Id);
                List<EmailTemplate> et = [Select Id, Name, Subject, Body, HtmlValue from EmailTemplate where DeveloperName = 'Marketing_Fund_Request' limit 1];
                if(!et.isEmpty())
                {
                    String newHtmlBody = mergeEmail(et[0].Body, mdf, url);
                    String newSubject = mergeEmail(et[0].Subject, mdf, url);
                    //Send MDF URL Email to User
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String recipient = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.Email : mdf.Contact__r.Email;
                    mail.setToAddresses(new String[] {recipient});
                    mail.setSenderDisplayName('The Silver Peak Team');
                    mail.setSubject(mergeEmail(et[0].Subject, mdf, url));
                    mail.setHtmlBody(mergeEmail(et[0].HtmlValue, mdf, url));
                    mail.setPlainTextBody(mergeEmail(et[0].Body, mdf, url));
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Email has been sent successfully. Page is refreshing.'));
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'Email template not found. '));
                    mdfId = '';
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'To send the link to client, the MFR should either be owned by a partner user, or the contact field is populated.'));
                mdfId = '';
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'The MFR Id is invalid'));
            mdfId = '';
        }
        return null;
    }
    
    private String mergeEmail(String originalValue, MDF_Request__c mdf, String encryptedLink)
    {
        String recipientName = mdf.Owner.Profile.Name == '13g-SP Partner Community' ? mdf.Owner.FirstName: mdf.Contact__r.FirstName;
        return originalValue.replace('{!MDF_Request__c.Owner.Name}', recipientName).replace('{!MDF_Request__c.OwnerFirstName}', recipientName).replace('{!MDF_Request__c.Link}','https://partners.silver-peak.com/s/MarketingFundsAnonymous?id=' + encryptedLink).replace('{!MDF_Request__c.Name}', mdf.Name);
    }
    
    public static String encryptParameter(String mdfId)
    {
        Blob cryptoData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('SliverPeakCrytpo'), Blob.valueOf(mdfId + '|' + Date.today().format()));
        return EncodingUtil.base64Encode(cryptoData);
    }
}