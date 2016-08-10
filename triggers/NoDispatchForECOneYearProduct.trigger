trigger NoDispatchForECOneYearProduct on RMA__c (after update) {
    List<RMA__c> lstRMAs =[Select Id, (select Id from RMALines__r) from RMA__c where Id in :Trigger.newMap.keyset()];
    Set<id> rmaIds= new Set<Id>();
    for(RMA__c item :lstRMAs)
    {
         
        RMA__c newRMA= Trigger.newMap.get(item.Id);
        RMA__c oldRMA= Trigger.oldMap.get(item.Id);
        
        if(oldRMA.Status__c!= newRMA.Status__c && newRMA.Status__c== 'Dispatched') 
        {
            
            rmaIds.add(item.Id);
        }
    }
    Profile profile = [Select Id from Profile where Name='9-Operations Manager' Limit 1];
    List<RMA__c> finalRMAToUpdate = new List<RMA__c>();
    if(rmaIds.size()>0)
    {
        for(Id rmaId :rmaIds)
        {
            List<RMA_Item__c> lstRMAItems =[Select Id, Product2__r.Name from RMA_Item__c where  RMA__c = :rmaId and Product2__r.Name like 'EC-%' and Product2__r.Family = 'Product' and Asset__r.Status='Customer Owned'];
            
            if(lstRMAItems!=null && lstRMAItems.size()>0)
            {
                string[] prodName = lstRMAItems[0].Product2__r.Name.split('-');
              
                if(prodName!=null && prodName.size()==2)
                {
                    // Only operations Manager can dispatch the EC-M products.
                   
                    if(UserInfo.getProfileId()!=profile.Id)
                    {
                       
                        // Change the status to Initated
                        finalRMAToUpdate.add(new RMA__C(Id =rmaId,Status__c= 'Initated'));
                        
                        
                    }
                }
            }
        }
    }
    if(finalRMAToUpdate.size()>0)
        update finalRMAToUpdate;
}