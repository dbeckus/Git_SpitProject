/**
 * The controller class of LeadConvertToExistingOpportunity page.
 *
 * @author  SnapBI
 * @version 1.1
 *
 * @changelog
 * 4/27/2015 Matt Yuan - Created.
 * 9/19/2015 Matt Yuan - Allow ISR to select a Contact Role on page.
 */

public with sharing class LeadConvertToOpportunityController
{
    private Lead lead;

    public Contact Contact { get; set; }
    public String ContactId { get; set; }
    public String OpportunityId { get; set; }
    public OpportunityContactRole OCR { get; set; }
    public String LeadConvertedStatus { get; set; }
    //public Boolean IsSendNotificationEmail { get; set; }
    //public Boolean IsOverWriteLeadSource { get; set; }

    public LeadConvertToOpportunityController(ApexPages.StandardController controller)
    {
        if(!Test.isRunningTest())
        {
            controller.addFields(new List<String> { 'OwnerId', 'Status', 'Trial_Request_from_Marketplace__c' });
        }
        lead = (Lead)controller.getRecord();
        Contact = new Contact();
        Contact.OwnerId = lead.OwnerId;
        LeadConvertedStatus = 'Converted into Existing Opportunity';        
        OCR = new OpportunityContactRole(ContactId = contact.Id);
    }

    public List<SelectOption> ContactOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            options.add(new SelectOption('new', 'Create New Contact: ' + lead.Name));
            if(String.isNotBlank(Contact.AccountId))
            {
                for(Contact con : [select Id, Name from Contact where AccountId = :Contact.AccountId order by Name])
                {
                    options.add(new SelectOption(con.Id, 'Attach to Existing: ' + con.Name));
                }
            }
            return options;
        }
    }

    public List<SelectOption> OpportunityOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
            if(String.isNotBlank(Contact.AccountId))
            {
                for(Opportunity opp : [select Id, Name from Opportunity where AccountId = :Contact.AccountId and IsClosed=false order by Name])
                {
                    options.add(new SelectOption(opp.Id, 'Attach to Existing: ' + opp.Name));
                }
            }
            return options;
        }
    }

    //public List<SelectOption> ConvertedStatusOptions
    //{
    //    get
    //    {
    //        List<SelectOption> options = new List<SelectOption>();
    //        options.add(new SelectOption('', '--None--'));
    //        for(LeadStatus leadStatus : [select MasterLabel from LeadStatus where IsConverted = true order by SortOrder])
    //        {
    //            options.add(new SelectOption(leadStatus.MasterLabel, leadStatus.MasterLabel));
    //        }
    //        return options;
    //    }
    //}

    public PageReference convert()
    {
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.Id);
        lc.setOwnerId(Contact.OwnerId);
        lc.setAccountId(Contact.AccountId);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus(LeadConvertedStatus);
        //lc.setSendNotificationEmail(IsSendNotificationEmail);
        //lc.setOverwriteLeadSource(IsOverWriteLeadSource);
        if(String.isNotBlank(ContactId) && ContactId != 'new')
        {
            lc.setContactId(ContactId);
        }

        Savepoint sp = Database.setSavePoint();
        try
        {
            lead.BANT_Qualified__c = false;
            lead.Contact_Me__c = false;
            update lead;
            
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if(lcr.isSuccess())
            {
                ContactId = lcr.getContactId();
                OCR.OpportunityId = OpportunityId;
                OCR.ContactId = ContactId;
                List<OpportunityContactRole> ocrs = [select Id, ContactId, OpportunityId, Role from OpportunityContactRole where OpportunityId = :OpportunityId and ContactId = :ContactId];
                if(!ocrs.isEmpty())
                {
                    OCR.Id = ocrs[0].Id;
                }
                upsert OCR;
                
                return new PageReference('/' + OpportunityId);
            }
            else
            {
                String errMsg = '';
                for(Database.Error error : lcr.getErrors())
                {
                    errMsg += error.getMessage() + '\r\n';
                }
                ApexPages.Message pageErrMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errMsg);
                ApexPages.addMessage(pageErrMsg);
                return null;
            }
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
    }
}