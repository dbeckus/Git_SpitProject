global class LeadTransitionAnalyticsIterable implements Database.Batchable<sObject> , Database.Stateful { 
    global final Map<String, Map<String, Integer>> transitions {get; set;}
    global final Map<String, Map<String, Integer>> transitionsPerWeek {get; set;}
    global final String leadTransitionPrefix = 'LeadTransitions-';
    global final String leadTransitionsPerWeekPrefix = 'TranstionsPerWeek-';
    global final String leadsQuery;
    Integer numberOfDays {get; private set;}
    global LeadTransitionAnalyticsIterable(Integer numDays) {
        transitions = new Map<String, Map<String, Integer>>();
        transitionsPerWeek=  new Map<String, Map<String, Integer>>();
        //this.aggr = new LeadAggregateResultIterable();
        numberOfDays = numDays;
        leadsQuery = 'SELECT CreatedDate, Field, LeadId, NewValue, OldValue, Lead.Status FROM LeadHistory where CreatedDate = LAST_N_DAYS:' + numberOfDays + ' and Field IN (\'Status\', \'leadConverted\')';    
        //this.aggr.setQuery(query);
    }
    
    global LeadTransitionAnalyticsIterable(Integer numDays, String leadTransPrefix, String leadTransPerWeekPrefix, String queryFilters) {        
        this(numDays);        
        leadTransitionPrefix = leadTransPrefix;
        leadTransitionsPerWeekPrefix = leadTransPerWeekPrefix;
        if(queryFilters != null) {
         	leadsQuery = leadsQuery + queryFilters;   
        }
    }
    global Database.QueryLocator start(Database.batchableContext info){            
         return Database.getQueryLocator(leadsQuery);
    }
  
    Integer getWeekNumber(Datetime inputDate) {
        Datetime todaydate = inputDate;
        Date todaydateinstance = date.newinstance(todaydate.year(), todaydate.month(), todaydate.day());
        Integer currentyear = todaydate.year();
        Date startDate = date.newinstance(currentyear, 01, 01);
        integer numberDaysDue = startDate.daysBetween(todaydateinstance);
        Integer numberOfWeek = Math.mod((Integer)math.FLOOR( ( numberDaysDue )/7),52)+1;
        System.Debug(LoggingLevel.INFO, todaydate + ' - Week of ' + todaydateinstance.toStartOfWeek()); 
        return numberOfWeek;
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        System.Debug(LoggingLevel.INFO, 'Resultset Size:' + scope.size());
       
        
        //Map<String, Map<String, Integer>> transitions = new Map<String, Map<String, Integer>>();
        for (Sobject so : scope)  {
           LeadHistory ar = (LeadHistory) so;          
           String field= (String) ar.get('Field');
           
           String oldValue= (String) ar.get('OldValue');
           String newValue = (String) ar.get('NewValue');
           Datetime createdDateValue = (Datetime) ar.get('CreatedDate');
           Date dateInstance = date.newinstance(createdDateValue.year(), createdDateValue.month(), createdDateValue.day()); 
           Date startWeekDate = dateInstance.toStartOfWeek(); 
           Datetime startWeekDateTime = Datetime.newInstanceGmt(startWeekDate.year(), startWeekDate.month(),startWeekDate.day());
           String startWeekDateStr = startWeekDateTime.format('YYMMdd');
           if(field == 'leadConverted') {
                newValue = (String) ar.Lead.Status;	     
                oldValue = 'Unknown';
                //System.Debug(LoggingLevel.INFO, 'Field = leadConverted- newValue' + newValue + ', oldValue: '+ 'Unknown');
           }  
           String mapKey  = oldValue + ':' + newValue;             
           Map<String, Integer> mapValue = transitionsPerWeek.get(mapKey)  ;
           //System.Debug(LoggingLevel.INFO, 'Map value:' + mapValue + ', mapKey: '+ mapKey); 
           if(mapValue == null) {
               Map<String, Integer> item = new Map<String, Integer> ();              
               item.put(startWeekDateStr, 1);
               transitionsPerWeek.put(mapKey, item);
           } else {
               //System.Debug(LoggingLevel.INFO, 'Map value in:' + mapValue + ', mapKey: '+ mapKey); 
               Map<String, Integer> item = transitionsPerWeek.get(mapKey) ;
               if(item.get(startWeekDateStr) == null) {
                   
                   item.put(startWeekDateStr, 1);
               } else {
               		item.put(startWeekDateStr, item.get(startWeekDateStr) + 1);
               }
               //transitionsPerWeek.put(weekNumber, mapValue+1);
           }
           
           if(transitions.get(oldValue) == null) {
                Map<String, Integer> newValueMap = new Map<String, Integer>();
                newValueMap.put(newValue, 1);
                transitions.put(oldValue, newValueMap);  
                
           } else {
                Map<String, Integer> newMap = transitions.get(oldValue);
                if(newMap.get(newValue) == null ) {
                    newMap.put(newValue, 1);
                } else { 
                    Integer value = newMap.get(newValue) + 1;
                    newMap.put(newValue,value) ;
                }
           } 
               
           //System.Debug(LoggingLevel.INFO,'Old Value:' + oldValue + ', New Value:' + newValue);
        } 
        
         
            
    }
 
    global void finish(Database.BatchableContext BC){
        System.Debug(LoggingLevel.INFO, JSON.serialize(transitions));
        List<Misc_Data__c> listData = new List<Misc_Data__c>();
        Misc_Data__c data  = new Misc_Data__c();
        data.Name = leadTransitionPrefix + numberOfDays;
        data.JSON__c = JSON.serialize(transitions);
        listData.add(data);
        
        Misc_Data__c tpw  = new Misc_Data__c();
        tpw.Name = leadTransitionsPerWeekPrefix + numberOfDays;
        tpw.JSON__c = JSON.serialize(transitionsPerWeek);
        System.Debug(LoggingLevel.INFO,'JSON - Transtions: ' +  tpw.JSON__c);
        listData.add(tpw);
        
        
        insert listData;
        
        
    }  
    
    
    

}