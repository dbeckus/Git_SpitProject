trigger CalculateContractedAmounts on OpportunityLineItem (before update) {
    
    if(Trigger.IsUpdate)
    {
        for(OpportunityLineItem lineItem: Trigger.New)
        { 
            lineItem.Net_Contract_Value_NTCV__c=0;
            lineItem.Annual_Contract_Value_ACV__c=0;
            lineItem.Total_Contract_Value_TCV__c=0;
            decimal totalPrice= lineItem.UnitPrice!=null?(lineItem.UnitPrice*lineItem.Quantity):0;
            if((lineItem.Quote_Type__c=='EDGECONNECT'|| lineItem.Quote_Type__c=='EC-SP-Term' || lineItem.Quote_Type__c=='EC-SP-Metered' || lineItem.Quote_Type__c=='EC-SP-Perpetual' )&& lineitem.Product_Family__c=='Virtual Image' )
            {
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?totalPrice:0;
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Is_ACV_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Net_Contract_Value_NTCV__c=lineItem.Is_NTCV_Enabled__c?(totalPrice-lineItem.Annual_Contract_Value_ACV__c):0;
            }
            else if((lineItem.Quote_Type__c=='EDGECONNECT'|| lineItem.Quote_Type__c=='EC-SP-Perpetual' || lineItem.Quote_Type__c=='EC-SP-Term'|| lineItem.Quote_Type__c=='EC-SP-Metered')&& lineitem.Product_Family__c=='Product')
            {
                lineItem.EC_Hardware_Amount__c =totalPrice;
            }
            else if((lineItem.Quote_Type__c=='EDGECONNECT'|| lineItem.Quote_Type__c=='EC-SP-Term' || lineItem.Quote_Type__c=='EC-SP-Metered' || lineItem.Quote_Type__c=='EC-SP-Perpetual')&& lineitem.Product_Family__c!='Product' && lineitem.Product_Family__c!='Virtual Image' )
            {
                
                lineItem.Total_Contract_Value_TCV__c=lineItem.IS_TCV_Enabled__c?totalPrice:0;
                lineItem.Annual_Contract_Value_ACV__c= lineItem.Is_ACV_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Net_Contract_Value_NTCV__c=lineItem.Is_NTCV_Enabled__c?(totalPrice-lineItem.Annual_Contract_Value_ACV__c):0;
                
            }
            else if(lineItem.Quote_Type__c=='NX/VX')
            {
                if(lineItem.Quote_Type__c=='NX/VX')
                {
                    lineItem.NX_VX_Amount__c=totalPrice;
                }
            }
        }
    }
    
    
}