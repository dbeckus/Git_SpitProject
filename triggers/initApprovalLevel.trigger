/**
   Updates ApproavalLevel field on QuoteLine according to the field 'Type' and 'Discount' on QuoteApprovalMatrix.
 **/
trigger initApprovalLevel on Quote_Line__c (before insert, before update) 
{
    for(Quote_Line__c quoteLine : Trigger.new)
    {
        Decimal level = 0;
        for(QuoteApprovalMatrix__c qaMax : QuoteApprovalMatrix__c.getAll().values())
        {
            if(quoteLine.ApprovalType__c == qaMax.Type__c && quoteLine.Discount_Percent__c > qaMax.Discount__c )
            {
                if(level < = qaMax.Level__c)
                {
                    quoteLine.ApprovalLevel__c = qaMax.Level__c;
                    level = qaMax.Level__c;
                }
            }
        }
    } 
}