/*
 * Set the Deal Reg End Date when converting a lead(Record Type is Deal Reg) to an opp.
 */

trigger UpdateDealRegEndDateAfterConversion on Lead (after update)
{
    if(!SilverPeakUtils.BypassingTriggers)
    {
        Map<String,Schema.RecordTypeInfo> leadRecordTypes = Schema.SObjectType.Lead.getRecordTypeInfosByName();
        if(leadRecordTypes.containsKey('Deal Registration'))
        {
            Id dealRegId = leadRecordTypes.get('Deal Registration').getRecordTypeId();
            Map<Id, Lead> oldLeads = trigger.oldMap;
            Set<Id> convertedOpportunityIds = new Set<Id>();
            for(Lead lead : trigger.new)
            {
                if(lead.RecordTypeId == dealRegId && lead.ConvertedOpportunityId != null && oldLeads.get(lead.Id).ConvertedOpportunityId == null)
                {
                    convertedOpportunityIds.add(lead.ConvertedOpportunityId);
                }
            }
            if(!convertedOpportunityIds.isEmpty())
            {
                Date today = Date.today();
                List<Opportunity> opportunities = new List<Opportunity>();
                for(Id oppId : convertedOpportunityIds)
                {
                    opportunities.add(new Opportunity(Id=oppId, Deal_Approved_Date__c = today, Registration_Expiration__c = today.addDays(90)));
                }
                SilverPeakUtils.BypassingTriggers = true;
                update opportunities;
                SilverPeakUtils.BypassingTriggers = false;
            }
        }
    }
}