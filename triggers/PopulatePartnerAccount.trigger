/*
 * On opportunity to closed won, copy and populate partner account from master quote.
 */
trigger PopulatePartnerAccount on Opportunity (before update) 
{
    List<Opportunity> closedWons = new List<Opportunity>();
    for(Opportunity opp : Trigger.new)
    {
        Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
        if(opp.IsWon && !oldOpp.IsWon)
        {
            closedWons.add(opp);
        }
    }
    
    if(closedWons.size() > 0)
    {
        Map<Id, Id> oppId2DistributorId = new Map<Id, Id>();
        Map<Id, Id> oppId2ResellerId = new Map<Id, Id>();
        for(Opportunity opp : [select Id, Registering_Partner__c, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__Distributor__c, SBQQ__PrimaryQuote__r.Reseller_Partner__c from Opportunity where Id in :closedWons])
        {
            oppId2DistributorId.put(opp.Id, opp.SBQQ__PrimaryQuote__r.SBQQ__Distributor__c);
            oppId2ResellerId.put(opp.Id, opp.SBQQ__PrimaryQuote__r.Reseller_Partner__c);
        }
        for(Opportunity opp : closedWons)
        {
            Id resellerId = oppId2ResellerId.get(opp.Id);
            Id distributorId = oppId2DistributorId.get(opp.Id);
            if(resellerId != null && distributorId == null)
            {
                opp.Primary_Partner__c = resellerId;
            }
            else if(distributorId != null)
            {
                opp.Primary_Partner__c = distributorId;
            }
        }
    }
}