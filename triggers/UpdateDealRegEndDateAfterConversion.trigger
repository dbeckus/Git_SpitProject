/*
 * Set the Deal Reg End Date when converting a lead(Record Type is Deal Reg) to an opp.
 */

trigger UpdateDealRegEndDateAfterConversion on Lead (after update)
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true limit 1];
        if(!recordTypes.isEmpty())
        {
            Map<Id, Lead> oldLeads = trigger.oldMap;
            Set<Id> convertedOpportunityIds = new Set<Id>();
            for(Lead lead : trigger.new)
            {
                if(lead.RecordTypeId == recordTypes[0].Id && lead.ConvertedOpportunityId != null && oldLeads.get(lead.Id).ConvertedOpportunityId == null)
                {
                    convertedOpportunityIds.add(lead.ConvertedOpportunityId);
                }
            }
            if(!convertedOpportunityIds.isEmpty())
            {
                Date today = Date.today();
                List<Opportunity> opportunities = [select Deal_Approved_Date__c, Registration_Expiration__c from Opportunity where Id in :convertedOpportunityIds];
                for(Opportunity opportunity : opportunities)
                {
                    opportunity.Deal_Approved_Date__c = today;
                    opportunity.Registration_Expiration__c = today.addDays(90);
                }
                SilverPeakUtils.BypassingTriggers = true;
                update opportunities;
                SilverPeakUtils.BypassingTriggers = false;
            }
        }
    }
}