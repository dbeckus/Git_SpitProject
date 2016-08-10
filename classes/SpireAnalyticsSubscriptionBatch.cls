global class SpireAnalyticsSubscriptionBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
           new SpireAnalyticsSubscriptionBatch().run();         
    }
    public void run() {
        
        String app = 'VX%';
        String stage = 'Closed Won';
        String familyStr = '\'Virtual Image\',\'Upgrade\', \'Service\'';
        String subscriptionStr ='Subscription'  ;
        //Total Perpetual VX Sales (including MR)
        String queryVX = 
              'SELECT SUM(TotalPrice) Sales, MIN(Opportunity.CloseDate) CloseDate, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' 
              + stage + '\' and (PriceBookEntry.Product2.Family IN (' 
              + familyStr   + ') and PriceBookEntry.Product2.Product_Category__c != \''
              + subscriptionStr + '\' ) and PriceBookEntry.Product2.Name like \'' + 'VX%' 
              + '\' group by Opportunity.Account.Name';
        Map<String, String> fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'VX_Perpetual_Sales__c');
        fieldsToUpdate.put('CloseDate', 'First_VX_Perp_Order__c');
        Id vxPerpBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVX, fieldsToUpdate));
        
        
        //Total Perpetual VRX Sales (including MR)
        String queryVRX = 
              'SELECT SUM(TotalPrice) Sales, MIN(Opportunity.CloseDate) CloseDate, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' 
              + stage + '\' and (PriceBookEntry.Product2.Family IN (' 
              + familyStr   + ') and PriceBookEntry.Product2.Product_Category__c != \''
              + subscriptionStr + '\' ) and PriceBookEntry.Product2.Name like \'' + 'VRX%' 
              + '\' group by Opportunity.Account.Name';
        
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'VRX_Perpetual_Sales__c');
        fieldsToUpdate.put('CloseDate', 'First_VRX_Perp_Order__c');
        Id vrxPerpBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVRX, fieldsToUpdate));
        
        //Total Subscription VX Sales (including SR) 
        
        String queryVXSub = 'SELECT SUM(TotalPrice) Sales,MIN(Opportunity.CloseDate) CloseDate, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VX%' + '\' group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'VX_Subscription_Sales__c');
        fieldsToUpdate.put('CloseDate', 'First_VX_Subs_Order__c');
        Id vxSubsBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVXSub, fieldsToUpdate));
        
        // Total Subscription VRX Sales (including SR) 
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'VRX_Subscription_Sales__c');
        fieldsToUpdate.put('CloseDate', 'First_VRX_Subs_Order__c');
        String queryVRXSub = 'SELECT SUM(TotalPrice) Sales, MIN(Opportunity.CloseDate) CloseDate, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Product_Category__c = \'' +
            subscriptionStr   + '\' and PriceBookEntry.Product2.Name like \'' + 'VRX%' + '\' group by Opportunity.Account.Name';
        
        Id vrxSubsBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryVRXSub, fieldsToUpdate));
        
        // Total NX Sales 
        
        String nxProductCategory = 'Appliance'; 
        String nxfamilyStr = '\'Product\', \'Service\'';
        String queryNX = 'SELECT SUM(TotalPrice) Sales, MIN(Opportunity.CloseDate) CloseDate, Opportunity.Account.Name AccountName FROM OpportunityLineItem where Opportunity.StageName=\'' + stage + '\' and PriceBookEntry.Product2.Family IN (' +
            nxfamilyStr   + ') and PriceBookEntry.Product2.Product_Category__c = \'' + nxProductCategory  + '\' group by Opportunity.Account.Name';
        fieldsToUpdate = new Map<String, String>();
        fieldsToUpdate.put('Sales', 'NX_Sales__c');
        fieldsToUpdate.put('CloseDate', 'First_NX_Order__c');
        
        Id nxSalesBatch= Database.executeBatch(new SubscriptionAnalyticsIterable(queryNX, fieldsToUpdate));
        
        
        
    }
}