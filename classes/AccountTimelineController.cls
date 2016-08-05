global with sharing class AccountTimelineController implements Schedulable {

    private transient Map<String,Summary> Summaries { get; set; }
    private transient Map<String,Summary> SummariesMore { get; set; }
    private transient Map <String, Account> AcctsWithParents {get; set;}
    private transient Map <String, String> DerivedParentMap {get; set;}
    private transient Map <String, String> AllAccountsMap {get; set;}
    private transient Map <String, AccountWithTimeline__c> AcctTimeLineMap {get; set;}
    private transient Map<String,Map<String, Integer>> acctWithAssets {get; set;}
     
    public AccountTimelineController () {
    }
    global void execute(SchedulableContext sc) {
       //new AccountTimelineController().populateAcctWithTimeline();   
        Database.executeBatch(new BatchPopulateAcctWithTimeline());      
    }
    
    public void resetTable() {
        List<AccountWithTimeline__c> curRecords = [SELECT Id FROM AccountWithTimeline__c];
        delete curRecords;
    }
    public void populateAcctWithTimeline () {
        
        AcctsWithParents = new Map <String, Account>();
        DerivedParentMap = new Map <String, String>();
        AllAccountsMap = new Map <String, String>();
    AcctTimeLineMap = new Map <String, AccountWithTimeline__c>();
        
        List<AccountWithTimeline__c> timelineAccts = [SELECT Id, Name, Name__c FROM AccountWithTimeline__c];
        for (AccountWithTimeline__c acctT : timelineAccts ) {
            AcctTimeLineMap.put(acctT.Name__c, acctT);           
        }
        
        List<AccountWithTimeline__c> acctList = new List<AccountWithTimeline__c>();     
        Summaries = new Map<String,Summary>();
        
        for (Account a : [SELECT Id, Name FROM Account]) {
            AllAccountsMap.put(a.Id, a.Name);           
        }
        
        
        for (AggregateResult agr : [SELECT Account.Name , MAX(CloseDate), MIN(CloseDate), SUM(Amount)   FROM Opportunity where StageName = 'Closed Won' Group By Account.Name Limit 1000]) {      
           
            // System.Debug(LoggingLevel.INFO, 'Adding key Aggr:' + (String) agr.get('Name'));  
            Summary sum = new Summary(agr);
            Summaries.put((String) agr.get('Name'), sum);
           
        }
        SummariesMore = new Map<String,Summary>();
        for (AggregateResult agr : [SELECT Account.Name , MAX(CloseDate), MIN(CloseDate), SUM(Amount)   FROM Opportunity where StageName = 'Closed Won' Group By Account.Name Limit 1000 Offset 1000 ]) {      
            Summary sum = new Summary(agr);                        
            SummariesMore.put((String) agr.get('Name'), sum);
                     
        }
       
        List<Account> accountWithOpptys = [SELECT Id, Name, ParentId, (SELECT CloseDate, StageName, Amount 
                        FROM Account.Opportunities where 
                        Opportunity.StageName = 'Closed Won') FROM Account];
    
       
         for(Account a: accountWithOpptys){
            AcctsWithParents.put(a.Id, a);            
         }
         
         for(String key: AcctsWithParents.keySet()){
             Account at = AcctsWithParents.get(key);                                      
             DerivedParentMap.put(at.Name, getTopParentAccountName(at));                
         }
        //Loop through Accounts only once
        Integer i =0;
        for(Account a: accountWithOpptys){
          //  System.Debug(LoggingLevel.INFO, 'acct:' + a);
         //Loop through related Opportunities only once
             Summary sumLookup ; 
             Decimal numNinety = 0;
             Decimal numFirstYear = 0;
             Date ninetyDays;
             Date firstYear;
             //System.Debug(LoggingLevel.INFO, 'Acc:' + a + ', Opportunities:' + a.Opportunities.size());  
             if(a.Opportunities.size() > 0) {
                 //System.Debug(LoggingLevel.INFO, 'Looking for Acc:' + a.Name + ',' + Summaries.containsKey(a.Name));  
                
                 if(Summaries.containsKey(a.Name)) {
                     sumLookup = Summaries.get(a.Name);
                 } else if(SummariesMore.containsKey(a.Name)) {
                      sumLookup = SummariesMore.get(a.Name);
                 } else {
                     System.Debug(LoggingLevel.INFO, 'Errr:' + a.Name + ',' + a.Opportunities );  
                     continue;
                 }
                 ninetyDays = sumLookup.FirstTranDate + 90;
                 firstYear = sumLookup.FirstTranDate + 365;
                 
             }
             for(Opportunity opp: a.Opportunities){
                //System.Debug(LoggingLevel.INFO, 'opp:' + opp);
                if(opp.CloseDate == sumLookup.FirstTranDate) {
                    if(sumLookup.FirstTranSize == null) {
                        sumLookup.FirstTranSize = opp.Amount;
                    } else {
                        sumLookup.FirstTranSize += opp.Amount;
                    }
                }
                if(opp.CloseDate == sumLookup.LatestTranDate) {
                    if(sumLookup.LatestTranSize == null) {
                        sumLookup.LatestTranSize = opp.Amount;
                    } else {
                        sumLookup.LatestTranSize += opp.Amount;
                    }
                }
                if(opp.CloseDate < ninetyDays)  {
                    if(opp.Amount != null) numNinety += opp.Amount;
                }
                if(opp.CloseDate < firstYear) {
                    if(opp.Amount != null) numFirstYear += opp.Amount;
                }
             }
             
             
            
             if(sumLookup != null) {
                 if(sumLookup.TotalSales == null || sumLookup.TotalSales < 0.0) 
                     continue;
                 if(sumLookup.Name.length() > 80) {
                    System.Debug(LoggingLevel.INFO, 'Length > 80: ' + sumLookup.Name);
                     sumLookup.Name = sumLookup.Name.substring(0,79);
                     System.Debug(LoggingLevel.INFO, 'New Name: ' + sumLookup.Name);                     
                 }
                 sumLookup.firstNinety = numNinety;
                 sumLookup.firstYear = numFirstYear;  
                 //System.Debug(LoggingLevel.INFO, 'Acc:' + a.Name + ': ' + sumLookup);  
                AccountWithTimeline__c acct = null;
                if(AcctTimeLineMap.get(a.Id) == null) {
                  acct = new AccountWithTimeline__c(Name = sumLookup.Name);
                    acct.Name__c = a.Id;
                } else {
                  acct = AcctTimeLineMap.get(a.Id);
                    System.Debug(LoggingLevel.INFO, 'Found account: ' + acct.Name);
                }
                
                acct.Total_Sales__c = sumLookup.TotalSales != null ? sumLookup.TotalSales : 0.0;
                
                acct.UltimateParent__c = DerivedParentMap.get(a.Name);
                acct.UltimateParentName__c =  AllAccountsMap.get(DerivedParentMap.get(a.Name));    
                acct.First_Order__c = sumLookup.FirstTranDate;
                acct.Last_Order_Date__c = sumLookup.LatestTranDate;
                acct.First_Order_Amt__c = sumLookup.FirstTranSize != null ? sumLookup.FirstTranSize : 0.0 ;
                acct.Last_Order_Amt__c = sumLookup.LatestTranSize != null ? sumLookup.LatestTranSize : 0.0;
                acct.Ninety_Days_Total__c = sumLookup.firstNinety;        
                acct.First_Year_Total__c = sumLookup.firstYear;
                acctList.add(acct);
                 
                //System.Debug(LoggingLevel.INFO, 'i: '+ i + ', ' + acct);  
                i++; 
             }
       }
       System.debug(LoggingLevel.INFO, 'populateAcctWithTimeline() - Current Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
       
       upsert acctList;
      
         
       
        
    }
    private string getTopParentAccountName(Account thisAccount) {
        if (thisAccount.ParentId != null) {
            return getTopParentAccountName(AcctsWithParents.get(thisAccount.ParentId));
        }
            else { // There's no parent account
            return thisAccount.Id;        
        }
    }
    // wrapper class to hold aggregate data
    public class Summary {
        public Date LatestTranDate { get; private set; }
        public Decimal LatestTranSize { get; private set; }
        public Date FirstTranDate { get; private set; }
        public Decimal FirstTranSize { get; private set; }
        
        public Decimal firstNinety { get; private set; }
        public Decimal firstYear { get; private set; }
        public Decimal TotalSales { get; private set; }
        public String Name { get; private set; }
        public String ParentName { get; private set; }
        
        public Summary(AggregateResult ar) {
            LatestTranDate = (Date) ar.get('expr0');
            FirstTranDate= (Date) ar.get('expr1');
            TotalSales= (Decimal) ar.get('expr2');
            Name = (String) ar.get('Name');
            
        }
    }
    
     

}