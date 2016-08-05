trigger ShareLeadAndOpportunityToPartner on Lead (after insert, after update) 
{
    Map<String, Schema.RecordTypeInfo> leadRecordTypes = Lead.SObjectType.getDescribe().getRecordTypeInfosByName();
    Schema.RecordTypeInfo dealReg = leadRecordTypes.get('Deal Registration');
    List<Lead> needToShareLeads = new List<Lead>();
    List<Id> needToShareLeadIds = new List<Id>();
    
    for(Lead theLead : trigger.New)
    {
        if(dealReg != null && theLead.RecordTypeId == dealReg.getRecordTypeId())
        {
            if(Trigger.isinsert)
            {
                needToShareLeads.add(theLead);
                needToShareLeadIds.add(theLead.Id);
            }
            else if(Trigger.isUpdate)
            {
                Lead oldLead = trigger.oldmap.get(theLead.Id);
                if(isChanged(oldLead, theLead, new String[] {'Registered_Distributor_Contact__c', 'Registered_Partner_Sales_Rep__c', 'Registered_Distributor__c', 'Registered_Partner__c'}))
                {
                    needToShareLeads.add(theLead);
                    needToShareLeadIds.add(theLead.Id);
                }
            }    
        }
        if(needToShareLeads.size() > 0)
        {
            if(System.isFuture())
            {
                ShareLeadAndOpportunityToPartnerHelper.shareLeads(needToShareLeads);
            }
            else
            {
                //owner change in assignment rule may remove the sharing, making the sharing in async assures.
                ShareLeadAndOpportunityToPartnerHelper.willShareLeads(needToShareLeadIds);
            }
        }
    }
        
    //checks if the fields are changed in the sObjects
    private Boolean isChanged(sObject oldObj, sObject newObj, String[] fields)
    {
        for(String field : fields)
        {
            Object oldValue = oldObj.get(field);
            Object newValue = newObj.get(field);
            if(oldValue != newValue)
            {
                return true;
            }
        }
        return false;
    }
}