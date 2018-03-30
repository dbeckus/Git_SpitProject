@Istest
public class TestUpdateStageOnOpportunityForTask {
    
    
    @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_Update()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Deal_Type__c='Replication',Type='New Business',Opportunity_Source__c='Other', OwnerId= usr.Id, Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        tsk.Subject='New BDR Meeting';
        tsk.Initial_Solution_Interest__c='Replication';
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Next_Opportunity_Stage__c='Discovery';
            updatedTask.Initial_Solution_Interest__c='Replication';
            updatedTask.Meeting_Rating__c='Poor';
            update updatedTask;
            Opportunity updatedOpp=[Select Id,StageName from opportunity where Id=:opp.Id];
            System.assertEquals('Discovery',updatedOpp.StageName);
        }
        
    }
   @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_UpdateDeadStage()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp',Solution_Type__c='Hybrid WAN', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Deal_Type__c='Replication',OwnerId= usr.Id, Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Next_Opportunity_Stage__c='Closed Dead';
              updatedTask.Initial_Solution_Interest__c='Replication';
            updatedTask.Dead_Reason__c='No Current Project';
            updatedTask.Meeting_Rating__c='Poor';
            update updatedTask;
            Opportunity updatedOpp=[Select Id,StageName from opportunity where Id=:opp.Id];
            System.assertEquals('Closed Dead',updatedOpp.StageName);
        }
        
    }
   
    public static void TestUpdateStageOnOpportunityForTask_UpdatedInitialSolutionInterestRequired()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Initial_Solution_Interest__c='Replication';
            updatedTask.Next_Opportunity_Stage__c='Discovery';
            updatedTask.Meeting_Rating__c='Poor';
            
            try
            {
                update updatedTask;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('If the Subject is New BDR Meeting, then Initial Solution Interest is required. Please select Initial Solution Interest.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true); 
            }
        }
        
    }
     @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_UpdatedDeadReasonRequired()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
              updatedTask.Initial_Solution_Interest__c='Replication';
            updatedTask.Next_Opportunity_Stage__c='Closed Dead';
            updatedTask.Meeting_Rating__c='Poor';
            
            try
            {
                update updatedTask;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('If the Next Opportunity Stage is Closed Dead, then Dead Reason is required. Please select Dead Reason.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true); 
            }
        }
        
    }
     @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_UpdatedMeetingRatingRequired()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Next_Opportunity_Stage__c='Closed Dead';
            updatedTask.Meeting_Rating__c=null;
            
            try
            {
                update updatedTask;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('If the Subject is New BDR Meeting, then Meeting Rating is required. Please select Meeting Rating.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true); 
            }
        }
        
    }
    
      @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_UpdatedStageRequired()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Next_Opportunity_Stage__c=null;
            updatedTask.Meeting_Rating__c='Poor';
            
            try
            {
                update updatedTask;
            }
            catch(Exception e)
            {
                Boolean expectedExceptionThrown =  e.getMessage().contains('If the Subject is New BDR Meeting, then Next Opportunity Stage is required. Please select Next Opportunity Stage.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true); 
            }
        }
        
    }
     @Istest(SeeAllData=true)
    public static void TestUpdateStageOnOpportunityForTask_NonRSM()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact con = new Contact(LastName='testUser',AccountId=account.Id);
        insert con;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        System.debug('Original Opp '+ opp.Id);
        Task tsk= new Task();
        tsk.WhoId= con.Id;
        tsk.WhatId= opp.Id;
        tsk.OwnerId= usr.Id;
        insert tsk;
        System.runAs(usr)
        {
            Task updatedTask= [Select Id, Next_Opportunity_Stage__c from task where Id=:tsk.Id];
            updatedTask.Subject='New BDR Meeting';
            updatedTask.Next_Opportunity_Stage__c='Discovery';
            updatedTask.Meeting_Rating__c='Poor';
            update updatedTask;
            Opportunity updatedOpp=[Select Id,StageName from opportunity where Id=:opp.Id];
            System.assertEquals('New',updatedOpp.StageName);
        }
        
    }
    
   @Istest(SeeAllData=true)
    public static void UpdateTaskForAccount()
    {
        
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship');
        insert ct;
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opp = new Opportunity(Name='test opp', AccountId=account.Id,StageName='New',Type='New Business',Opportunity_Source__c='Other',Pricebook2Id=standardPricebookId,CloseDate=Date.today());
        insert opp;
        
        Task tsk= new Task();
        tsk.Subject='New BDR Meeting';
        tsk.Next_Opportunity_Stage__c='Closed Dead';
        tsk.WhoId= ct.Id;
        tsk.WhatId= account.Id;
        tsk.Dead_Reason__c='No Current Project';
        insert tsk;
        Opportunity updatedOpp=[Select Id,StageName,Dead_Reason__c from opportunity where Id=:opp.Id];
        System.assert(tsk.Id!=null);
        
        System.assertNotEquals(tsk.Next_Opportunity_Stage__c, updatedOpp.StageName);
        System.assertNotEquals('No Current Project', updatedOpp.Dead_Reason__c);
    }
    
    
}