@IsTest 
public class TestCaseShareWithPartnerManager {
    @IsTest(SeeAllData=true)
    public static void TestSharCaseWithManager()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testpartnerUser.com');
        insert con;
        Profile prof = [SELECT Id FROM Profile WHERE Name='13g-SP Partner Community']; 
        User usr = new User(Alias = 'standt', Email='testUser@testpartnerUser.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=con.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testpartnerUser.com');
        
        usr.IsActive =true;
        insert usr;
        con.PortalUser__c=usr.Id;
        update con;
        Case caseData = new Case();
        caseData.ContactId= con.Id;
        caseData.Subject='Test Data';
        caseData.Status='In Process';
        caseData.Type='Technical Support';
        caseData.Origin='Web';
        caseData.Priority='P3 - Normal';
        insert caseData;
        
     
        
    }

}