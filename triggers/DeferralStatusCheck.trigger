/*
 * 1. Require DeferralDate when status is updated to "Sales Accepted - Deferred"
 * 2. Clears DeferalDate when status moves out of "Sales Accepted - Deferred"
 * 3. Stamp LastStatusChange
 */
trigger DeferralStatusCheck on Lead (before insert, before update) 
{
    for(Lead lead : Trigger.new)
    {
        if(lead.Status == 'Sales Accepted - Deferred' && lead.Deferral_Date__c == null)
        {
            lead.Deferral_Date__c.addError('Deferral date is required');
        }
        if(Trigger.isUpdate)
        {
            Lead oldLead = Trigger.oldMap.get(lead.Id);
            if(oldLead.Status == 'Sales Accepted - Deferred' && lead.Status != 'Sales Accepted - Deferred')
            {
                lead.Deferral_Date__c = null;
            }
            if(lead.Status != oldLead.Status)
            {
                lead.Last_Status_Change__c = Date.today();
            }
        }
    }
}