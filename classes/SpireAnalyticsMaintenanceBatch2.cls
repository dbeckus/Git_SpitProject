global class SpireAnalyticsMaintenanceBatch2 implements Schedulable {
    global void execute(SchedulableContext sc) {
           new SpireAnalyticsMaintenanceBatch2().run();         
    }
    global void run() {
        
        //###################################################
        
        //Maintanence Renewals
        
        //###################################################
        
        String stage = 'Closed Won';
        String familyStrMR = '\'Service\'';
        String subscriptionStr ='Subscription';  
        Map<String, String> fieldsToUpdate = new Map<String, String>();
        
        //Previous VX Subscription (including SR) 
        
        Datetime startYr = Datetime.now();
        startYr = startYr.addYears(-2);
        Datetime endYr = Datetime.now();
        endYr = endYr.addYears(-1);
        
        String queryVXSubMRPrev = 'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VX%' + '\' and Opportunity.CloseDate > ' + startYr.format('yyyy-MM-dd') 
            + ' and  Opportunity.CloseDate < ' + endYr.format('yyyy-MM-dd') + ' group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Previous_VX_Subscription_and_SR__c');
        Id vxSubsMRPrevBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVXSubMRPrev, fieldsToUpdate));
        
        //Previous VRX Subscription (including SR) 
        
        String queryVRXSubMRPrev = 'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VRX%' + '\' and Opportunity.CloseDate > ' + startYr.format('yyyy-MM-dd') 
            + ' and  Opportunity.CloseDate < ' + endYr.format('yyyy-MM-dd') + ' group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Previous_VRX_Subscription_and_SR__c');
        Id vrxSubsMRPrevBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVRXSubMRPrev, fieldsToUpdate));
        
    }
}