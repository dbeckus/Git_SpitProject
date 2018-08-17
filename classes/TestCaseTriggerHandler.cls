@IsTest
public class TestCaseTriggerHandler {
    
    //A non Tech Support case is created for a account that has DE Notes
    @isTest
    static void NewCaseNotTechSupport()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, DE_Notes__c = 'TestNotes');
        insert den;
        
        Case case1 = new Case(Subject = 'Invalid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005HNd', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(0,lstDECaseNotes.size() );
    }
    
    //A Tech Support Case is created for an account that has DE Notes
    @isTest
    static void NewCaseIsTechSupport()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Engineering Support']; 
        User engUser = new User(Alias = 'standt', Email='testUser@testenguser.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = prof.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testenguser.com');  
        
        Account acc = new Account(Name = 'Hybrid Technologies', Type = 'Customer', Deployment_Engineering__c = True);
        insert acc;
        
        Contact con = new Contact(FirstName = 'John', LastName  = 'Doe', AccountId = acc.Id);
        insert con;
        
        De_Note__c den = new DE_Note__c(Account_Name__c = acc.Id, DE_Notes__c = 'TestNotes');
        insert den;
        
        Case case1 = new Case(Subject = 'Valid Case for DE Notes', AccountId = acc.Id, ContactId = con.Id, RecordTypeId = '012500000005Aui', Priority = 'P4 - Low', Type = 'Customer Service', Origin = 'Web');
        insert case1;
        
        List<DE_Case_Note__c> lstDECaseNotes = [Select Id, De_Note__r.Id from DE_Case_Note__c where DE_Note__r.Id =:den.Id];
        system.assertEquals(1,lstDECaseNotes.size() );
    }
}