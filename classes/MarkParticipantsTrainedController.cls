/*
 * Controller of page MarkParticipantsTrained
 */
public with sharing class MarkParticipantsTrainedController 
{
    private Training_Events__c event;
    
    public MarkParticipantsTrainedController(ApexPages.StandardController controller) 
    {
        event = (Training_Events__c)controller.getRecord();
        SpxTrained = false;
        ScspCompleted = false;
        SctpCompleted = false;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Are you sure you want to mark all registered contacts for this class as having completed training? If not, remove any who did not attend first.'));
    }

    public Boolean SpxTrained { get; set; }
    public Boolean ScspCompleted { get; set; }
    public Boolean SctpCompleted { get; set; }
    
    public PageReference save()
    {
        List<Contact> contacts = new List<Contact>();
        List<Training_Registration__c> registrations = [select Id, Attendee__c from Training_Registration__c where Event__c=:event.Id];
        for(Training_Registration__c registration : registrations)
        {
            if(SpxTrained)
            {
                contacts.add(new Contact(Id=registration.Attendee__c, Completed_SPX_Training__c=true));
            }
            else if(ScspCompleted)
            {
                contacts.add(new Contact(Id=registration.Attendee__c, SCSP_Completed__c=true));
            }
            else if(SctpCompleted)
            {
                //contacts.add(new Contact(Id=registration.Attendee__c, Completed_Sales_Training__c=true));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must select at least one checkbox.'));
                return null;
            }
        }
        try
        {
            if(contacts.size() > 0)
            {
                update contacts;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, contacts.size() + ' registration(s) updated<script>top.opener.location="/'+event.Id+'";setTimeout("top.close()", "3000");</script>'));
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
}