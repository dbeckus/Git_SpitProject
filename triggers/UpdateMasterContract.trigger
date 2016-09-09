trigger UpdateMasterContract on SBQQ__Quote__c (before insert, before update)
{
    Set<String> acctIds = new Set<String>();
    
    for(SBQQ__Quote__c newQuote : Trigger.new)
    {
        if(Trigger.isInsert)
        {
            if(newQuote.SBQQ__Account__c != null)
            {
                acctIds.add(newQuote.SBQQ__Account__c);
            }
        }
        else if(Trigger.isUpdate)
        {
            if(newQuote.SBQQ__Account__c != null && newQuote.SBQQ__MasterContract__c == null)
            {
                acctIds.add(newQuote.SBQQ__Account__c);
            }
        }
    }   
    
    if(!acctIds.isEmpty())
    {
        Map<Id, Id> accId2Contract = new Map<Id, Id>();  
        for(Contract con : [select Id, AccountId from Contract where AccountId IN :acctIds AND SBQQ__ActiveContract__c = 1 AND SBQQ__Quote__c != null AND SBQQ__MasterContract__c = true])
        {
            accId2Contract.put(con.AccountId, con.Id);
        }
        
        for(SBQQ__Quote__c quote : Trigger.new)
        {
            if(quote.SBQQ__Account__c != null &&
               quote.SBQQ__MasterContract__c == null && 
               //quote.SBQQ__Type__c.toLowerCase() == 'co-term' &&
               quote.Product_Type__c != null && quote.Product_Type__c.toLowerCase() == 'edgeconnect'
               && accId2Contract.containsKey(quote.SBQQ__Account__c))
            {
                quote.SBQQ__MasterContract__c = accId2Contract.get(quote.SBQQ__Account__c);
            }
        }
    }
}