/*
 * Controller of page LeadISRRejected and LeadRSMRejected
 */
public with sharing class LeadRejectedController 
{
    private Lead lead;
    
    public LeadRejectedController(ApexPages.StandardController controller) 
    {
        lead = (Lead)controller.getRecord();
        IsAllowed = lead.OwnerId == UserInfo.getUserId();
        if(!IsAllowed)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'You must be the Lead Owner to reject it'));
        }
    }
    
    public Boolean IsAllowed { get; set; }
    
    public PageReference ismReject()
    {
        lead.Status = 'Sales Rejected'; 
        lead.Screening_Results__c = 'Disqualified'; 
        lead.Screening_Pass_Date__c = Date.today();
        lead.Screening_Organization__c = 'Silver Peak'; 
        lead.Screening_Agent__c = UserInfo.getLastName();
        lead.Ownership_Routing__c = ''; 
        try
        {
            upsert lead;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Success.<script>opener.location=\'/'+lead.Id+'\';setTimeout("window.close()", 3000)</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        
        return null;
    }
    
    public PageReference rsmReject()
    {
        lead.Status = 'Sales Rejected'; 
        try
        {
            upsert lead;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Success.<script>opener.location=\'/'+lead.Id+'\';setTimeout("window.close()", 3000)</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
}