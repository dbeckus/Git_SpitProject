@IsTest
public class TestPopulateOpportunitySource {
    
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.1- Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
     @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM1()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.6- Sales Engineer Team']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
     @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM2()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.0- Sales Management']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    
     @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM3()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_ISR()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.3- Inside Sales']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
           Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='New',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('BDR-MQL', output.Opportunity_Source__c);
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_PIO()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.3- Inside Sales']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='New',CloseDate=Date.today().addDays(90),Deal_Reg__c=true);
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('PIO', output.Opportunity_Source__c);
            
        }
    }
}