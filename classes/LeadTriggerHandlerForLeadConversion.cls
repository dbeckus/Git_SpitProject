/**
 * A Trigger handler of Lead.
 * Update Contact.LeadStatus after lead conversion.
 *
 * @author  SnapBI
 * @version 1.0
 *
 * @changelog
 * 10/6/2015 Matt - Created.
 */

public class LeadTriggerHandlerForLeadConversion extends TriggerHandler
{
    public override void afterUpdate()
    {
        updateLeadStatusOnContact();
    }

    private void updateLeadStatusOnContact()
    {
        List<Contact> contacts = new List<Contact>();
        for(Lead lead : [select ConvertedContact.Id, ConvertedContact.Lead_Status__c, Status from Lead where Id in :Trigger.newMap.keySet() and IsConverted = true and Trial_Request_from_Marketplace__c = false])
        {
            lead.ConvertedContact.Lead_Status__c =  lead.Status;
            contacts.add(lead.ConvertedContact);
        }
        if(!contacts.isEmpty())
        {
            update contacts;
        }
    }
}