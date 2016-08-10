/*
 * After new campaign creation, create and link a new lead to it. This enforces campaign being listed in some reports.
 */
trigger CreateDefaultLead on Campaign (after insert) 
{
    Map<Id, Lead> campaign2Lead = new Map<Id, Lead>();
    List<RecordType> leadRecordTypes = [select Id from RecordType where SObjectType='Lead' and Name='Lead' limit 1];
    Id leadRecordTypeId = (leadRecordTypes.size() > 0) ? leadRecordTypes[0].Id : null;
    for(Campaign campaign : Trigger.new)
    {
        Lead newLead = new Lead(LastName=campaign.Name, Email='marketingoperations@silver-peak.com', Company='Silver Peak', Status='Marketing Nurturing');
        if(leadRecordTypeId != null)
        {
            newLead.RecordTypeId = leadRecordTypeId;
        }
        campaign2Lead.put(campaign.Id, newLead);
    }
    try
    {
        insert campaign2Lead.values();
        List<CampaignMember> newMembers = new List<CampaignMember>();
        for(Id campaignId : campaign2Lead.keyset())
        {
            Lead newLead = campaign2Lead.get(campaignId);
            CampaignMember newMember = new CampaignMember(CampaignId=campaignId, LeadId=newLead.Id);
            newMembers.add(newMember);
        }
        insert newMembers;
    }
    catch(Exception ex)
    {
        Trigger.new[0].addError('Failed to link a default lead to the campaign. Error message is: ' + ex.getMessage());
    }
}