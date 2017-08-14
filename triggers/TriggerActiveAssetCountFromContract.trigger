trigger TriggerActiveAssetCountFromContract on Contract (after update) {
    Set<Id> contractIds= new Set<Id>();
    List<Asset> assetsToUpdate= new List<Asset>();
    
    //isUpdate
    for(Contract con : Trigger.new)
    {
        Contract oldContract = Trigger.oldMap.get(con.Id);
        if(oldContract.Status != con.Status)
        {
            if(con.AccountId != null && con.Contract_Type__c!='Evaluation')
            {
                contractIds.add(con.Id);
            }
        }
        
    }
    
    if(contractIds.size() > 0)
    {
        List<Asset> lstAsset =[Select Id from Asset where Contract_Number__c in:contractIds];
        for(Asset counter: lstAsset)
        {
            assetsToUpdate.add(new Asset(Id = counter.Id, Is_Customer_Asset__c=true));
        }
        
    }
    if(assetsToUpdate.size()>0)
    {
        update assetsToUpdate;
    }
    
}