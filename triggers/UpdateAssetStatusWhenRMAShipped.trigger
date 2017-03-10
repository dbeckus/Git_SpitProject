trigger UpdateAssetStatusWhenRMAShipped on RMA__c (after update) {
    /*List<Asset> lstAsset= new List<Asset>();
    for(RMA__c item:Trigger.New)
    {
        if(item.Status__c=='Shipped' && item.Type__c=='Convert to Virtual')
        {
            lstAsset=[Select Id from Asset where Id in(Select Asset__c from RMA_Item__c where RMA__c=:item.Id) and Product2.Family='Product'];
        }
    }
    if(lstAsset.size()>0)
    {
        for(Asset item: lstAsset)
        {
            item.Status='Pending Return – Conversion';
        }
        
        update lstAsset;
    }*/
    
}