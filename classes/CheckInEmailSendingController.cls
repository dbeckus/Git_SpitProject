/**
 * Controller of "Check-In Email Sending" page.
 */
public with sharing class CheckInEmailSendingController
{
    private String campaignId = ApexPages.currentPage().getParameters().get('id');
    public String emailAddresses { get; set; }
    
    public PageReference send()
    {
        // Creates leads with entered emails for sending email.
        if(emailAddresses != null && emailAddresses != '')
        {
            Lead[] leads = new Lead[]{};
            for(String address : emailAddresses.split('(\r\n)|\r|\n|,'))
            {
                if(address != '')
                {
                    leads.add(new Lead(LastName = address, Company = address, Email = address));
                }
            }
            try
            {
                insert leads;
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
            
            // Gets the target IDs.
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Id templateId = getTemplateId();
            if(templateId != null)
            {
                for(Lead lead : leads)
                {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateID(templateId);
                    mail.setTargetObjectId(lead.Id);
                    mail.setWhatId(campaignId);
                    mail.setSaveAsActivity(false);
                    mails.add(mail);
                }
            }
            // Sends the mails.
            try
            {
                Messaging.sendEmail(mails);
            }
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }
            try
            {
                delete leads;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Emails have been sent out.<script>setTimeout("top.close()", 3000);</script>'));
            }
            catch(Exception ex)
            {
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter email addresses.'));
        }
        return null;
    }
    
    private Id getTemplateId()
    {
        List<EmailTemplate> templates = [select Id from EmailTemplate where DeveloperName='SendCheckinEmail' limit 1];
        if(templates.size() > 0)
        {
            return templates[0].Id;
        }
        else
        {
            return null;
        }
    }
    
    @isTest
    public static void testCheckInEmailSendingController()
    {
        CheckInEmailSendingController controller = new CheckInEmailSendingController();
        controller.send();
        controller.emailAddresses = 'test@test.com';
        controller.send();
    }
}