@IsTest
public class TestLMSFetchCertificationsBatch {
    @IsTest
    public static void TestBatch_email()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com');
        insert testContact;
        
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true);
        insert course;
        Test.setMock(HttpCalloutMock.class, new LMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        LMSFetchCertificationsBatch obj= new LMSFetchCertificationsBatch();
        Database.executeBatch(obj);
        Test.stopTest();
    }
    
    @IsTest
    public static void TestBatch_studentId()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com');
        insert testContact;
        Partner_Contact_Profile__c pc= new Partner_Contact_Profile__c(Contact__c=testContact.Id,LmsUserId__c='1423952');
        insert pc;
        
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true);
        insert course;
        Test.setMock(HttpCalloutMock.class, new LMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        LMSFetchCertificationsBatch obj= new LMSFetchCertificationsBatch();
        Database.executeBatch(obj);
        Test.stopTest();
    }
    
}