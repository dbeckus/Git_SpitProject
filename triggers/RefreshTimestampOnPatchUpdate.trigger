/*
 * Refreshes timestamp on patch after patch is updated
 */
trigger RefreshTimestampOnPatchUpdate on Patch__c (before insert, before update, after update) 
{
    Set<Id> patchIds = new Set<Id>();
    for(Patch__c patch : Trigger.new)
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert)
            {
                patch.Timestamp__c = System.now();
            }
            if(Trigger.isUpdate && hasKeyFieldsUpdated(patch, Trigger.oldMap.get(patch.Id)))
            {
                patch.Timestamp__c = System.now();
            }
        }
        else if(Trigger.isAfter)
        {
            if(Trigger.isUpdate && hasSequenceUpdated(patch, Trigger.oldMap.get(patch.Id)))
            {
                Decimal sequence = (patch.ProcessingSequence__c == null) ? 0 : patch.ProcessingSequence__c;
                refreshTimestamp(sequence);
            }
        }
    }
    
    private Boolean hasKeyFieldsUpdated(Patch__c newPatch, Patch__c oldPatch)
    {
        return newPatch.Active__c != oldPatch.Active__c || newPatch.ProcessingSequence__c != oldPatch.ProcessingSequence__c || newPatch.Rule_Logic__c != oldPatch.Rule_Logic__c;
    }
    
    private Boolean hasSequenceUpdated(Patch__c newPatch, Patch__c oldPatch)
    {
        return newPatch.ProcessingSequence__c != oldPatch.ProcessingSequence__c;
    }
    
    private void refreshTimestamp(Decimal processingSequence)
    {
        List<Patch__c> patches = [select Id from Patch__c where ProcessingSequence__c > :processingSequence];
        for(Patch__c p : patches)
        {
            p.Timestamp__c = DateTime.now();
        }
        Database.update(patches, false);
    }
}