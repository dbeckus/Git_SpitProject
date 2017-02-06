/**
 * A Trigger handler of Lead.
 * Update Contact.LeadStatus after lead conversion.
 *
 * @author  SnapBI
 * @version 1.0
 *
 * @changelog
 * 10/6/2015 Matt - Created
 * 10/24/2016 Zhong - Removed an unnecessary Soql
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
        for(Sobject obj : Trigger.new)
        {
            Lead lead = (Lead)obj;
            if(lead.IsConverted == true && lead.Trial_Request_from_Marketplace__c == false && lead.ConvertedContactId != null)
            {
                contacts.add(new Contact(Id=lead.ConvertedContactId, Lead_Status__c=lead.Status));
            }
        }
        if(!contacts.isEmpty())
        {
            update contacts;
        }
    }
}