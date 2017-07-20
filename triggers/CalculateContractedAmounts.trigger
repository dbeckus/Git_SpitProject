trigger CalculateContractedAmounts on OpportunityLineItem (before update) {
    
    if(Trigger.IsUpdate)
    {
        for(OpportunityLineItem lineItem: Trigger.New)
        { 
            
            System.debug('lineitem.Product_Family__c'+lineitem.Product_Family__c);
            System.debug('****************************************************');
            System.debug('lineItem.ListPrice'+lineItem.ListPrice);
            System.debug('lineItem.TotalPrice'+lineItem.TotalPrice);
            System.debug('lineItem.UnitPrice'+lineItem.UnitPrice);
            
            lineItem.Net_Contract_Value_NCV__c=0;
            lineItem.Annual_Contract_Value_ACV__c=0;
            
            decimal totalPrice= lineItem.UnitPrice!=null?(lineItem.UnitPrice*lineItem.Quantity):0;
            if(lineItem.Quote_Type__c=='EDGECONNECT'&& lineitem.Product_Family__c=='Virtual Image' )
            {
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice;
                lineItem.Net_Contract_Value_NCV__c=totalPrice-lineItem.Annual_Contract_Value_ACV__c;
                lineItem.Total_Contract_Value_TCV__c=totalPrice;
            }
            if(lineItem.Quote_Type__c!='EDGECONNECT' )
            {
                lineItem.Net_Contract_Value_NCV__c=totalPrice;
                lineItem.Total_Contract_Value_TCV__c=totalPrice;
            }
            
        }
    }
    
    
}