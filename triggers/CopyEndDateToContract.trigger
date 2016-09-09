/*
 * Copy Opp's Projected End Date to master contract
 * we want to wait until subscription is created 
 */
trigger CopyEndDateToContract on SBQQ__Subscription__c (after insert) 
{
    Map<Id, Date> contractId2Date = new Map<Id, Date>();
    //List<SBQQ__Subscription__c> subscriptions = [select Id, SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__Quote__r.Projected_End_Date__c from SBQQ__Subscription__c where Id in :Trigger.new and SBQQ__Contract__r.SBQQ__MasterContract__c=true and SBQQ__Contract__r.SBQQ__Opportunity__r.IsWon=true];
    List<SBQQ__Subscription__c> subscriptions = [select Id, SBQQ__Contract__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.Projected_End_Date__c from SBQQ__Subscription__c where Id in :Trigger.new and SBQQ__Contract__r.SBQQ__MasterContract__c=true and SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.IsWon=true];
    for(SBQQ__Subscription__c sub : subscriptions)
    {
        //contractId2Date.put(sub.SBQQ__Contract__c, sub.SBQQ__Contract__r.SBQQ__Quote__r.Projected_End_Date__c);
        contractId2Date.put(sub.SBQQ__Contract__c, sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Projected_End_Date__c);
    }
    if(contractId2Date.size() > 0)
    {
        List<Contract> updatingContracts = new List<Contract>();
        for(Id contractId : contractId2Date.keyset())
        {
            updatingContracts.add(new Contract(Id=contractId, EndDate=contractId2Date.get(contractId)));
        }
        Database.update(updatingContracts, true);
    }
    
}