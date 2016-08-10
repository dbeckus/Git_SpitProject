global class SpireAnalyticsMaintenanceBatch1 implements Schedulable {
    global void execute(SchedulableContext sc) {
           new SpireAnalyticsMaintenanceBatch1().run();         
    }
    global void run() {
        //###################################################
        
        //Maintanence Renewals
        
        //###################################################
        
        // Current Perpertual VX maintenance/MR $
        String stage = 'Closed Won';
        String familyStrMR = '\'Service\'';
        String subscriptionStr ='Subscription';  
        Map<String, String> fieldsToUpdate = new Map<String, String>();
        
        String queryVXMR = 
              'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' 
              + stage + '\' and (PriceBookEntry.Product2.Family IN (' 
              + familyStrMR   + ') and PriceBookEntry.Product2.Product_Category__c != \''
              + subscriptionStr + '\' ) and PriceBookEntry.Product2.Name like \'' + 'VX%' 
              + '\' and Opportunity.CloseDate = LAST_N_DAYS:365 group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Current_Perpetual_VX_Maintenance_and_MR__c');
        Id vxPerpMRBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVXMR, fieldsToUpdate));
        
        // Current Perpertual VRX maintenance/MR $
        String queryVRXMR = 
              'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' 
              + stage + '\' and (PriceBookEntry.Product2.Family IN (' 
              + familyStrMR   + ') and PriceBookEntry.Product2.Product_Category__c != \''
              + subscriptionStr + '\' ) and PriceBookEntry.Product2.Name like \'' + 'VRX%' 
              + '\' and Opportunity.CloseDate = LAST_N_DAYS:365 group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Current_Perpetual_VRX_Maintenance_and_MR__c');
        Id vrxPerpMRBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVRXMR, fieldsToUpdate));
        
     
        // Current NX maintenance/MR  
        
        
        String nxfamilyStrMR = '\'Service\'';
        String nxStr ='NX%';
        String queryNXMR = 'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Family IN (' +
            nxfamilyStrMR   + ') and PriceBookEntry.Product2.Name like \'' + nxStr  + '\' and Opportunity.CloseDate = LAST_N_DAYS:365 group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Current_NX_Maintenance_and_MR__c');        
        Id nxMRSalesBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryNXMR, fieldsToUpdate));
        
        
        //Current VX Subscription (including SR) 
        
        String queryVXSubMR = 'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VX%' + '\' and Opportunity.CloseDate = LAST_N_DAYS:365 group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Current_VX_Subscription_and_SR__c');
        Id vxSubsMRBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVXSubMR, fieldsToUpdate));
        
        // Current VRX Subscription (including SR)  
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'Current_VRX_Subscription_and_SR__c');
        String queryVRXSubMR = 'SELECT SUM(TotalPrice) Sales, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VRX%' + '\' and Opportunity.CloseDate = LAST_N_DAYS:365 group by Opportunity.Account.Name';
        
        Id vrxSubsMRBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVRXSubMR, fieldsToUpdate));
        
    }
}