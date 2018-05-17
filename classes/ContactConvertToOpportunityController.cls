/**
 * The controller class of ContactConvertToNewOpportunity, ContactConvertToExistingOpportunity page.
 *
 * @author  SnapBI
 * @version 1.1
 *
 * @changelog
 * 4/21/2015 Matt Yuan - Created.
 * 9/6/2015 Matt Yuan - Check duplicated OCR before create and allow ISR to select a Contact Role on page.
 */

public without sharing class ContactConvertToOpportunityController
{
    private Contact contact;

    public Opportunity Opportunity { get; set; }
    public String OpportunityId { get; set; }
    public OpportunityContactRole OCR { get; set; }
    
    public List<OpportunityContactRole> ExistingOpps{get;set;}
    //public Boolean IsSendNotificationEmail { get; set; }

    public ContactConvertToOpportunityController(ApexPages.StandardController controller)
    {
        List<Contact> contacts = [select Id, AccountId, Account.Name, Account.OwnerId, ISR_Notes__c, Contact_BANT_Qualified__c, Contact_Me__c, Lead_Status__c from Contact where Id = :controller.getId()];
        if(!contacts.isEmpty()) 
        {
            contact = contacts[0];
        } 
        ExistingOpps= new List<OpportunityContactRole>();
        ExistingOpps=CheckDuplicateOpportunity();
        Opportunity = new Opportunity();
        Opportunity.AccountId = contact.AccountId;
        Opportunity.OwnerId = contact.Account.OwnerId;
        Opportunity.Name = contact.Account.Name;
        OCR = new OpportunityContactRole(ContactId = contact.Id,Role='');
    }

    public List<SelectOption> OpportunityOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            if(contact != null)
            {
                for(Opportunity opp : [select Id, Name from Opportunity where Id not in (select OpportunityId from OpportunityContactRole where ContactId = :contact.Id) and AccountId = :contact.AccountId and IsClosed = false order by Name nulls last])
                {
                    options.add(new SelectOption(opp.Id, opp.Name));
                }
            }
            return options;
        }
    }

    public PageReference ConvertToNewOpportunity()
    {
        
        Savepoint sp = Database.setSavepoint();
        Opportunity.SP_PreMQL_Agent_Notes__c = contact.ISR_Notes__c; //Copy Contact.ScreeningNotes to Opportunity.ISRNotes.
        Opportunity.StageName = 'New'; //Default Stage = New
        Opportunity.CloseDate = Date.today().addDays(90); //Default Close Date = 90 days after
        Opportunity.Trigger_Assignment__c=true;
        
        if(Opportunity.Type== 'null')
        {
           
            Opportunity.Type='New Business';
        }
        try
        {
            upsert Opportunity;
            OpportunityId = Opportunity.Id;
            if(ExistingOpps!=null && ExistingOpps.size()>0)
            	SendEmailtoSalesOps(Opportunity);
            updateContactRelated(true);
            return new PageReference('/' + OpportunityId);
        }
        catch(DMLException ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
    }

    public PageReference ConvertToExistingOpportunity()
    {
        if(String.isNotBlank(OpportunityId))
        {
            Savepoint sp = Database.setSavepoint();
            try
            {
                updateContactRelated(false);
                return new PageReference('/' + OpportunityId);
            }
            catch(DMLException ex)
            {
                Database.rollback(sp);
                ApexPages.addMessages(ex);
                return null;
            }
        }
        else
        {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select an opportunity to continue.');
            ApexPages.addMessage(errorMsg);
            return null;
        }
    }

    //Remove Contact from SD campaign member, add contact role to opportunity.
    //Update Contact.Status, clear "BANT Qualified" & "Contact Me" fields on contact.
    private void updateContactRelated(Boolean isNewOpportunity)
    {
        Integer ocrCount = [select count() from OpportunityContactRole where OpportunityId = :OpportunityId and ContactId = :contact.Id];
        if(ocrCount == 0)
        {
            OCR.OpportunityId = OpportunityId;
            insert OCR;
        }

        String sdCampaignId = SalesDevelopmentHelper.getSDcampaign();
        List<CampaignMember> campaignMembers = [select Id from CampaignMember where CampaignId = :sdCampaignId and ContactId = :contact.Id];
        delete campaignMembers;

        contact.Lead_Status__c = isNewOpportunity ? 'Converted to New Opportunity' : 'Converted into Existing Opportunity';
        contact.Contact_BANT_Qualified__c = false;
        contact.Contact_Me__c = false;
        update contact;
    }
    private void SendEmailtoSalesOps(Opportunity opp)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String templateString='A duplicate opportunity {0} has been created for this account {1}.\n Please see the link  {2} \n\n ';
        String[] arguments = new String[] {opp.Name, contact.Account.Name, System.Url.getSalesforceBaseUrl().toExternalForm()+'/'+opp.AccountId};
        string bodyText= string.format(templateString,arguments);
        mail.setPlainTextBody (bodyText);
        mail.setSubject('Duplicate Opportunity alert: ' + contact.Account.Name);
        mail.setSaveAsActivity(false);
        List<String> sendTo = new List<String>();
        sendTo.add('salesops@silver-peak.com');
        sendTo.add('mmartin@silver-peak.com');
        mail.setToAddresses(sendTo);
        if(!test.isRunningTest())
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        
        
        
    }
    private  List<OpportunityContactRole> CheckDuplicateOpportunity()
    {
        List<OpportunityContactRole> lstOpps=[select id, OpportunityId, Opportunity.Name,Opportunity.StageName,Opportunity.CloseDate,Opportunity.CreatedDate from OpportunityContactRole where Opportunity.Account.Type='Prospect' and Opportunity.IsClosed=false and Opportunity.AccountId=:contact.AccountId ORDER BY Opportunity.CloseDate desc];
        return lstOpps;
    }
}