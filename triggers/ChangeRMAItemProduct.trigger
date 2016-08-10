/**
 * replace the product of RMA item with "RMA Alternate xx" on this product when RMA status is "dispatched rejected"
 *
 * Example:
 * Asset X is of product A. 
 * Product A has replaceable HDD which is product B.
 * Product B has primary replacement, alt1, alt2 and they are product C/D/E.
 * Product A also has primary replacement, alt1, alt2 to product F/G/H.
 *
 * Assume the client wants to return the HDD of Asset X.
 * After the RMA is created, the RMA line should link to Product B UNLESS Product "B" has the Primary Replacement, if so then "C".
 * If B (or C) is rejected, then if product "B" DOES HAVE the system Alternate flag set, then next is "A" or "F"("F" if "A" has the primary replacement), then "G" for a second rejection, the "H" for the third time.
 * ELSE product "B" DOES NOT HAVE the system alternate flag set, then next is "D" then "E" for a second rejection
 */
trigger ChangeRMAItemProduct on RMA__c (after update) 
{
    List<RMA_Item__c> rejectedItems = new List<RMA_Item__c>();
    Set<Id> rmaIds = new Set<Id>();
    List<RMA__c> allRmas = [select Id, (select Id from RMALines__r) from RMA__c where Id in :trigger.newMap.Keyset()];
    for(RMA__c rma : allRmas)
    {
        if(rma.RMALines__r.size() == 1) 
        {
            rmaIds.add(rma.Id);
        }
    }
    
    RMA__c  newRma, oldRma;
    List<String> altPrdIDs = new List<String>();
    for(RMA_Item__c item : [select Id, RMA__c, Product2__c, Product2__r.Use_System_Alternative__c, Product2__r.RMA_Primary_Replacement__c, Product2__r.RMA_Alternate_1__c, Product2__r.RMA_Alternate_2__c, Asset__r.Product2Id, Asset__r.Product2.RMA_Primary_Replacement__c, Asset__r.Product2.RMA_Alternate_1__c, Asset__r.Product2.RMA_Alternate_2__c, AltProdPreviouslyOrdered__c, AltProdPreviouslyOrdered__r.Use_System_Alternative__c, AltProdPreviouslyOrdered__r.RMA_Primary_Replacement__c, AltProdPreviouslyOrdered__r.RMA_Alternate_1__c, AltProdPreviouslyOrdered__r.RMA_Alternate_2__c from RMA_Item__c where RMA__c in :rmaIds])
    {
        newRma = trigger.newMap.get(item.RMA__c);
        oldRma = trigger.oldMap.get(item.RMA__c);
        if(oldRma.Status__c != 'Dispatch Rejected' && newRma.Status__c == 'Dispatch Rejected' && hasErrorMessage(newRma.Note_Loc_1__c))
        {
            Id currentProductId = item.Product2__c;
            Id originalProductId;
            Product2 originalProduct;
            if(item.AltProdPreviouslyOrdered__c == null)
            {
                originalProductId = currentProductId;
                originalProduct = item.Product2__r;
                item.AltProdPreviouslyOrdered__c = currentProductId;
            }
            else
            {
                originalProductId = item.AltProdPreviouslyOrdered__c;
                originalProduct = item.AltProdPreviouslyOrdered__r;
            }
            List<Id> alternateProductSequence;
            if(originalProduct.Use_System_Alternative__c)
            {
                Id systemProductId = (item.Asset__r.Product2.RMA_Primary_Replacement__c == null) ? item.Asset__r.Product2Id : item.Asset__r.Product2.RMA_Primary_Replacement__c;
                alternateProductSequence = new List<Id> { originalProductId, originalProduct.RMA_Primary_Replacement__c, systemProductId, item.Asset__r.Product2.RMA_Alternate_1__c, item.Asset__r.Product2.RMA_Alternate_2__c};
            }
            else
            {
                alternateProductSequence = new List<Id> { originalProductId, originalProduct.RMA_Primary_Replacement__c, originalProduct.RMA_Alternate_1__c, originalProduct.RMA_Alternate_2__c };
            }
            
            Boolean foundCurrent = false;
            for(Id productId : alternateProductSequence)
            {
                if(currentProductId == productId)
                {
                    foundCurrent = true;
                }
                if(foundCurrent && currentProductId != productId && productId != null)
                {
                    currentProductId = productId;
                    break;
                }
            }
            item.Product2__c = currentProductId;
            rejectedItems.add(item);
        }
    }
    if(rejectedItems.size() > 0)
    {
        update rejectedItems;
    }
    
    private static Boolean hasErrorMessage(String message)
    {
        if(message == null)
        {
            return false;
        }
        List<String> errorMessages;
        if(errorMessages == null)
        {
            errorMessages = new List<String> { 'Part Number Not Found', 'Part Number Not Active', 'Insufficient QOH', 'Serial Qty Doesn\'t Match Parts Qty' };
        }
        for(String m : errorMessages)
        {
            if(message.contains(m))
            {
                return true;
            }
        }
        return false;   
    }
}