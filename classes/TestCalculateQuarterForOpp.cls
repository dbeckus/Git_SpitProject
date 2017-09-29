@IsTest
public class TestCalculateQuarterForOpp {
  /*  @IsTest
    public static void TestCalculateQuarterForOppData_Insert()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        Opportunity result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:opp.Id];
        System.assert(result.Fiscal_Quarter_Name__c!=null);
    }
    
 	@IsTest
    public static void TestCalculateQuarterForOppData_Update()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.CloseDate= Date.today().addDays(100);
        update opp;
        Opportunity result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:opp.Id];
        System.assert(result.Fiscal_Quarter_Name__c!=null);
    }
    
   
   
    
     @IsTest
    public static void CheckAllOppsUpdatedforAccount()
    {
        
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
         
        Opportunity opp1 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(30),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(100),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp2;
        Test.startTest();
        opp1.Finance_Reviewed__c=true;
        opp1.StageName='Closed Won';
        update opp1;
       
        List<Opportunity> result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:acc.Id];
        for(Opportunity opp: result)
        {
            System.assertEquals(opp.Type, 'Follow on Business');
        }
        Test.stopTest();
    }
     @IsTest
    public static void CheckAllOppsUpdatedforAccount_Clear()
    {
        
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
         
        Opportunity opp1 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(30),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(100),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp2;
        Test.startTest();
        opp1.Finance_Reviewed__c=true;
        opp1.StageName='Closed Won';
        update opp1;
       
        List<Opportunity> result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:acc.Id];
        for(Opportunity opp: result)
        {
            System.assertEquals(opp.Type, 'Follow on Business');
        }
        opp1.StageName='New';
        update opp1;
        Account acco=[Select Id, First_Asset_Quarter__c from Account where Id=:acc.Id];
        System.assertEquals(acco.First_Asset_Quarter__c, null);
        Test.stopTest();
    }*/
}