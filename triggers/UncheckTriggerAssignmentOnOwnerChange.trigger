/*
 * unchecks Trigger_Assignment__c when owner is changed.
 */
trigger UncheckTriggerAssignmentOnOwnerChange on Lead (before update) 
{
    /*for(Lead lead : Trigger.new)
    {
        Lead oldLead = Trigger.oldMap.get(lead.Id);
        if(lead.OwnerId != oldLead.OwnerId)
        {
            lead.Trigger_Assignment__c = false;
        }
    }*/
}