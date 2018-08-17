@IsTest 
public class TestUpdatePatchChangesonOpenOpps {
    @IsTest
    public static void testRSMChange()
    {
        
        Account acc = new Account(Name='acme');
        insert acc;
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='LName',FirstName='FName', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Patch__c patch = new Patch__c(Patch_Name__c='acme');
        insert patch;
        Opportunity opp = new Opportunity(Name='acme',patch__c=patch.Id, Deal_Type__c='Wan Op',CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        
        patch.RSM__c=usr.Id;
        update patch;
        Patch__c updPatch=[Select Id,RSM__r.Name from Patch__c where Id=:patch.Id ];
        Patch_Change__e objPE= new Patch_Change__e(Patch_Id__c=patch.Id,RSM_Name__c=updPatch.RSM__r.Name,Channel_Manager_Name__c=null);
        System.debug('objPE'+objPE);
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(objPE);
        Test.stopTest();
        System.debug('sr.IsSuccess' + sr.isSuccess());
        Opportunity opp1=[Select Regional_Sales_Manager__c from Opportunity where Id=:opp.Id];
        System.assertequals(opp1.Regional_Sales_Manager__c,'FName LName');
        
        
        
    }
    @IsTest
    public static void testCAMChange()
    {
        
        Account acc = new Account(Name='acme');
        insert acc;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='LName',FirstName='FName', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Patch__c patch = new Patch__c(Patch_Name__c='acme');
        insert patch;
        Opportunity opp = new Opportunity(Name='acme',patch__c=patch.Id,Deal_Type__c='Wan Op' ,CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        
        patch.CSM__c=usr.Id;
        update patch;
        Patch__c updPatch=[Select Id,CSM__r.Name from Patch__c where Id=:patch.Id ];
        Patch_Change__e objPE= new Patch_Change__e(Patch_Id__c=patch.Id,RSM_Name__c=null,Channel_Manager_Name__c=updPatch.CSM__r.Name);
        System.debug('objPE'+objPE);
        Test.startTest();
        
        Database.SaveResult sr = EventBus.publish(objPE);
        Test.stopTest();
        System.debug('sr.IsSuccess' + sr.isSuccess());
        Opportunity opp1=[Select Channel_Manager__c from Opportunity where Id=:opp.Id];
        System.assertequals(opp1.Channel_Manager__c,'FName LName');
        
        
        
    }
    
     @IsTest
    public static void testRSSChange()
    {
        
        Account acc = new Account(Name='acme');
        insert acc;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='LName',FirstName='FName', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Patch__c patch = new Patch__c(Patch_Name__c='acme');
        insert patch;
        Opportunity opp = new Opportunity(Name='acme',patch__c=patch.Id,Deal_Type__c='Wan Op' ,CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id);
        insert opp;
        
        patch.RSS__c=usr.Id;
        update patch;
        Patch__c updPatch=[Select Id,RSS__r.Name from Patch__c where Id=:patch.Id ];
        Patch_Change__e objPE= new Patch_Change__e(Patch_Id__c=patch.Id,RSM_Name__c=null,Channel_Manager_Name__c=null,RSS_Name__c=updPatch.RSS__r.Name);
        System.debug('objPE'+objPE);
        Test.startTest();
        
        Database.SaveResult sr = EventBus.publish(objPE);
        Test.stopTest();
        System.debug('sr.IsSuccess' + sr.isSuccess());
        Opportunity opp1=[Select Renewal_Specialist__c from Opportunity where Id=:opp.Id];
        System.assertequals(opp1.Renewal_Specialist__c,'FName LName');
        
        
        
    }
}