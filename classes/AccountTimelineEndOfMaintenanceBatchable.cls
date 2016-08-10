global class AccountTimelineEndOfMaintenanceBatchable implements Database.Batchable<AggregateResult> , Database.Stateful { 
    global final List<AccountWithTimeline__c> timelineList {get; set;}
    global final Map<String, Date> endOfMaintenaceMap {get; set;}
    global final Map<String, String> endOfMaintenaceMapWithNullDates {get; set;}
    AggregateResultIterable aggr {get; set;}
    
    Integer numberOfDays {get; private set;}
    global AccountTimelineEndOfMaintenanceBatchable() {
        aggr = new AggregateResultIterable();
        endOfMaintenaceMap = new Map<String, Date>();
        endOfMaintenaceMapWithNullDates = new Map<String, String>();
        timelineList = [SELECT Id, Name__r.Name, End_Of_Maintenance__c from AccountWithTimeline__c];   
        aggr.setQuery('SELECT Account.Name Account, MAX(Contract_End__c) ContractEnd, MAX(License_Expiration__c) LicenseEnd FROM Asset where Status IN (\'Customer Owned\', \'Customer Subscription\', \'Conditional PO\', \'Cold Spare\') group by Account.Name');
    }
    global Iterable<AggregateResult> start(Database.batchableContext info){        
        return this.aggr;
        
    }
  
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        System.Debug(LoggingLevel.INFO, 'Resultset Size:' + scope.size());
        for (Sobject so : scope)  {
            AggregateResult ar = (AggregateResult) so;
            String acct = (String) ar.get('Account');    
            Date contractEnd = (Date)ar.get('ContractEnd');
            Date licenseEnd = (Date)ar.get('LicenseEnd');
            
            if(contractEnd != null && licenseEnd != null) {
                System.Debug(LoggingLevel.INFO, '##### Both Contract and license end dates same --> ' + JSON.serialize(ar) );
                endOfMaintenaceMap.put(acct, contractEnd >= licenseEnd ? contractEnd : licenseEnd);
            } else if(contractEnd != null) {
            	endOfMaintenaceMap.put(acct, contractEnd);
            } else if(licenseEnd != null) {
                endOfMaintenaceMap.put(acct, licenseEnd);
            } else {
            	System.Debug(LoggingLevel.INFO, '************* Both Contract and license end date null --> ' + acct + ', Contract End:' + contractEnd + ', License End:' + licenseEnd );
                endOfMaintenaceMapWithNullDates.put(acct, JSON.serialize(ar));
            }
            
        } 
                   
    }
 
    global void finish(Database.BatchableContext BC){
        System.Debug(LoggingLevel.INFO, 'Finishing...');
        System.Debug(LoggingLevel.INFO, 'End of Maint Map size: ' + endOfMaintenaceMap.size());
        System.Debug(LoggingLevel.INFO, 'End of Maint Map with null dates size: ' + endOfMaintenaceMapWithNullDates.size());
        System.Debug(LoggingLevel.INFO, JSON.serialize(endOfMaintenaceMapWithNullDates	));	
        
        List<AccountWithTimeline__c> updateList = new List<AccountWithTimeline__c>();
        
        for(AccountWithTimeline__c acct: timelineList) {
            //System.Debug(LoggingLevel.INFO, 'Looking for ' + acct.Name__r.Name);
        	Date endDate = endOfMaintenaceMap.get(acct.Name__r.Name);
            if(endDate != null) {
             	acct.End_Of_Maintenance__c = endDate;  
                updateList.add(acct);
            } else {
            	System.Debug(LoggingLevel.INFO, 'End Date Null: ' + JSON.serialize(acct));	
            }
                
        }
        System.Debug(LoggingLevel.INFO, 'Items to update: ' + updateList.size());
        update updateList;
    }  
    
    

}