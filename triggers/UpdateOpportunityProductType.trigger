trigger UpdateOpportunityProductType on Quote__c (after update) {
    List<Quote__c> lstPrimaryQuotes= new List<Quote__c>();
    List<Quote__c> lstNotPrimaryQuotes= new List<Quote__c>();
    
    for(Quote__c item :Trigger.New) //only for the system and not a replacement product.
    {
        if(item.Primary__c != trigger.oldMap.get(item.Id).Primary__c)
        {
            if(item.Primary__c)
            {
                lstPrimaryQuotes.add(item);
                
            }
            else
            {
                lstNotPrimaryQuotes.add(item);
            }
        }
        else
        {
            if(item.Primary__c)
            {
                if(item.Number_of_Quote_Lines__c != trigger.oldMap.get(item.Id).Number_of_Quote_Lines__c)
                {
                    lstPrimaryQuotes.add(item);
                }
                
            }
        }
        
        if(lstPrimaryQuotes.size()>0)   
        {
            List<Opportunity> lstOpp= new List<Opportunity>();
            for(Quote__c primaryQuote: lstPrimaryQuotes)
            { 
                Opportunity opp= QuoteHelper.SetOpportunityProductType(primaryQuote);
                if(opp!=null)
                {
                    lstOpp.add(opp);
                }
            }
            if(lstOpp.size()>0)
            {
                update lstOpp;
            }
        }
        
        if(lstNotPrimaryQuotes.size()>0)   
        {
            List<Opportunity> lstOpp= new List<Opportunity>();
            for(Quote__c notPrimaryQuote: lstNotPrimaryQuotes)
            {
                List<Quote__c> quoteList= new List<Quote__c>();
                quoteList= QuoteHelper.GetPrimaryQuote(notPrimaryQuote.Opportunity__c);
                if(quoteList!=null && quoteList.size()==0)
                {
                   
                    Opportunity opp=  QuoteHelper.SetOpportunityProductTypeToNone(notPrimaryQuote);
                    if(opp!=null)
                    {
                        lstOpp.add(opp);
                    }
                }
            }
            if(lstOpp.size()>0)
            {
                update lstOpp;
            }
        }   
    }
}