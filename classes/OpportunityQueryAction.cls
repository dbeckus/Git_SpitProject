public class OpportunityQueryAction {
    
    @InvocableMethod(label='Updates Opp Amounts' description='Updates the ECSP Hardware and Software for SP.')
    public static void UpdateECSPAmounts(List<Opportunity> lstOpps) {
        Map<Id,decimal> hdwrAmt= new Map<id,decimal>();
        Map<Id,decimal> sfwrAmt= new Map<id,decimal>();
        Set<Id> lstOppIds= new Set<Id>();
         List<Opportunity> lstOpp= new List<Opportunity>();
        for(Opportunity item: lstOpps)
        {
            
            AggregateResult[] groupedResults=[Select OpportunityId oppId,Product2.Family family,SUM(Expected_Amount__c)sumAmt from OpportunityLineItem where OpportunityId=:item.Id and Product2Id in(Select Id from Product2 where Family in('Virtual Image','Product')) GROUP BY OpportunityId,Product2.Family ];
            if(groupedResults!=null && groupedResults.size()>0)
            {
                for (AggregateResult ar : groupedResults)  {
                    decimal amt = (decimal)ar.get('sumAmt');
                   	System.debug('amt'+amt);
                    string prodFamily= (string)ar.get('family');
                    Id oppId= (Id)ar.get('oppId');
                    lstOppIds.add(oppId);
                    if(prodFamily=='Virtual Image')
                    {
                        sfwrAmt.put(oppId,amt);
                    }
                    else if(prodFamily=='Product')
                    {
                        hdwrAmt.put(oppId,amt);
                    }
                    
                }
            }
            
        }
        
        if(lstOppIds.size()>0)
        {
            for(Id item: lstOppIds)
            {
                lstOpp.add(new Opportunity(Id=item,HDWR_AMT__c= hdwrAmt.get(item)==null?0:hdwrAmt.get(item) ,Sfwr_Amt__c=sfwrAmt.get(item)==null?0:sfwrAmt.get(item)));
            }
            
            update lstOpp;
            
        }
        
    }
    
    
}