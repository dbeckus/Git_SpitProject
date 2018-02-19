@isTest
public class CaseSupportEmailHandlerTest
{
   @isTest
    static void testIsDuplicateCase()
    {
        Contact newContact = new Contact(LastName = 'acmeLastName', Email='acme@mail.com');
        insert newContact;
        Case newCase = new Case(Subject='acme 1981', ContactId=newContact.Id);
        insert newCase;
        System.assertEquals(true, CaseSupportEmailHandler.isDuplicateCase('acme 1981', 'acme@mail.com'));
    }
  
   @isTest 
    static void testParseCaseNumber()
    {
        String[] caseNumbers = CaseSupportEmailHandler.parseCaseNumber('test[20100101-2015]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = CaseSupportEmailHandler.parseCaseNumber('test[2015]');
        System.assertEquals(0, caseNumbers.size());
        
        caseNumbers = CaseSupportEmailHandler.parseCaseNumber('test[20100101-2015]ab[abcdefg]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = CaseSupportEmailHandler.parseCaseNumber('test[20100101-2015]ab[20110101-34567]');
        System.assertEquals(2, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        System.assertEquals('20110101-34567', caseNumbers[1]);
    }
  
    @isTest
    static void testCreateContactByMail()
    {
        Account acc = new Account(name='acme');
        insert acc;
        CaseSupportEmailHandler.createContactByMail('test@test.com', 'kevin chong', acc.Id);
        List<Contact> contacts = [select Id, FirstName, lastName, Email from Contact where Email='test@test.com' and FirstName='kevin' and LastName='chong' limit 1];
        System.assertEquals(1, contacts.size());
    }
  
    @isTest
    static void testNonAutoEmail()
    {
        Test.startTest();
        Account acc= new Account(Name='Test');
        insert acc;
        Contact con= new Contact(FirstName='TestFName',LastName='Test',Email='Acme.InTestMethod@acme.com',AccountId=acc.Id);
        insert con;
        Id [] fixedSearchResults= new Id[1];
      	fixedSearchResults[0] = con.Id;
       	Test.setFixedSearchResults(fixedSearchResults);
        Case cs = new Case(Subject='acme');
        insert cs;
        EmailSetup__c setup = new EmailSetup__c(Name='Support', Drop_Email_From__c='spam',Case_Record_Type__c='Incoming Email');
        insert setup;
        Messaging.Inboundemail testEmail = new Messaging.Inboundemail();
        testEmail.subject = 'acme subject';
        testEmail.fromAddress = 'Acme.InTestMethod@acme.com';
        testEmail.plainTextBody = 'This is a test Email plainTextBody !';
        List<Messaging.Inboundemail.Binaryattachment> bAttachments = new List<Messaging.Inboundemail.Binaryattachment>();
        List<Messaging.Inboundemail.Textattachment> tAttachments = new List<Messaging.Inboundemail.Textattachment>();
        Messaging.Inboundemail.Binaryattachment bAttachment = new Messaging.Inboundemail.Binaryattachment();
        bAttachment.body = Blob.valueOf('acme');
        bAttachment.fileName = 'binary attachment';
        bAttachments.add(bAttachment);
        testEmail.binaryAttachments = bAttachments;
        Messaging.Inboundemail.Textattachment tAttachment = new Messaging.Inboundemail.Textattachment();
        tAttachment.body = 'acme';
        tAttachment.fileName = 'text attachment';
        tAttachments.add(tAttachment);
        testEmail.textAttachments = tAttachments;
        Messaging.Inboundenvelope testEnvelope = new Messaging.Inboundenvelope();
        (new CaseSupportEmailHandler()).handleInboundEmail(testEmail, testEnvelope);
        testEmail.subject = 'acme subject['+cs.Subject+']';
        (new CaseSupportEmailHandler()).handleInboundEmail(testEmail, testEnvelope);
        //Test for illegal condition.
        Messaging.Inboundemail illegalFromNameEmail = new Messaging.Inboundemail();
        illegalFromNameEmail.fromName = 'system administrator';
        (new CaseSupportEmailHandler()).handleInboundEmail(illegalFromNameEmail, testEnvelope);
        
        Test.stopTest();
    }
    
    @isTest
    static void testParseSubjectValues()
    {
        List<String> result = CaseSupportEmailHandler.parseSubjectValues('AUTOCASE: [00-e0-81-78-58-8e]:[acme@test.com]:[P3]');
        System.assertEquals(3, result.size());
        System.assertEquals('00-e0-81-78-58-8e', result[0]);
        System.assertEquals('acme@test.com', result[1]);
        System.assertEquals('P3', result[2]);
        
        System.assertEquals(true, CaseSupportEmailHandler.isAutoEmail('AUTOCASE: [00-e0-81-78-58-8e]:[acme@test.com]:[P3]'));
    }
    
   	@isTest
    static void testAutoEmail()
    {
        EmailSetup__c setup = new EmailSetup__c(Name='Support', Drop_Email_From__c='spam', Case_Record_Type__c='Incoming Email');
        insert setup;
        Account acc = new Account(Name='acme');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Asset asset = new Asset(Name='00e08178588e', AccountId=acc.Id);
        insert asset;
        Messaging.Inboundemail testEmail = new Messaging.Inboundemail();
        testEmail.subject = 'AUTOCASE: [' + asset.Name + ']:[acme@test.com]:[P3]';
        testEmail.fromAddress = 'Acme.InTestMethod@acme.com';
        testEmail.plainTextBody = 'Priority: P3 \r\n' + 
            'Name: Acme Test \r\n' + 
            'Email: acme@test.com \r\n' + 
            'phone: x1822 \r\n' + 
            'NX IP: 10.0.40.38 \r\n' + 
            'NX name: mars \r\n' + 
            'NX Serial 00-e0-81-78-58-8e \r\n' + 
            'Sysdump name: http://autosupport.silverpeaksystems.com/files/gms/speak.local/debug-2011-05-10-074155.zip \r\n' + 
            'Description: \r\n' + 
            'hello';
        CaseSupportEmailHandler handler = new CaseSupportEmailHandler();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(testEmail, null);
        System.assertEquals(null, result.message);
        System.assertEquals(true, result.success);
        System.assertEquals(1, [select count() from Case]);
        Case theCase = [select Id, CaseNumber, AssetId, Priority, ContactId from Case where Subject = :testEmail.subject];
        System.assertEquals(asset.Id, theCase.AssetId);
        System.assert(theCase.ContactId != null);
    }
    
    @isTest
    static void testInsertCaseComments()
    {
        Contact newContact = new Contact(LastName = 'acmeLastName', Email='acme@mail.com');
        insert newContact;
        EmailSetup__c setup = new EmailSetup__c(Name='Support', Drop_Email_From__c='spam',Case_Record_Type__c='Incoming Email',delimiter__c=',');
        insert setup;
        Case newCase = new Case(Subject='acme 1981', ContactId=newContact.Id);
        insert newCase;
        Messaging.Inboundemail testEmail = new Messaging.Inboundemail();
        testEmail.subject = 'acme subject';
        testEmail.fromAddress = 'Acme.InTestMethod@acme.com';
        testEmail.plainTextBody = 'This is a test Email plainTextBody !';
        System.assertNotEquals(null,CaseSupportEmailHandler.insertCaseComment(newCase, testEmail));
    }
   
}