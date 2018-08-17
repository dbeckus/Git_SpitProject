/**
 * A Trigger handler of Lead.
 * Move lead to SD campaign when Lead Lifecycle Stage equals "03 MQL", "04 SAL", "13 MQC" or "14 SAC". Clear Lead Sub Status.
 * Move lead off the SD campaign when Lead Lifecycle Stage not equals "03 MQL", "04 SAL", "13 MQC" or "14 SAC".
 * Clear BANT Qualified and Contact Me field when Lead Lifecycle Lifecycle equals "Sales - Rejected", or "Rejected" or being converted. 
 *
 * @author  SnapBI
 * @version 1.2
 *
 * @changelog
 * 4/21/2015 Matt Yuan - Created.
 * 7/27/2015 Matt Yuan - Updated move lead off the SD Campaign logic.
 * 8/18/2015 Matt Yuan - Added 'MQL', 'SAL', 'MQC' in Lead Lifecycle Stages.
 * 2/10/2016 Andy Getz - Added condition to remove leads from campaign when Lead Status is changed (case 20160130-182792)
 * 10/24/2016 Zhong - Removed an unnecessary SOQL
 */

public class LeadTriggerHandlerForSDC extends TriggerHandler 
{
    public override void afterInsert()
    {
        moveLeadsOnOffCampaign();
    }
    
    public override void afterUpdate()
    {
        moveLeadsOnOffCampaign();
    }
    
    private void moveLeadsOnOffCampaign()
    {
        Set<String> moveToSDCampaignStages = new Set<String> { '03 MQL', '04 SAL', '13 MQC', '14 SAC', 'MQL', 'SAL', 'MQC' };
        Set<String> excludedStatuses = new Set<String> {'Submitted', 'Approved', 'Rejected' };
        Set<String> rejectedStatuses = new Set<String> { 'Sales Rejected', 'Rejected', 'Rejected - Not Interested', 'Rejected - Wrong Role', 'Rejected - Unresponsive/Check Back', 'Rejected - Do Not Contact', 'Rejected -Reseller Partner' };

        String sdCampaignId = SalesDevelopmentHelper.getSDCampaign();
        List<CampaignMember> newSDCampaignMembers = new List<CampaignMember>();
        Set<Id> leadIdsToBeMovedOff = new Set<Id>();
        Map<Id, Lead> leadsToBeUpdated = new Map<Id, Lead>();

        Lead oldLead;
        for(SObject obj : Trigger.new)
        {
            Lead newLead = (Lead)obj;
            if(Trigger.isInsert)
            {
                if(moveToSDCampaignStages.contains(newLead.Lead_Lifecycle_Stage__c) && !excludedStatuses.contains(newLead.Status))
                {
                    if(!leadsToBeUpdated.containsKey(newLead.Id))
                    {
                        leadsToBeUpdated.put(newLead.Id, new Lead(Id=newLead.Id));
                    }
                    leadsToBeUpdated.get(newLead.Id).Lead_Sub_Status__c = null;
                    newSDCampaignMembers.add(new CampaignMember(LeadId = newLead.Id, CampaignId = sdCampaignId));
                }
            }
            else if(Trigger.isUpdate)
            {
                oldLead = (Lead)Trigger.oldMap.get(newLead.Id);
                if(moveToSDCampaignStages.contains(newLead.Lead_Lifecycle_Stage__c) && !moveToSDCampaignStages.contains(oldLead.Lead_Lifecycle_Stage__c) && !excludedStatuses.contains(newLead.Status))
                {
                    if(!leadsToBeUpdated.containsKey(newLead.Id))
                    {
                        leadsToBeUpdated.put(newLead.Id, new Lead(Id=newLead.Id));
                    }
                    leadsToBeUpdated.get(newLead.Id).Lead_Sub_Status__c = null;
                    newSDCampaignMembers.add(new CampaignMember(LeadId = newLead.Id, CampaignId = sdCampaignId));
                }
                //preserving previous if condition
                /*if(!moveToSDCampaignStages.contains(newLead.Lead_Lifecycle_Stage__c) && moveToSDCampaignStages.contains(oldLead.Lead_Lifecycle_Stage__c))
                {
                    leadIdsToBeMovedOff.add(newLead.Id);
                }*/
                //new if condition 
                if((!moveToSDCampaignStages.contains(newLead.Lead_Lifecycle_Stage__c) && moveToSDCampaignStages.contains(oldLead.Lead_Lifecycle_Stage__c)) || (excludedStatuses.contains(newLead.Status) && !excludedStatuses.contains(oldLead.Status)))
                {
                    leadIdsToBeMovedOff.add(newLead.Id);
                }
                if((rejectedStatuses.contains(newLead.Status) && !rejectedStatuses.contains(oldLead.Status)) || (newLead.IsConverted && !oldLead.IsConverted))
                {
                    if(!leadsToBeUpdated.containsKey(newLead.Id))
                    {
                        leadsToBeUpdated.put(newLead.Id, new Lead(Id=newLead.Id));
                    }
                    leadsToBeUpdated.get(newLead.Id).Contact_Me__c = false;
                    leadsToBeUpdated.get(newLead.Id).BANT_Qualified__c = false;
                    leadIdsToBeMovedOff.add(newLead.Id);
                }
            }
        }

        //Move leads to SD campaign
        if(!newSDCampaignMembers.isEmpty())
        {
            Database.insert(newSDCampaignMembers, false);
        }

        //Move leads off SD campaign
        if(!leadIdsToBeMovedOff.isEmpty())
        {
            delete [select Id from CampaignMember where CampaignId = :sdCampaignId and LeadId in :leadIdsToBeMovedOff];
        }

        //Update leads
        if(!leadsToBeUpdated.isEmpty())
        {
            SilverPeakUtils.BypassingTriggers = true;
            Database.update(leadsToBeUpdated.values(), false);
            SilverPeakUtils.BypassingTriggers = false;
        }
    }
}