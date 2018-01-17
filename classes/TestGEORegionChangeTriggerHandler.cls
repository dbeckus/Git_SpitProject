@IsTest
public class TestGEORegionChangeTriggerHandler {

    @IsTest
    public static void UpdateGEORegion()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='LName',FirstName='FName', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='EMEA',Region__c='East',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr; 
        
        Account acc= new Account(Name='Test');
        insert acc;
        Opportunity opp= new Opportunity(Name='Test Opp',CloseDate=Date.today(), StageName='Discovery', AccountId=acc.Id, OwnerId=usr.Id);
        insert opp;
   
        Test.startTest();
        User_GEO_Region__e obj= new User_GEO_Region__e();
        obj.Owner_Id__c=usr.Id;
        obj.GEO_Region__c=usr.Sales_Region__c;
        System.debug(obj);
        Database.SaveResult spresult= EventBus.publish(obj);
        System.assert(spresult.isSuccess());
        
        
        Opportunity outputOpp=[Select Sales_Region__c,OwnerId from opportunity where Id=:opp.Id];
        System.assertEquals(outputOpp.OwnerId,usr.Id );
        System.assertEquals(outputOpp.Sales_Region__c,'EMEA-East' );
        Test.stopTest();
    }
    
   
    
     
}