@IsTest
public class TEstClassForTesting {
  @IsTest
    public static void TestUpdateFirstOpportunityWinCheckBox_FirstOppClosed()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.Finance_Reviewed__c=true;
        opp.StageName='Closed Won';
        update opp;
        Opportunity result=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result.First_Win_Opportunity__c==true);
    }
    
     @IsTest
    public static void TestUpdateFirstOpportunityWinCheckBox_Uncheck()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.Finance_Reviewed__c=true;
        opp.StageName='Closed Won';
        update opp;
        Opportunity result=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result.First_Win_Opportunity__c==true);
        opp.StageName='PO in Process';
        update opp;
		Opportunity result1=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result1.First_Win_Opportunity__c==false);        
    }
    
   
}