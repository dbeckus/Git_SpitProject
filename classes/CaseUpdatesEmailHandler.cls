/*
 * An email handler, parses case number in the email subject, and appends the body to the internal discussion objects.
 */
global class CaseUpdatesEmailHandler implements Messaging.InboundEmailHandler 
{
  private static EmailSetupHelper.EmailSetupInfo emailSetup = EmailSetupHelper.getEmailSetup('Case Updates'); 
    
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
  { 
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    //code below count the total number of the inbound emails
    String emailSubject = (email.subject != null && email.subject.length() > 80)?email.subject.substring(0, 80):email.subject;
    Email_Log__c emailLog = new Email_Log__c(Name = emailSubject);
    insert emailLog;
    
    String fromAddress = email.fromAddress;
    
    //filter to avoid the duplicate cases
    if(isDuplicateCase(email.subject, fromAddress))
    {
      result.success = false;
      return result;
    } 
    
    //filter spam keywords
    String tempSubject = (email.subject != null)?email.subject.toLowerCase():'';
    for(String keyword : emailSetup.spamKeywordList)
    {
      if(keyword == null)
      {
        keyword = '';
      }
      if(keyword.trim() != '')
      {
          if(tempSubject.contains(keyword.toLowerCase()))
          { 
            result.success = true;
            return result; 
          }
      } 
    }
    
    //filter drop email address
    for(String address : emailSetup.dropEmailList)
    {
        if(fromAddress == address)
        {
            result.success = true;
            return result;
        }
    }
    
    try
    {  
      
      //checks whether an existing case is specified
      String[] caseNumbers = parseCaseNumber(email.subject);
      if(caseNumbers != null && caseNumbers.size() > 0)
      {
        Case[] cases = [select Id, ownerId, CaseNumber, Subject, Priority, Severity__c, Description from Case where CaseNumber in :caseNumbers limit 1];
        if(cases.size() > 0)
        {
          //case exists, update it
          Case theCase = cases[0];  
          Internal_Discussion__c discussion = insertCaseComment(theCase, email);
          addAttachmentsToCase(discussion, email);
          result.success = true;
        }
        else
        {
          //no such case exists, return an error message
          result.success = false;
          result.message = 'No such case found, or no case number specified in your subject.';
        }
      }
    }
    catch(exception e)
    {  
      result.success = false;
      result.message = 'An error ocurred when processing an email, the error message is ->' + e.getMessage();
    }
    return result;   
  }  
  
    //extracts the id between the first pair of brackets
    private static String[] parseCaseNumber(String subject)
    {
        Pattern caseNumberPattern = Pattern.compile('\\[([0-9]{8}-[0-9]{4,})\\]');
        String[] returnedCaseNumbers = new List<String>();
        Matcher caseNumberMatcher = caseNumberPattern.matcher(subject);
        while (caseNumberMatcher.find()) 
        {
            returnedCaseNumbers.add(caseNumberMatcher.group(1));
        }
        return returnedCaseNumbers;
    }
  
  //creates a new contact with the specified email address and sender name.
  private static Contact createContactByMail(String emailAddress, String senderName)
  {
    String firstName = '';
    String lastName = '';
    if(senderName != null && senderName != '' && !senderName.contains('@'))
    {
      Integer spaceIdx = senderName.lastIndexOf(' ');
      if(spaceIdx >= 0)
      {
          firstName = senderName.substring(0, spaceIdx);
          lastName = senderName.substring(spaceIdx + 1);
      }
      else
      {    
         lastName = senderName;
      }
    }
    else
    {
        Integer atIdx = emailAddress.indexOf('@');
        lastName = emailAddress.substring(0, atIdx);
    }
    List<Account> acct = [select Id from Account where Name = 'Silver Peak Systems' limit 1];
    Contact contact = new Contact(LastName = lastName, FirstName = firstName, Email = emailAddress, LeadSource = 'Customer Service');
    if(acct.size() > 0)
    {
        contact.AccountId = acct[0].Id;
    }
    insert contact;
    return contact;
  }
  
  //adds attachment to the specified InternalDiscusion object
  private static void addAttachmentsToCase(Internal_Discussion__c discussion, Messaging.InboundEmail email)
  {
    Attachment[] attachments = new List<Attachment>();
    String pId = discussion.Id;
    
    if(email.BinaryAttachments != null)
    {
      //adds BinaryAttachment to the object
      for(Messaging.InboundEmail.BinaryAttachment ba : email.BinaryAttachments)
      {
        Attachment ac = new Attachment(Body = ba.Body, ParentId = pId, Name = ba.fileName);  
        attachments.add(ac);    
      }
    }
    if(email.TextAttachments!=null)
    {
      //adds TextAreaAttachment to the object
      for(Messaging.InboundEmail.TextAttachment taa : email.TextAttachments)
      {
        Attachment ac = new Attachment(Body=Blob.valueOf(taa.Body),ParentId=pId, Name=taa.fileName);          
        attachments.add(ac);
      }
    }
    if(attachments != null && attachments.size() > 0)
    insert attachments;
  }

  //adds a comment to case
  private static Internal_Discussion__c insertCaseComment(Case theCase, Messaging.InboundEmail email)
  {
    String caseId = theCase.Id;
    String delimiter = emailSetup.delimiter;
    String body = email.plainTextBody;
    if(delimiter != null && delimiter != '' && body != null)
    {
        List<String> splitBodys = body.split(delimiter);
        if(splitBodys.size() > 0)
        {
            body = splitBodys[0];
        }
    }
    Internal_Discussion__c discussion = new Internal_Discussion__c(Case__c=caseId, Subject__c= email.subject, Body__c=body, From__c=email.fromAddress);
    insert discussion;
    return discussion;
  }
  
  //checks if there is already a case created with the specified subject with in 5 minutes.
  private static Boolean isDuplicateCase(string theSubject, string fromAddress)
  {
    List<Case> cases = [select Id, CreatedDate  from Case where Subject = :theSubject and contact.Email = :fromAddress order by CreatedDate desc limit 1];
    if(cases.size() == 1)
    {
      Datetime theTime = cases[0].CreatedDate.addMinutes(5);
      if(theTime > System.now())
      {
        return true;
      }
    }
    return false;
  }
  
  @isTest
  static void testIsDuplicateCase()
  {
      Contact newContact = new Contact(LastName = 'acmeLastName', Email='acme@mail.com');
      insert newContact;
      Case newCase = new Case(Subject='acme 1981', ContactId=newContact.Id);
      insert newCase;
      System.assertEquals(true, isDuplicateCase('acme 1981', 'acme@mail.com'));
  }
  
    @isTest 
    static void testParseCaseNumber()
    {
        String[] caseNumbers = parseCaseNumber('test[20100101-2015]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = parseCaseNumber('test[2015]');
        System.assertEquals(0, caseNumbers.size());
        
        caseNumbers = parseCaseNumber('test[20100101-2015]ab[abcdefg]');
        System.assertEquals(1, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        
        caseNumbers = parseCaseNumber('test[20100101-2015]ab[20110101-34567]');
        System.assertEquals(2, caseNumbers.size());
        System.assertEquals('20100101-2015', caseNumbers[0]);
        System.assertEquals('20110101-34567', caseNumbers[1]);
    }
  
  @isTest
  static void testCreateContactByMail()
  {
      createContactByMail('test@test.com', 'kevin chong');
      List<Contact> contacts = [select Id, FirstName, lastName, Email from Contact where Email='test@test.com' and FirstName='kevin' and LastName='chong' limit 1];
      System.assertEquals(1, contacts.size());
  }
  
  @isTest
  static void testCaseUpdatesEmailHandler()
  {
      Case testCase = new Case(Subject='acme');
      insert testCase;
      testCase = [select Id, CaseNumber from Case where Id=:testCase.Id limit 1];
      
      Messaging.Inboundemail testEmail = new Messaging.Inboundemail();
      testEmail.subject = 'acme subject [' + testCase.CaseNumber + ']';
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
      
      CaseUpdatesEmailHandler handler = new CaseUpdatesEmailHandler();
      handler.handleInboundEmail(testEmail, testEnvelope);
    
      List<Internal_Discussion__c> discussions = [select Id from Internal_Discussion__c where Case__c=:testCase.Id];
      System.assertEquals(1, discussions.size());
    /*(new CaseUpdatesEmailHandler()).handleInboundEmail(testEmail, testEnvelope);
    //Test for illegal condition.
    Messaging.Inboundemail illegalFromNameEmail = new Messaging.Inboundemail();
    illegalFromNameEmail.fromName = 'system administrator';
    (new CaseUpdatesEmailHandler()).handleInboundEmail(illegalFromNameEmail, testEnvelope);*/
  }
 
}