trigger CalculateContractedAmounts on OpportunityLineItem (before insert,before update) {
    
    for(OpportunityLineItem lineItem: Trigger.New)
    { 
        decimal totalPrice= lineItem.UnitPrice!=null?(lineItem.UnitPrice*lineItem.Quantity):0;
        lineItem.Annual_Contract_Value_ACV__c= lineItem.Product_Length_in_Years__c>1?(totalPrice/lineitem.Product_Length_in_Years__c):totalPrice;
        lineItem.Net_Contract_Value_NCV__c=totalPrice-lineItem.Annual_Contract_Value_ACV__c;
        lineItem.Total_Currency_Value_TCV__c=totalPrice;
    }

}