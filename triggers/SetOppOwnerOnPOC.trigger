/*
 * Auto populates the opportunity owner on POC_Summary object.
 */
trigger SetOppOwnerOnPOC on POC_Summary__c (before insert, before update)
{
	Set<Id> oppId = new Set<Id>();
	if(Trigger.isInsert)
	{
		for(POC_Summary__c poc : Trigger.new)
		{
			if(poc.POC_For__c != null)
			{
				oppId.add(poc.POC_For__c);
			}
		}
	}
	else if(Trigger.isUpdate)
	{
		for(POC_Summary__c poc : Trigger.new)
		{
			POC_Summary__c oldPoc = Trigger.oldMap.get(poc.Id);
			if(poc.POC_For__c != oldPoc.POC_For__c)
			{
				if(poc.POC_For__c == null)
				{
					poc.OppOwner__c = null;
				}
				else
				{
					oppId.add(poc.POC_For__c);
				}
			}
		}
	}
	
	if(oppId.size() > 0)
	{
		Map<Id, Id> oppMap = new Map<Id, Id>();
		for(Opportunity opp : [select Id, OwnerId from Opportunity where Id in :oppId])
		{
			oppMap.put(opp.Id, opp.OwnerId);
		}
		for(POC_Summary__c poc : Trigger.new)
		{
			if(poc.POC_For__c != null && oppMap.containsKey(poc.POC_For__c))
			{
				poc.OppOwner__c = oppMap.get(poc.POC_For__c);
			}
		}
	}
}