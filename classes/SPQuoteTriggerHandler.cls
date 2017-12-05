public class SPQuoteTriggerHandler implements ITriggerHandler {
    Map<Id,ID> mapQuoteOpp= null;
    public SPQuoteTriggerHandler()
    {
        
    }
    
    public Boolean IsDisabled()
    {
        return false;
    }
    public void BeforeInsert(List<SObject> newItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for(Quote__c newQuote: (List<Quote__c>)newItems)
            {
                if(newQuote.Tier_2_Partner__c!=null && newQuote.Assigned_Distributor__c!=null)
                {
                    string distInfo=newQuote.Assigned_Distributor__c;
                    string[] splitDistInfo= distInfo.split('\\|');
                 
                    if(newQuote.Tier_2_Partner__c!=splitDistInfo[0])
                        newQuote.Tier_2_Partner__c.addError('Tier 2 partner is not a valid distributor.'+ string.format('Please select {0} value.',new string[]{splitDistInfo[1]}) );
                }
            }
        }
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {
        if(newItems!=null && newItems.size()>0)
        {
            for(Id quoteId: newItems.keyset())
            {
                Quote__c newQuote= (Quote__c)newItems.get(quoteId);
                Quote__c oldQuote= (Quote__c)oldItems.get(quoteId);
                /*if(newQuote.Opportunity__c!=oldQuote.Opportunity__c && CheckInvalidPriceBook(new Set<Id>{newQuote.Opportunity__c,oldQuote.Opportunity__c}))	                {
newQuote.addError('The pricebook of the new opportunity does not match with the current opportunity pricebook.' );
}*/
                if((newQuote.Tier_1_Partner__c!=oldQuote.Tier_1_Partner__c || newQuote.Tier_2_Partner__c!=oldQuote.Tier_2_Partner__c) && newQuote.Tier_2_Partner__c!=null && newQuote.Assigned_Distributor__c!=null)
                {
                    string distInfo=newQuote.Assigned_Distributor__c;
                    string[] splitDistInfo= distInfo.split('\\|');
                   
                    if(newQuote.Tier_2_Partner__c!=splitDistInfo[0])
                        newQuote.Tier_2_Partner__c.addError('Tier 2 partner is not a valid distributor.'+ string.format('Please select {0} value.',new string[]{splitDistInfo[1]}) );
                }
            }
            
        }
    }
    public void BeforeDelete(Map<Id,SObject> oldItems) 
    {
        
    }
    public void AfterInsert(Map<Id, SObject> newItems) 
    {
        mapQuoteOpp= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for(Id quoteId:newItems.keyset())
            {
                Quote__c quoteInfo=(Quote__c)newItems.get(quoteId);
                if(quoteInfo.Primary__c && quoteInfo.Opportunity__c!=null)
                {
                    mapQuoteOpp.put(quoteInfo.Id,quoteInfo.Opportunity__c);
                }
            }
            
            CheckPrimaryFlag();
        }
    }
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) 
    {     
        List<Quote__c> lstPrimaryQuotes= new List<Quote__c>();
        List<Quote__c> lstNotPrimaryQuotes= new List<Quote__c>();
        mapQuoteOpp= new Map<Id,Id>();
        if(newItems!=null && newItems.size()>0)
        {
            for (Id quoteId : newItems.keyset())
            {
                Quote__c newQuote= (Quote__c)newItems.get(quoteId);
                Quote__c oldQuote= (Quote__c)oldItems.get(quoteId);
                
                if(newQuote.Primary__c!=oldQuote.Primary__c)
                {
                    if(newQuote.Primary__c)
                    {
                        lstPrimaryQuotes.add(newQuote);
                        if(newQuote.Opportunity__c!=null)
                            mapQuoteOpp.put(newQuote.Id,newQuote.Opportunity__c);                        
                    }
                    else
                    {
                        lstNotPrimaryQuotes.add(newQuote);
                    }
                }
                else
                {
                    if(newQuote.Primary__c)
                    {
                        if(newQuote.Number_of_Quote_Lines__c != oldQuote.Number_of_Quote_Lines__c)
                        {
                            lstPrimaryQuotes.add(newQuote);
                        }
                        
                    }
                }
                
            }
            CheckPrimaryFlag();
            SetProductType(lstPrimaryQuotes,lstNotPrimaryQuotes);
        }
        
    }
    public void AfterDelete(Map<Id, SObject> oldItems) 
    {
        
    }
    public void AfterUndelete(Map<Id, SObject> newItems) 
    {
        
    }
  /*  private boolean CheckInvalidPriceBook(Set<Id> lstOppId)
    {
        List<Opportunity> lstOpp=[Select PriceBook2Id from Opportunity where Id in:lstOppId];
        Set<Id> lstPB= new Set<Id>();
        for(Opportunity opp: lstOpp)
        {
            lstPB.add(opp.Pricebook2Id);
        }
        if(lstPB.size()>0 && lstPB.size()>1)
        {
            return true;
        }
        return false;
    }  */  
    private void CheckPrimaryFlag()
    {
        if(mapQuoteOpp!=null && mapQuoteOpp.size()>0)
        {
            List<Quote__c> existingPrimaryQuotes = [Select Id from Quote__c where Opportunity__c in :mapQuoteOpp.values() and Id not in:mapQuoteOpp.keySet() and Primary__c=true];
            if(existingPrimaryQuotes!=null && existingPrimaryQuotes.size()>0)
            {
                for(Quote__c existingPrimaryQuote : existingPrimaryQuotes)
                {
                    existingPrimaryQuote.Primary__c = false;
                }
                try
                {
                    update existingPrimaryQuotes;
                }
                catch(Exception ex)
                {
                    Trigger.new[0].addError(ex.getMessage());
                }
            }
        }
    }
    private void SetProductType(List<Quote__c> lstPrimaryQuotes, List<Quote__c> lstNotPrimaryQuotes)
    {
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