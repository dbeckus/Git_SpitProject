global class PerfHelpEmailHandler implements Messaging.InboundEmailHandler 
{
   private static EmailSetupHelper.EmailSetupInfo emailSetup = EmailSetupHelper.getEmailSetup('PerfHelp'); 
    
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
    String tempSubject = email.subject.toLowerCase();
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
      //check whether the contact exists, we'll create a new contact if not
      Contact[] contacts = [select Id, Name from contact where email =:email.fromAddress limit 1];
      Contact contact = null;
      if(contacts.size() > 0)
      {
        contact = contacts[0];
      }
      if(contact == null)
      {  
        contact = createContactByMail(email.fromAddress, email.fromName);          
      }
      
      Case theCase = null;
      //check whether the mail is a new one or a reply
      String[] caseNumbers = parseCaseNumber(email.subject);
      if(caseNumbers != null && caseNumbers.size() > 0)
      {
        Case[] cases = [select Id, ownerId, CaseNumber, Subject, Priority, Severity__c, Description from Case where CaseNumber in :caseNumbers limit 1];
        if(cases.size() > 0)
        {
          theCase = cases[0];  
        }
      }

      if(theCase == null)
      {  
        //no such case exists, create new  
        theCase = createCaseByMail(email, contact.Id);  
        addAttachmentsToCase(theCase, email);      
      }
      else
      {  //case exists, update it
        system.debug('entry to the method');
        addAttachmentsToCase(theCase, email);
        insertCaseComment(theCase, email);
      }
      result.success = true;
    }
    catch(exception e)
    {  
      result.success = false;
      result.message = 'An error ocurred when processing an email, the error message is ->' + e.getMessage();
    }
    return result;
  }  
  
    //extract the id between the last pair of brackets
    public static String[] parseCaseNumber(String subject)
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
  
  //create a new contact with the specified email address and sender name.
  public static Contact createContactByMail(String emailAddress, String senderName)
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
    Contact contact = new Contact(LastName = lastName, FirstName = firstName, Email = emailAddress);
    insert contact;
    return contact;
  }
  
  //create a new case by email info.
  public static Case createCaseByMail(Messaging.InboundEmail email, Id contactId)
  {
    Case cs = new Case(ContactId=contactId, subject=email.subject, description=email.plainTextBody, status='Qualifying', Type='PerfHelp', PerfHelp_Request_Type__c='Product Component Change', RecordTypeId=emailSetup.caseRecordTypeId);          
    cs.OwnerId = '00G500000016yiB';  //default owner is queue Tier1
    insert cs;
    cs = [select CaseNumber, Id, OwnerId from Case where id=:cs.Id];
    return cs;
  }
  
  //add attachment to the specified case
  public static void addAttachmentsToCase(Case theCase, Messaging.InboundEmail email)
  {
    Attachment[] attachments = new List<Attachment>();
    String caseId = theCase.Id;
    
    if(email.BinaryAttachments != null)
    {
      //add BinaryAttachment to the object
      for(Messaging.InboundEmail.BinaryAttachment ba : email.BinaryAttachments)
      {
        Attachment ac = new Attachment(Body = ba.Body, ParentId = caseId, Name = ba.fileName);  
        attachments.add(ac);    
      }
    }
    if(email.TextAttachments!=null)
    {
      //add TextAreaAttachment to the case object
      for(Messaging.InboundEmail.TextAttachment taa : email.TextAttachments)
      {
        Attachment ac = new Attachment(Body=Blob.valueOf(taa.Body),ParentId=caseId, Name=taa.fileName);          
        attachments.add(ac);
      }
    }
    if(attachments != null && attachments.size() > 0)
    insert attachments;
  }

  //add a comment to case
  public static CaseComment insertCaseComment(Case theCase, Messaging.InboundEmail email)
  {
    system.debug('Entered the method');
    String caseId = theCase.Id;
      system.debug('thecase:'+ caseId);
    String delimiter = emailSetup.delimiter;
    String body = email.plainTextBody;
      system.debug('body:'+ body);
    if(delimiter != null && delimiter != '' && body != null)
    {
        List<String> splitBodys = body.split(delimiter);
        if(splitBodys.size() > 0)
        {
            body = splitBodys[0];
        }
        if(body.length()>4000)
        {
            body=body.substring(0,3999);
        }
    }
      system.debug('exactly before case comment creation');
    CaseComment cc = new CaseComment(ParentId=caseId, CommentBody=body, isPublished=true);
    insert cc;
      system.debug('case comment inserted');
    if(email.fromAddress.contains('@silver-peak.com'))
    {
        theCase.UpdatedBy__c = 'Owner';
    }
    else
    {
        theCase.UpdatedBy__c = 'Customer';
    }
    update theCase;
      system.debug('updated by info:' + theCase.UpdatedBy__c);
    return cc;
  }
  
  //checks if there is already a case created with the specified subject with in 5 minutes.
  public static Boolean isDuplicateCase(string theSubject, string fromAddress)
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
}