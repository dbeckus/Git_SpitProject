trigger CalculateCompensationAmounts on OpportunityLineItem (before update) {
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
         
            lineItem.Total_Comp_Rate__c=0;
            lineItem.Comp_Rate1__c=0;
            lineItem.Comp_Rate2__c=0;
            decimal totalPrice= lineItem.UnitPrice!=null?(lineItem.UnitPrice*lineItem.Quantity):0;
            System.debug(totalPrice);
            if((lineItem.Quote_Type__c=='EDGECONNECT'|| lineItem.Quote_Type__c=='EC-SP-Term')&& lineitem.Product_Family__c=='Virtual Image' )
            {
                
                lineItem.Total_Comp_Rate__c =lineItem.Is_Total_Comp_Rate_Enabled__c?totalPrice:0;
                lineItem.Comp_Rate1__c= lineItem.Is_Comp_Rate1_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Comp_Rate2__c=lineItem.Is_Comp_Rate2_Enabled__c?(totalPrice-lineItem.Comp_Rate1__c):0;
            }
            else if(lineItem.Quote_Type__c=='EDGECONNECT'&& lineitem.Product_Family__c=='Product')
            {
                decimal discount42PercentPrice= lineItem.Quantity >1?(lineItem.ListPrice -(lineItem.ListPrice*0.42))*lineItem.Quantity:lineItem.ListPrice -(lineItem.ListPrice*0.42);
                System.debug('lineItem.Quantity '+lineItem.Quantity);
                System.debug('discount42PercentPrice '+ discount42PercentPrice);
                decimal finalValue= lineItem.DiscountPercent__c>42?(totalPrice-discount42PercentPrice):totalPrice;
                System.debug('finalValue'+ finalValue);
                lineItem.Total_Comp_Rate__c=0;
                lineItem.Comp_Rate1__c=0;
                lineItem.Comp_Rate2__c=0;
                if(lineItem.DiscountPercent__c>42)
                {
                    lineItem.Total_Comp_Rate__c=finalValue;
                    lineItem.Comp_Rate1__c=finalValue;
                    lineItem.Comp_Rate2__c=finalValue-lineItem.Comp_Rate1__c;
                }
                
            }
            else if((lineItem.Quote_Type__c=='EDGECONNECT'||lineItem.Quote_Type__c=='EC-SP-Term' )&& lineitem.Product_Family__c!='Product' && lineitem.Product_Family__c!='Virtual Image' )
            {
                lineItem.Total_Comp_Rate__c=lineItem.Is_Total_Comp_Rate_Enabled__c?totalPrice:0;
                lineItem.Comp_Rate1__c=lineItem.Is_Comp_Rate1_Enabled__c?(lineItem.Term__c>1?(totalPrice/lineitem.Term__c):totalPrice):0;
                lineItem.Comp_Rate2__c=lineItem.Is_Comp_Rate2_Enabled__c?(totalPrice-lineItem.Comp_Rate1__c):0;
                
                
            }
            else if(lineItem.Quote_Type__c=='NX/VX' || lineItem.Quote_Type__c=='EC-SP-Metered'|| lineItem.Quote_Type__c=='EC-SP-Perpetual')
            {
                lineItem.Total_Comp_Rate__c=lineItem.Is_Total_Comp_Rate_Enabled__c?totalPrice:0;
                lineItem.Comp_Rate1__c= lineItem.Is_Comp_Rate1_Enabled__c?0:0;
                lineItem.Comp_Rate2__c=lineItem.Is_Comp_Rate2_Enabled__c?(totalPrice-lineItem.Comp_Rate1__c):0;
            }
            
        }
    }
}