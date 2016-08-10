global with sharing  class AccountSummaryController{
   //private transient Map<String,Summary> Summaries { get; set; }
    public Account account { get; set; }   
    public String  assetWithSummaryJSON  { get; set; }
    public String  casesSummaryJSON  { get; set; }
    public String  timelineChartDataJSON  { get; set; }
    public String  acctTimelineJSON  { get; set; }
    public AccountSummaryController (ApexPages.StandardController stdController) {
        
        account = (Account)stdController.getRecord();
        String accountId = account.Id;
        
        List<Asset>  assetWithSummary = [SELECT Id, SerialNumber, Status, Contract_Type__c, Contract_Status__c, Contract_End__c, Ship_Date__c,Model__c, License_End_Date__c,
                             (SELECT Start_Date__c, License_Expiration__c, Duration__c FROM licenses__r), 
                             (SELECT WAN_Total_15_days__c,Release__c,Reduction_Total_15_days__c,Platform__c,Last_Contact__c,LAN_Total_15_days__c,CreatedById,Name FROM Summary_of_Asset__r) 
                             FROM Asset where AccountId = :accountId and Status in ('Customer Owned', 'Cold Spare', 'Customer Subscription', 'Conditional PO')];
        //System.Debug(LoggingLevel.INFO, assetWithSummary.size());
        //System.Debug(LoggingLevel.INFO, assetWithSummary[10].Release__c);
        assetWithSummaryJSON= JSON.serialize(assetWithSummary);             
        
        // Get Case Summary
        Map<String, Integer> caseSummary = new  Map<String, Integer>(); 
        AggregateResult[] aggr = [SELECT Count(Id) FROM Case where IsClosed = True and Type in ('Incoming Email','WANstart','Technical Support') and ClosedDate =LAST_90_DAYS and Account.Id = :accountId];
        caseSummary.put('closedLast90Days', (Integer) aggr[0].get('expr0'));
        AggregateResult[] aggr1 = [SELECT Count(Id) FROM Case where IsClosed = True and Type in ('Incoming Email','WANstart','Technical Support') and CreatedDate = LAST_90_DAYS and Account.Id = :accountId];   
        caseSummary.put('createdLast90Days',(Integer) aggr1[0].get('expr0'));
        AggregateResult[] aggr2 = [SELECT Count(Id) FROM Case where IsClosed = False and Type in ('Incoming Email','WANstart','Technical Support') and Account.Id = :accountId];               
        caseSummary.put('openCases', (Integer) aggr2[0].get('expr0') );         
        casesSummaryJSON = JSON.serialize(caseSummary);     
        
        // Account Cumulative Timeline
        AggregateResult[] agr = [SELECT  CloseDate, SUM(Amount) Amount FROM Opportunity where IsClosed =  True and StageName = 'Closed Won' and AccountId = :accountId GROUP BY CloseDate  ORDER BY CloseDate];          
        timelineChartDataJSON = JSON.serialize(agr);
        
        List<AccountWithTimeline__c> timeline = [SELECT Name, Name__c, First_Order__c, First_Order_Amt__c, First_Year_Total__c,  Last_Order_Amt__c, Last_Order_Date__c, 
                                                    Total_Sales__c, UltimateParent__c, UltimateParentName__c FROM AccountWithTimeline__c where Name__c = :accountId];  
        
        acctTimelineJSON =JSON.serialize(null);
        if(!timeline.isEmpty())
        {
           acctTimelineJSON = JSON.serialize(timeline[0]);
        }
        
    }
    
    @RemoteAction
    public static List<Account> getAccounts(String inputString) {
        String modInput = inputString + '%';
         List<Account> accts =  [SELECT Name from Account WHERE Name like :modInput and Type in ('Customer') LIMIT 25];
         return accts;
    }
    
}