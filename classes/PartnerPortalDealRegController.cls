/**
 * The controller of PartnerPortalDealReg page.
 */

public without sharing class PartnerPortalDealRegController 
{
    private User currentUser;
    private Id DealRegId;
    
    public PartnerPortalDealRegController()
    {
        String leadId = ApexPages.currentPage().getParameters().get('id');
        TemporaryAddress = new Partner_Account_Profile__c();
        List<RecordType> dealRegType = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' limit 1];
        DealRegId = (dealRegType.size() > 0) ? dealRegType[0].Id : null;
        if(String.isBlank(leadId))
        {
            Lead = new Lead(RecordTypeId=DealRegId);
        }
        else
        {
            List<Lead> leads = [select Id, RecordTypeId, IsConverted, FirstName, LastName, Title, Company, Phone, Email, Street, City, State, PostalCode, Country, Project_Name__c, Estimated_Close_Date__c, Project_Description__c, Project_Budgeted__c, Project_Budget_Amount__c, Competitive_Deal__c, Competition__c, Deal_Source__c, Distributor__c, Deal_Type__c, Registered_Distributor__c, Registered_Partner__c, ConvertedOpportunityId, ConvertedOpportunity.Registering_Partner__c, ConvertedOpportunity.Registered_Distributor__c, ConvertedOpportunity.Registered_Distributor_Contact__c, ConvertedOpportunity.Registering_Partner_Sales_Rep__c from Lead where Id=:leadId or ConvertedOpportunityId=:leadId limit 1];
            List<Opportunity> opps = [select Deal_Id__c from Opportunity where Id=:leadId limit 1];
            DealId = (opps.size() > 0) ? opps[0].Deal_Id__c : null;
            Lead = (leads.size() > 0) ? leads[0] : new Lead();
            TemporaryAddress.Country__c = Lead.Country;
        }
        IsNewLead = (lead.Id == null || (lead.Id != null && lead.RecordTypeId!=DealRegId && !lead.IsConverted));
        currentUser = [select Id, ContactId, Contact.AccountId, Contact.Account.Owner.GEO_Region__c from User where Id = :UserInfo.getUserId() limit 1];
        if(!isAuthorized())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You are not authorized.'));
            Lead = new Lead();
        }
    }

    public Lead Lead { get; set; }
    public Partner_Account_Profile__c TemporaryAddress { get; set; } /* For country data binding */
    public Boolean IsNewLead { get; set; }
    public String DealId { get; set; }
    
    public PageReference submit() 
    {
        SavePoint sp = Database.setSavePoint();
        lead.Registered_Partner__c = currentUser.Contact.AccountId;
        lead.Registered_Partner_Sales_Rep__c = currentUser.ContactId;
        Lead.Country = TemporaryAddress.Country__c;
        lead.RecordTypeId = DealRegId;
        lead.LeadSource = 'Deal Registration';
        lead.GEO__c = currentUser.Contact.Account.Owner.GEO_Region__c;
        
        try
        {
            upsert lead;
            IsNewLead = false;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
        submitLead(lead.Id);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'The new deal has been submitted.'));   
        return null;
    }
    
    @future
    private static void submitLead(Id leadId)
    {
        Approval.ProcessResult result = null;
        try
        {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Client submission');
            req.setObjectId(leadId);  
            result = Approval.process(req);
            
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException('Failed to submit deal reg', 'Lead Id = ' + leadId);
        }
    }
    
    private Boolean isAuthorized()
    {
        if(IsNewLead)
        {
            return true;
        }
        else
        {
            return Lead.Registered_Distributor__c == currentUser.Contact.AccountId 
                    || Lead.Registered_Partner__c == currentUser.Contact.AccountId 
                    || (Lead.ConvertedOpportunityId!= null && 
                        (Lead.ConvertedOpportunity.Registering_Partner__c == currentUser.Contact.AccountId 
                        || Lead.ConvertedOpportunity.Registered_Distributor__c == currentUser.Contact.AccountId
                        || Lead.ConvertedOpportunity.Registered_Distributor_Contact__c == currentUser.ContactId
                        || Lead.ConvertedOpportunity.Registering_Partner_Sales_Rep__c == currentUser.ContactId));
        }
    }
}