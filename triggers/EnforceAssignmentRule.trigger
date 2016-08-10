/*
 * Executes the default Lead assignment rule when Trigger_Assignment__c was checked.
 */
trigger EnforceAssignmentRule on Lead (after update)
{
    /*List<Lead> leads = new List<Lead>();
    Database.DMLOptions dmlOption = new Database.DMLOptions();
    dmlOption.assignmentRuleHeader.useDefaultRule = true;
    for(Lead lead : [select Id, Trigger_Assignment__c from Lead where Id in :Trigger.new])
    {
        Lead oldLead = Trigger.oldMap.get(lead.Id);
        if(!oldLead.Trigger_Assignment__c && lead.Trigger_Assignment__c)
        {
            lead.setOptions(dmlOption);
            lead.Trigger_Assignment__c = false;            
            leads.add(lead);
        }
    }
    
    try
    {
        Database.update(leads);
    }
    catch(Exception e)
    {
        Trigger.new[0].addError(e.getMessage());
    }*/
}