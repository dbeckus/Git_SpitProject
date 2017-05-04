trigger SetApprovalLevelOnQuoteLine on Quote_Line__c (before insert,before update) {
    
    for(Quote_Line__c quoteLine : Trigger.new)
    {
        decimal isMaintainance=quoteLine.Include4ServiceDiscount__c;
        decimal maintYear=quoteLine.Maint_Year_Value__c;
        string prodType=isMaintainance==1.00?'Maintainance':quoteLine.Product_Quote_Type__c;
        string prodSubType=quoteLine.Product_Quote_Type__c;
        decimal discount=quoteLine.Discount_Spread__c;
        List<Quote_Discount_Matrix__c> lstData=new List<Quote_Discount_Matrix__c>();
        System.debug('isMaintainance'+isMaintainance);
        System.debug('maintYear'+maintYear);
        System.debug('prodType'+prodType);
        System.debug('prodSubType'+prodSubType);
        System.debug('prodName'+quoteLine.Product__c);
         System.debug('discount'+discount);
         System.debug('reseller discount'+quoteline.Reseller_Discount__c);
        if(isMaintainance==1)
        {
            lstData=[Select Level__c from Quote_Discount_Matrix__c where Product_Type__c=:prodType and Sub_Type__c=:prodSubType and Year__c=:maintYear and Start_Discount__c<:discount and End_Discount__c>=:discount];
        }
        else
        {
            lstData=[Select Level__c from Quote_Discount_Matrix__c where Product_Type__c=:prodType and Start_Discount__c<:discount and End_Discount__c>=:discount];
        }
        if(lstData.size()>0)
        {
            quoteline.ApprovalLevel__c=lstData[0].Level__c;
        }
        else
        {
             quoteline.ApprovalLevel__c=3;
        }
       
        
        
    } 
}