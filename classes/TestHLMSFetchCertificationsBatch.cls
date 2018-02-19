@Istest
public class TestHLMSFetchCertificationsBatch {
 @IsTest
    public static void TestBatch_email()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com');
        insert testContact;
        
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true,New_Course_Id__c='01I38000000RCsf');
        insert course;
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        H_LMSFetchCertificationsBatch  obj= new H_LMSFetchCertificationsBatch();
        Database.executeBatch(obj);
        Test.stopTest();
    }
    
    @IsTest
    public static void TestBatch_studentId()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com',LMS_User_Id__c='01p3B000000Ea8s');
        insert testContact;
        Partner_Contact_Profile__c pc= new Partner_Contact_Profile__c(Contact__c=testContact.Id);
        insert pc;
        
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true,New_Course_Id__c='01I38000000RCsf');
        insert course;
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        H_LMSFetchCertificationsBatch obj= new H_LMSFetchCertificationsBatch();
        Database.executeBatch(obj);
        AssociateLMSCertificateWithContact objContact= new AssociateLMSCertificateWithContact();
        objContact.execute(null);
        Test.stopTest();
    }
    
    @IsTest
    public static void TestBatch_studentemail()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com');
        insert testContact;
        
        
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true,New_Course_Id__c='01I38000000RCsf');
        insert course;
        
        Test.setMock(HttpCalloutMock.class, new HLMSPartnerPortalAPiMock(200, 'OK', 'String body', new Map<String, String> ()));
        Test.startTest();
        H_LMSFetchCertificationsBatch obj= new H_LMSFetchCertificationsBatch();
        Database.executeBatch(obj);
        AssociateLMSCertificateWithContact objContact= new AssociateLMSCertificateWithContact();
        objContact.execute(null);
        Test.stopTest();
    }
    
     @IsTest
    public static void TestAssociateLMSCertificateWithContact()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Contact testContact = new Contact(LastName='acme', AccountId=testAccount.Id,Email='srussell@silver-peak.com');
        insert testContact;
        
       
        LMS_Course__c course= new LMS_Course__c(Course_Id__c='138078',Course_Name__c='Test Course',Display_Name__c='Test Course Display Name',Is_Active__c=true,New_Course_Id__c='01I38000000RCsf');
        insert course;
        LMS_Course_Certification__c cert= new LMS_Course_Certification__c(IsActive__c=true,LMS_Course_Id__c=course.Id,Student_Email__c='srussell@silver-peak.com');
        insert cert;
     	LMS_Course_Certification__c cert1= new LMS_Course_Certification__c(IsActive__c=true,LMS_Course_Id__c=course.Id,LMS_User_Id__c=testContact.Id);
        insert cert1;
        Test.startTest();
        AssociateLMSCertificateWithContact objContact= new AssociateLMSCertificateWithContact();
        objContact.execute(null);
        Test.stopTest();
    }
}