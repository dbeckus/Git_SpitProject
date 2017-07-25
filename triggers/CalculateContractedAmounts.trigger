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
            System.debug('lineItem.DiscountPercent__c'+lineItem.DiscountPercent__c);
            lineItem.Net_Contract_Value_NCV__c=0;
            lineItem.Annual_Contract_Value_ACV__c=0;
            
            decimal totalPrice= lineItem.UnitPrice!=null?(lineItem.UnitPrice*lineItem.Quantity):0;
            System.debug(totalPrice);
            if((lineItem.Quote_Type__c=='EDGECONNECT'||lineItem.Quote_Type__c=='EC-SP-Perpetual'||lineItem.Quote_Type__c=='EC-SP-Metered')&& lineitem.Product_Family__c=='Virtual Image' )
            {
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?totalPrice:0;
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Is_ACV_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Net_Contract_Value_NCV__c=lineItem.Is_NTCV_Enabled__c?(totalPrice-lineItem.Annual_Contract_Value_ACV__c):0;
               
            }
            else if((lineItem.Quote_Type__c=='EDGECONNECT'||lineItem.Quote_Type__c=='EC-SP-Perpetual'||lineItem.Quote_Type__c=='EC-SP-Metered')&& lineitem.Product_Family__c=='Product')
            {
                decimal discount42PercentPrice= lineItem.ListPrice -(lineItem.ListPrice*0.42);
                System.debug('discount42PercentPrice'+ discount42PercentPrice);
                decimal finalValue= lineItem.DiscountPercent__c>42?(totalPrice-discount42PercentPrice):totalPrice;
                System.debug('finalValue'+ finalValue);
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?finalValue:0;
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Is_ACV_Enabled__c?(lineItem.Term__c>1?(finalValue/lineitem.Term__c):finalValue):0;
                lineItem.Net_Contract_Value_NCV__c=lineItem.Is_NTCV_Enabled__c?(finalValue-lineItem.Annual_Contract_Value_ACV__c):0;
               
            }
            else if((lineItem.Quote_Type__c=='EDGECONNECT'||lineItem.Quote_Type__c=='EC-SP-Perpetual'||lineItem.Quote_Type__c=='EC-SP-Metered')&& lineitem.Product_Family__c!='Product' && lineitem.Product_Family__c!='Virtual Image' )
            {
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?totalPrice:0;
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Is_ACV_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Net_Contract_Value_NCV__c=lineItem.Is_NTCV_Enabled__c?(totalPrice-lineItem.Annual_Contract_Value_ACV__c):0;
               
            }
            else if(lineItem.Quote_Type__c=='NX/VX' )
            {
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?totalPrice:0;
                lineItem.Annual_Contract_Value_ACV__c =lineItem.IS_ACV_Enabled__c?0:0;
                lineItem.Net_Contract_Value_NCV__c=lineItem.Is_NTCV_Enabled__c?(totalPrice-lineItem.Annual_Contract_Value_ACV__c):0;
            }
            
        }
    }
    
    
}