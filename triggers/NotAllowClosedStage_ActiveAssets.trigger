trigger NotAllowClosedStage_ActiveAssets on Opportunity (before update) {
    Set<Id> setOppIds= new Set<Id>();
    
    for(Opportunity item: Trigger.New)
    {
        Opportunity oldOpp = Trigger.OldMap.get(item.Id);
        if((item.StageName=='Closed Dead'|| item.StageName=='Closed Lost' || item.StageName=='Closed Deleted')&& item.StageName!=oldOpp.StageName)
        {
            setOppIds.add(item.Id);
        }
    }
    
    List<Asset> lstAssets=[Select Id,POCRequest__r.Opportunity__c from Asset where Product2.Family='Product' and POCRequest__c  in (Select Id from Request__c where Opportunity__c in :setOppIds)];
    setOppIds= new Set<Id>();
    if(lstAssets!=null && lstAssets.size()>0)
    {
        for(Asset asset: lstAssets)
        {
            setOppIds.add(asset.POCRequest__r.Opportunity__c);
        }
    }
    
    for(Opportunity item: Trigger.New)
    {
        if(setOppIds.size()>0 && setOppIds.contains(item.Id))
        {
            item.addError('This selected stage cannot be updated as it has active physical assets.');
            
        }
    }
    
}