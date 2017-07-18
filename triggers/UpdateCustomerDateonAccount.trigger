trigger UpdateCustomerDateonAccount on Asset (after insert,after update) {
    Set<Id> setAcctIds= new Set<Id>();
  
    if (system.isBatch() || system.isFuture()) return;
    if(Trigger.isInsert)
    {
        for(Asset counter: Trigger.New)
        {
            
            if(counter.AccountId!=null && counter.Status!='Customer Evaluation' && counter.Ship_Date__c!=null)
            {
                if(((counter.Product_Quote_Type__c=='EDGECONNECT'|| counter.Product_Quote_Type__c=='EC-SP-Perpetual' || counter.Product_Quote_Type__c=='EC-SP-Metered') && counter.Product_Family__c=='Virtual Image' ) || counter.Product_Quote_Type__c=='NX/VX' )
                {
                    setAcctIds.add(counter.AccountId);  
                }
            }
        }
    }
    if(Trigger.isUpdate)
    {
        for(Asset counter: Trigger.New)
        {
            Asset oldAsset= Trigger.oldMap.get(counter.Id);
            if(counter.AccountId!=null && counter.Status!='Customer Evaluation' &&(counter.AccountId!=oldAsset.AccountId || counter.Ship_Date__c!=oldAsset.Ship_Date__c || counter.Status!=oldAsset.Status))
            {
                if(((counter.Product_Quote_Type__c=='EDGECONNECT'|| counter.Product_Quote_Type__c=='EC-SP-Perpetual' || counter.Product_Quote_Type__c=='EC-SP-Metered') && counter.Product_Family__c=='Virtual Image' ) || counter.Product_Quote_Type__c=='NX/VX' )
                {
                    setAcctIds.add(counter.AccountId);    
                    if(counter.AccountId!=oldAsset.AccountId)
                    {
                        setAcctIds.add(oldAsset.AccountId);    
                    }
                }
            }
        } 
    }
    
    
    if(setAcctIds.size()>0)
    {
        AssetHelper.CalculateCustomerDate(setAcctIds);
    }
    
    
}