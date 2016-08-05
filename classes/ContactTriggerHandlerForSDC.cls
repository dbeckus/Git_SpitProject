/**
 * A Trigger handler of Contact.
 * Move contact to SD campaign when Lead Lifecycle Stage equals "03 MQL", "04 SAL", "13 MQC" or "14 SAC". Clear Contact Sub Status.
 * Move contact off the SD campaign when Lead Lifecycle Stage not equals "03 MQL", "04 SAL", "13 MQC" or "14 SAC".
 * Clear BANT Qualified and Contact Me field when Lead Lifecycle Lifecycle equals "Sales - Rejected", or "Rejected".
 *
 * @author  SnapBI
 * @version 1.2
 *
 * @changelog
 * 4/21/2015 Matt Yuan - Created.
 * 7/27/2015 Matt Yuan - Updated move lead off the SD Campaign logic.
 * 8/18/2015 Matt Yuan - Added 'MQL', 'SAL', 'MQC' in Lead Lifecycle Stages.
 */

public class ContactTriggerHandlerForSDC extends TriggerHandler 
{
    public override void afterInsert()
    {
        moveContactOnOffCampaign();
    }
    
    public override void afterUpdate()
    {
        moveContactOnOffCampaign();
    }
    
    private void moveContactOnOffCampaign()
    {
        Set<String> moveToSDCampaignStages = new Set<String> { '03 MQL', '04 SAL', '13 MQC', '14 SAC', 'MQL', 'SAL', 'MQC' };
        Set<String> rejectStatuses = new Set<String> { 'Sales Rejected', 'Rejected' };

        String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();

        Set<Id> contactIdsToBeMovedOff = new Set<Id>();
        List<Contact> contactsToBeUpdated = new List<Contact>();
        List<CampaignMember> newSDCampaignMembers = new List<CampaignMember>();
        Contact oldContact;

        for(Contact newContact : [select Id, Account.Type, Lead_Lifecycle_Stage__c, Lead_Status__c, Lead_Sub_Status__c, Contact_Me__c, Contact_BANT_Qualified__c from Contact where Id in :trigger.newMap.keySet()])
        {
            if(Trigger.isInsert)
            {
                if(moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && newContact.Account.Type != 'Partner')
                {
                    newContact.Lead_Sub_Status__c = null;
                    contactsToBeUpdated.add(newContact);
                    newSDCampaignMembers.add(new CampaignMember(ContactId = newContact.Id, CampaignId = sdCampaignId));
                }
            }
            else if(Trigger.isUpdate)
            {
                oldContact = (Contact)Trigger.oldMap.get(newContact.Id);
                if(moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && !moveToSDCampaignStages.contains(oldContact.Lead_Lifecycle_Stage__c) && newContact.Account.Type != 'Partner')
                {
                    newContact.Lead_Sub_Status__c = null;
                    contactsToBeUpdated.add(newContact);
                    newSDCampaignMembers.add(new CampaignMember(ContactId = newContact.Id, CampaignId = sdCampaignId));
                }
                if(!moveToSDCampaignStages.contains(newContact.Lead_Lifecycle_Stage__c) && moveToSDCampaignStages.contains(oldContact.Lead_Lifecycle_Stage__c))
                {
                    contactIdsToBeMovedOff.add(newContact.Id);
                }
                if(rejectStatuses.contains(newContact.Lead_Status__c) && !rejectStatuses.contains(oldContact.Lead_Status__c))
                {
                    newContact.Contact_Me__c = false;
                    newContact.Contact_BANT_Qualified__c = false;
                    contactsToBeUpdated.add(newContact);
                    contactIdsToBeMovedOff.add(newContact.Id);
                }
            }
        }

        //Move contacts to SD campaign
        if(!newSDCampaignMembers.isEmpty())
        {
            Database.insert(newSDCampaignMembers, false);
        }

        //Move contacts off SD campaign
        if(!contactIdsToBeMovedOff.isEmpty())
        {
            delete [select Id from CampaignMember where CampaignId = :sdCampaignId and ContactId in :contactIdsToBeMovedOff];
        }
        
         //Update contacts
        if(!contactsToBeUpdated.isEmpty())
        {
            SilverPeakUtils.BypassingTriggers = true;
            Database.update(contactsToBeUpdated, false);
            SilverPeakUtils.BypassingTriggers = false;
        }
    }
}