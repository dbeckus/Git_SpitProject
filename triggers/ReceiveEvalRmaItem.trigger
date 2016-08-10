/*
 * If RMA Item on an Eval RMA is changed status="Received", updates the Asset to status "Silver Peak Inventory".
 * Also, unlinks the asset from POC Request.
 */
trigger ReceiveEvalRmaItem on RMA_Item__c (after update) 
{
    Set<Id> assetIds = new Set<Id>();
    Set<Id> rmaIds = new Set<Id>();
    
    for(RMA_Item__c item : Trigger.new)
    {
        if(item.RecordTypeId == PocRequestAutomationHelper.EvalRMAItemRecordTypeId)
        {
            RMA_Item__c oldItem = Trigger.oldMap.get(item.Id);
            if(item.Status__c == 'Received' && item.Status__c != oldItem.Status__c)
            {
                assetIds.add(item.Asset__c);
                rmaIds.add(item.RMA__c);
            }
        }
    }
    if(assetIds.size() > 0)
    {
        try
        {
            PocRequestAutomationHelper.removePocLinkOnAssetAndSetStatus(assetIds);
        }
        catch(PocRequestAutomationHelper.PocRequestAutomationException ex)
        {
            for(RMA_Item__c item : Trigger.new)
            {
                item.addError(ex.getMessage());
            }
        }
    }
}