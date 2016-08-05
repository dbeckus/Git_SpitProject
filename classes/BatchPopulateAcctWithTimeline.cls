global class BatchPopulateAcctWithTimeline implements Database.Batchable<Account>, Database.Stateful 
{	
  global BatchPopulateAcctWithTimeline() 
	{	
	}
	
	global List<Account> start(Database.BatchableContext BC) 
	{
    return [select Id, Name, ParentId, UltimateParentId__c, UltimateParentName__c,  
				(select CloseDate, StageName, Amount from Opportunities where StageName = 'Closed Won') 
				from Account];
	}

  global void execute(Database.BatchableContext BC, List<Account> accounts) 
  {
    Map<String,Summary> Summaries = new Map<String,Summary>();
    for (AggregateResult agr : [select Account.Name , MAX(CloseDate), MIN(CloseDate), SUM(Amount)   
    from Opportunity where StageName = 'Closed Won' and AccountId in :accounts
    group by Account.Name]) 
    {      
      Summary sum = new Summary(agr);
      Summaries.put((String)agr.get('Name'), sum);
    }

    Map<String, AccountWithTimeline__c> acct2Timelines = new Map<String, AccountWithTimeline__c>();
    for(AccountWithTimeline__c accountWithTimeline : [select Id, Name, Name__c from AccountWithTimeline__c where Name__c in :accounts])
    {
      acct2Timelines.put(accountWithTimeline.Name__c, accountWithTimeline);
    }

    List<AccountWithTimeline__c> accTimelines = new List<AccountWithTimeline__c>();
    for(Account acc : accounts)
    {
      Summary currentSum;
      Date ninetyDays;
      Date firstYear;
      Decimal ninetyAmount = 0;
      Decimal firstYearAmount = 0;

      if(acc.Opportunities.size() > 0) 
      {
        if(Summaries.containsKey(acc.Name)) 
        {
          currentSum = Summaries.get(acc.Name);
        } 
        else 
        {
          System.Debug(LoggingLevel.INFO, 'Errr:' + acc.Name + ',' + acc.Opportunities );  
          continue;
        }
        ninetyDays = currentSum.FirstTranDate + 90;
        firstYear = currentSum.FirstTranDate + 365;
      }

      for(Opportunity opp: acc.Opportunities)
      {
        if(opp.CloseDate == currentSum.FirstTranDate) 
        {
          if(currentSum.FirstTranSize == null) 
          {
            currentSum.FirstTranSize = opp.Amount;
          } 
          else 
          {
            currentSum.FirstTranSize += opp.Amount;
          }
        }

        if(opp.CloseDate == currentSum.LatestTranDate) 
        {
          if(currentSum.LatestTranSize == null) 
          {
            currentSum.LatestTranSize = opp.Amount;
          } 
          else 
          {
            currentSum.LatestTranSize += opp.Amount;
          }
        }

        if(opp.CloseDate < ninetyDays)  
        {
          if(opp.Amount != null) 
          {
            ninetyAmount += opp.Amount;
          }
        }

        if(opp.CloseDate < firstYear) 
        {
          if(opp.Amount != null) 
          {
            firstYearAmount += opp.Amount;
          }
        }
      }

      if(currentSum != null) 
      {
        if(currentSum.TotalSales == null || currentSum.TotalSales < 0.0) 
        {
          continue;
        }
        if(currentSum.Name.length() > 80) 
        {
          System.Debug(LoggingLevel.INFO, 'Length > 80: ' + currentSum.Name);
          currentSum.Name = currentSum.Name.substring(0,79);
          System.Debug(LoggingLevel.INFO, 'New Name: ' + currentSum.Name);                     
        }
        currentSum.firstNinety = ninetyAmount;
        currentSum.firstYear = firstYearAmount;  

        AccountWithTimeline__c accTimeLine;
        if(acct2Timelines.get(acc.Id) == null) 
        {
          accTimeLine = new AccountWithTimeline__c(Name = currentSum.Name, Name__c = acc.Id);
        } 
        else 
        {
          accTimeLine = acct2Timelines.get(acc.Id);
          System.Debug(LoggingLevel.INFO, 'Found account: ' + accTimeLine.Name);
        }

        accTimeLine.Total_Sales__c = currentSum.TotalSales != null ? currentSum.TotalSales : 0.0;
        accTimeLine.UltimateParent__c = acc.UltimateParentId__c;// DerivedParentMap.get(acc.Name);
        accTimeLine.UltimateParentName__c = acc.UltimateParentName__c;// AllAccountsMap.get(DerivedParentMap.get(acc.Name));    
        accTimeLine.First_Order__c = currentSum.FirstTranDate;
        accTimeLine.Last_Order_Date__c = currentSum.LatestTranDate;
        accTimeLine.First_Order_Amt__c = currentSum.FirstTranSize != null ? currentSum.FirstTranSize : 0.0 ;
        accTimeLine.Last_Order_Amt__c = currentSum.LatestTranSize != null ? currentSum.LatestTranSize : 0.0;
        accTimeLine.Ninety_Days_Total__c = currentSum.firstNinety;        
        accTimeLine.First_Year_Total__c = currentSum.firstYear;
        system.debug(accTimelines);
        accTimelines.add(accTimeLine);
      }
    }
    if(!accTimelines.isEmpty())
    {
      upsert accTimelines;
    }
  }
	
	global void finish(Database.BatchableContext BC) 
	{	
	}

	public class Summary 
	{
        public Date LatestTranDate { get; private set; }
        public Decimal LatestTranSize { get; private set; }
        public Date FirstTranDate { get; private set; }
        public Decimal FirstTranSize { get; private set; }
        
        public Decimal firstNinety { get; private set; }
        public Decimal firstYear { get; private set; }
        public Decimal TotalSales { get; private set; }
        public String Name { get; private set; }
        public String ParentName { get; private set; }
        
        public Summary(AggregateResult ar) 
        {
            LatestTranDate = (Date)ar.get('expr0');
            FirstTranDate= (Date)ar.get('expr1');
            TotalSales= (Decimal)ar.get('expr2');
            Name = (String)ar.get('Name');
        }
    }
}
/*
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
             //System.Debug(LoggingLevel.INFO, 'Acc:' + a + ', Opportunities:' + a.Opportunities.size());  
             
             
             
             
            
             
       }
       System.debug(LoggingLevel.INFO, 'populateAcctWithTimeline() - Current Query Rows: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
       
       upsert acctList;
*/