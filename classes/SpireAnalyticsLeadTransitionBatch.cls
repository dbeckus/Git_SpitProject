global class SpireAnalyticsLeadTransitionBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
           new SpireAnalyticsLeadTransitionBatch().run();         
    }
    global void run() {
       
        //###################################################
        // Lead Transition Analytics
        //###################################################
        Id analytics30 = Database.executeBatch(new LeadTransitionAnalyticsIterable(30));                
        Id analytics90 = Database.executeBatch(new LeadTransitionAnalyticsIterable(90)); 
        Id analytics180 = Database.executeBatch(new LeadTransitionAnalyticsIterable(180)); 
        //Id analytics365 = Database.executeBatch(new LeadTransitionAnalyticsIterable(365));  
    }
}