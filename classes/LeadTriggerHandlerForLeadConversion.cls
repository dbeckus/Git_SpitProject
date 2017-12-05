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
    
    public static Id getCloudingoUserId()
    {
      if(SilverPeakUtils.IsProduction())
        {
            return '005380000057EOB';     
        }
        else
        {
         User cloudingoUser = [Select Id, Name from User where Name = 'Cloudingo Integration'];
         if(cloudingoUser!=null)
         {
         return cloudingoUser.Id;
         }
         return null;
        }
    }

    private void updateLeadStatusOnContact()
    {
        List<Contact> contacts = new List<Contact>();
        for(Sobject obj : Trigger.new)
        {
            Lead lead = (Lead)obj;
            Id uid =userinfo.getUserId();
            Id cloudingoUserId=getCloudingoUserId();
            if(lead.IsConverted == true && lead.Trial_Request_from_Marketplace__c == false && lead.ConvertedContactId != null && cloudingoUserId!=null && uid !=cloudingoUserId )
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