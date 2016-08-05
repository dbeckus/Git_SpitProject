/*
 * Populates Reseller Addl Notice with Contact on Reseller PO
 */
trigger PopulateFieldsToContract on Contract (before insert, before update) 
{
    Set<Id> poIds = new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Contract ct : Trigger.new)
        {
            if(ct.Reseller_PO__c != null)
            {
                poIds.add(ct.Reseller_PO__c);
            }
        }
    }
    else if(Trigger.isUpdate)
    {
        for(Contract ct : Trigger.new)
        {
            Contract oldCt = Trigger.oldMap.get(ct.Id);
            if(ct.Reseller_PO__c != oldCt.Reseller_PO__c)
            {
                if(ct.Reseller_PO__c == null)
                {
                    ct.Reseller_Addl_Notices__c = null;
                }
                else
                {
                    poIds.add(ct.Reseller_PO__c);
                }
            }
        }
    }
    if(poIds.size() > 0)
    {
        Map<Id, Id> po2Contact = new Map<Id, Id>();
        for(Purchase_Order__c po : [select Id, Email_Contact__c from Purchase_Order__c where Id in :poIds])
        {
            po2Contact.put(po.Id, po.Email_Contact__c);
        }
        for(Contract ct : Trigger.new)
        {
            if(po2Contact.containsKey(ct.Reseller_PO__c))
            {
                ct.Reseller_Addl_Notices__c = po2Contact.get(ct.Reseller_PO__c);
            }
        }
    }
}