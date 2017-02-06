/*
 * Sets Lead or Contact's Last_Campaign_Response_Date__c to today 
 * when a Campaign Member's status was changed from following status to others or created with status other than following:
 * 'Sent', 'Sent for Tele-Qual', 'Tele-Qualified', 'Disqualified', 'Return to Nurture', 'Could not contact'
 */
trigger SetLastCampaignResponseDate2LeadOrContact on CampaignMember (after insert, after update) 
{
    Set<String> ignoredStatus = new Set<String>{ 'Sent', 'Sent for Tele-Qual', 'Tele-Qualified', 'Disqualified', 'Return to Nurture', 'Could not contact' };
    Set<Id> leadIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    for(CampaignMember campaignMember : Trigger.new)
    {
        if((Trigger.isInsert && !ignoredStatus.contains(campaignMember.Status)) || 
           (Trigger.isUpdate && ignoredStatus.contains(Trigger.oldMap.get(campaignMember.Id).Status) && !ignoredStatus.contains(campaignMember.Status)))
        {
            if(campaignMember.LeadId != null)
            {
                leadIds.add(campaignMember.LeadId);
            }
            else if(campaignMember.ContactId != null)
            {
                contactIds.add(campaignMember.ContactId);
            }
        }
    }
    
    if(leadIds.size() > 0)
    {
        List<Lead> leads = [select Id, Do_Not_Tele_Qualify__c, Do_Not_Tele_Qualify_Date__c from Lead where Id in:leadIds];
        for(Lead updatingLead : leads)
        {
            updatingLead.Last_Campaign_Response_Date__c = System.today();
            if(updatingLead.Do_Not_Tele_Qualify__c == true && updatingLead.Do_Not_Tele_Qualify_Date__c != null && updatingLead.Do_Not_Tele_Qualify_Date__c < Date.today().addDays(-30))
            {
                updatingLead.Do_Not_Tele_Qualify__c = false;
                updatingLead.Do_Not_Tele_Qualify_Date__c = null;
            }
        }
    
        try
        {
            SilverPeakUtils.BypassingTriggers = true;
            update leads;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
        
    List<Contact> contacts = new List<Contact>();
    for(Id contactId : contactIds)
    {
        contacts.add(new Contact(Id = contactId, Last_Campaign_Response_Date__c = System.today()));
    }
    if(contacts.size() > 0)
    {
        try
        {
            update contacts;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError(ex.getMessage());
        }
    }
}