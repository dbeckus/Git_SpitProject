@IsTest
public class TestSetDefaultTechResponsibility {
    
    @Istest(SeeAllData=true)
    public static void SetTechResponsibilityWhenNullAndNotNew()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        User rsmusr = new User(Alias = 'standt', Email='testUser@testrsmUser.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = prof.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testrsmUser.com',Default_TR__c=techUser.id);
        
        rsmusr.IsActive =true;
        insert rsmusr;
        
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true,RSM__c=rsmusr.Id);
        insert patch;
        
        Account acc= new Account(Name='Test Account',Patch__c=patch.Id);
        insert acc;
        
        Opportunity opp= new Opportunity(AccountId=acc.id,Name='Test Opp',StageName='Discovery',CloseDate=Date.today().addYears(1));
        insert opp;
        
        Opportunity outputOpp=[Select Id,Technical_Responsible__c from Opportunity where Id=:opp.Id];
        System.assertEquals(outputOpp.Technical_Responsible__c, techUser.id);
        
    }
    @Istest(SeeAllData=true)
    public static void SetTechResponsibilityWhenNotNullAndNotNew()
    {
         Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        User rsmusr = new User(Alias = 'standt', Email='testUser@testrsmUser.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = prof.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testrsmUser.com',Default_TR__c=techUser.id);
        
        rsmusr.IsActive =true;
        insert rsmusr;
        
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true,RSM__c=rsmusr.Id);
        insert patch;
        
        Account acc= new Account(Name='Test Account',Patch__c=patch.Id);
        insert acc;
        
        Opportunity opp= new Opportunity(AccountId=acc.id,Name='Test Opp',StageName='Discovery',CloseDate=Date.today().addYears(1),Technical_Responsible__c=rsmusr.Id);
        insert opp;
        
        Opportunity outputOpp=[Select Id,Technical_Responsible__c from Opportunity where Id=:opp.Id];
        System.assertNotEquals(outputOpp.Technical_Responsible__c, techUser.id);
    }
     @Istest(SeeAllData=true)
    public static void SetTechResponsibilityWhenNullAndNew()
    {
          Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        User rsmusr = new User(Alias = 'standt', Email='testUser@testrsmUser.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = prof.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testrsmUser.com',Default_TR__c=techUser.id);
        
        rsmusr.IsActive =true;
        insert rsmusr;
        
        Patch__c patch = new Patch__c(Patch_Name__c='acme', Active__c=true,RSM__c=rsmusr.Id);
        insert patch;
        
        Account acc= new Account(Name='Test Account',Patch__c=patch.Id);
        insert acc;
        
        Opportunity opp= new Opportunity(AccountId=acc.id,Name='Test Opp',StageName='New',CloseDate=Date.today().addYears(1));
        insert opp;
        
        Opportunity outputOpp=[Select Id,Technical_Responsible__c from Opportunity where Id=:opp.Id];
        System.assertEquals(outputOpp.Technical_Responsible__c, null);
    }
}