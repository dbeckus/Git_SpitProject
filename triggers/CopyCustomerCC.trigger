/*
 * Copies CustomerCCEmail field on account to case
 */
trigger CopyCustomerCC on Case (before insert, before update) 
{
    Set<Id> accIds = new Set<Id>();
    for(Case c : Trigger.new)
    {
        if(c.AccountId != null)
        {
            accIds.add(c.AccountId);
        }
    }
    
    if(accIds.size() > 0)
    {
        Map<Id, String> accEmailMap = new Map<Id, String>(); // key: account id, value: account email
        for(Account acc : [select Id, Customer_CC_Email__c from Account where Id in :accIds and Customer_CC_Email__c!=null])
        {
            accEmailMap.put(acc.Id, acc.Customer_CC_Email__c);
        }
        for(Case c : Trigger.new)
        {
            if(c.AccountId != null && c.CC10__c == null && accEmailMap.containsKey(c.AccountId))
            {
                c.CC10__c = accEmailMap.get(c.AccountId);
            }
        }
    }
}