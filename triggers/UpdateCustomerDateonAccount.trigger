trigger UpdateCustomerDateonAccount on Asset (after insert,after update) {
    Set<Id> setECAcctIds= new Set<Id>();
    Set<Id> setWanOpAcctIds= new Set<Id>();
    if(Trigger.isInsert)
    {
        for(Asset counter: Trigger.New)
        {
            if(counter.AccountId!=null && counter.Status!='Customer Evaluation' && counter.Ship_Date__c!=null)
            {
                if(((counter.Product_Quote_Type__c=='EDGECONNECT'|| counter.Product_Quote_Type__c=='EC-SP-Perpetual' || counter.Product_Quote_Type__c=='EC-SP-Metered') && counter.Product_Family__c=='Virtual Image' ) || counter.Product_Quote_Type__c=='NX/VX' )
                { 
                    if(counter.Product_Quote_Type__c=='NX/VX' && (counter.Wan_Op_Customer_Date__c ==null ||  (counter.Wan_Op_Customer_Date__c!=null && counter.Ship_Date__c < counter.Wan_Op_Customer_Date__c)))
                        setWanOpAcctIds.add(counter.AccountId);
                    else if((counter.EC_Customer_Date__c ==null ||  (counter.EC_Customer_Date__c!=null && counter.Ship_Date__c < counter.EC_Customer_Date__c)))
                        setECAcctIds.add(counter.AccountId); 
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
                    if(counter.Product_Quote_Type__c=='NX/VX' && (counter.Wan_Op_Customer_Date__c ==null ||  (counter.Wan_Op_Customer_Date__c!=null && counter.Ship_Date__c < counter.Wan_Op_Customer_Date__c)))
                        setWanOpAcctIds.add(counter.AccountId);
                    else if((counter.EC_Customer_Date__c ==null ||  (counter.EC_Customer_Date__c!=null && counter.Ship_Date__c < counter.EC_Customer_Date__c)))
                        setECAcctIds.add(counter.AccountId); 
                }
            }
        } 
    }
    
    System.debug('setWanOpAcctIds'+setWanOpAcctIds);
    System.debug('setECAcctIds'+setECAcctIds);
    AssetHelper.CalculateCustomerDate(setECAcctIds,setWanOpAcctIds);
    
    
    
}