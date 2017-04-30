@IsTest
public class TestAssignGEOFromContactOwner {
    
   
    public static void TestAssignGeo_Insert()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='West',GEO__c='NAM',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        System.RunAs(usr)
        {
            Test.startTest();
            Contact con= new Contact(FirstName='TestFirst',LastName='Test Last',OwnerId=usr.Id);
            insert con;
            
            Contact newCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(newCon.Accurate_GEO__c,usr.GEO__c);
            Test.stopTest();
        }
        
    }
    
  
    public static void TestAssignGeo_Update()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='West',GEO__c='NAM',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        User usr1 = new User(Alias = 'standt', Email='testUser1@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, Region__c='East',GEO__c='APAC',
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser1@uniquetest.com');
        
        usr1.IsActive =true;
        insert usr1;
        System.RunAs(usr)
        {
            Test.startTest();
            Contact con= new Contact(FirstName='TestFirst',LastName='Test Last',OwnerId=usr.Id);
            insert con;
            
            Contact newCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(newCon.Accurate_GEO__c,usr.GEO__c);
            newCon.OwnerId=usr1.Id;
            update newCon;
            
            Contact expectedCon=[Select GEO__c,Accurate_GEO__c from Contact where Id=:con.id];
            System.assertEquals(expectedCon.Accurate_GEO__c,usr1.GEO__c);
            Test.stopTest();
        }
        
    }
    
}