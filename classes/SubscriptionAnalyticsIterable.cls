global class SubscriptionAnalyticsIterable implements Database.Batchable<AggregateResult> {   
    Map<String, String> fields {get; set;}
    AggregateResultIterable aggr {get; set;}
    
    global SubscriptionAnalyticsIterable(String queryStr, Map<String, String> fieldNames) {
        this.aggr = new AggregateResultIterable();
        fields = fieldNames;
        this.aggr.setQuery(queryStr);
    }
    global Iterable<AggregateResult> start(Database.batchableContext info){
        
        return this.aggr;
    }
 
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        
        Map <String, Summary> AccountsToSalesMap = new Map <String, Summary>();
        for (Sobject so : scope)  {
           AggregateResult ar = (AggregateResult) so;          
           Summary s = new Summary(ar);                              
       	   AccountsToSalesMap.put(s.AccountName, s);
        } 
        //System.Debug(LoggingLevel.INFO,'Accounts with Sales:' +  String.join(AccountsToSalesMap.keySet(), ','));
        Map <String, Account> AllAccountsMap = new Map <String, Account>();
        for (Account a : [SELECT Id, Name FROM Account]) {
            AllAccountsMap.put(a.Name, a);           
        }
        
        System.Debug(LoggingLevel.INFO,'Accounts with Sales:' +  String.join(new List<String>(AccountsToSalesMap.keySet()), ';'));
        List<AccountWithTimeline__c> acctList = new List<AccountWithTimeline__c>();
        List<String> accttimelineList = new List<String>();
        List<String> accttimelineListNot = new List<String>();
        System.Debug(LoggingLevel.INFO, 'Field : ' + String.join(new List<String>(fields.keySet()), ',')  + ', ResultSet Size:' +scope.size());
        
        for (AccountWithTimeline__c a : [Select Name__r.Name, VX_Perpetual_Sales__c, VRX_Perpetual_Sales__c, First_VX_Subs_Order__c, 
                                         First_VX_Perp_Order__c,
                                         NX_Sales__c, VX_Subscription_Sales__c, VRX_Subscription_Sales__c from AccountWithTimeline__c]) {
            
            if(AccountsToSalesMap.get(a.Name__r.Name)!= null) {
                //System.Debug(LoggingLevel.INFO,'Account Sales:' +  a.Name__r.Name + ': ' + AccountsToSalesMap.get(a.Name__r.Name));
                
                //if(field == 'VX_Subscription_Sales__c') {
                //    System.Debug(LoggingLevel.INFO, 'Field:' + field + ', Account: ' + a.Name__r.Name + ', Sales:' + AccountsToSalesMap.get(a.Name__r.Name));
            	//}
                //a.put(field , 0.0);
                Summary s = AccountsToSalesMap.get(a.Name__r.Name);
                for (String fieldName : fields.keySet()){
            		//System.debug('field name is ' + fieldName);                    
                    Object value = s.ar.get(fieldName);
                    String fld = fields.get(fieldName);
                    a.put(fld, value);
					//a.put(fld , 0.0);                    
        		}
               
                acctList.add(a);
                accttimelineList.add(a.Name__r.Name);
                AccountsToSalesMap.remove(a.Name__r.Name);
            } else {
            	accttimelineListNot.add(a.Name__r.Name);
            }
        }
        //System.Debug(LoggingLevel.INFO,'Account Remaining: ' +  String.join(new List<String>(AccountsToSalesMap.keySet()), ';'));
        //System.Debug(LoggingLevel.INFO,'Account Timeline with Sales:' +  String.join(accttimelineList, ';'));
        //System.Debug(LoggingLevel.INFO,'Not Account Timeline with Sales:' +  String.join(accttimelineListNot, ';'));
        //if(field == 'VX_Subscription_Sales__c') System.Debug(LoggingLevel.INFO, JSON.serialize(acctList));
        update acctList;    
            
    }
 
    global void finish(Database.BatchableContext BC){}  
    
    // wrapper class to hold aggregate data
    public class Summary {
        public AggregateResult ar { get; private set; }
        
        public String AccountName {get; private set;}
        
        public Summary(AggregateResult aresult) {
            ar = aresult;
            AccountName = String.valueOf(ar.get('AccountName'));
            
        }
    }
}