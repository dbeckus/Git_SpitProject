/*
* receives email from support and converts to case/comments
*/
global class CaseSupportEmailHandler implements Messaging.InboundEmailHandler 
{
    private static EmailSetupHelper.EmailSetupInfo emailSetup = EmailSetupHelper.getEmailSetup('Support'); 
    private static final Id BounceEmailTemplateId = '00X50000001ZTAm';
    private static final Id Tier1Id = '00G500000016yiB';
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    { 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        //code below count the total number of the inbound emails
        String emailSubject = (email.subject != null && email.subject.length() > 80)?email.subject.substring(0, 80):email.subject;
        Email_Log__c emailLog = new Email_Log__c(Name = emailSubject);
        insert emailLog;
        
        String fromAddress = email.fromAddress;
        //filter the email from system administrator
        if(email.fromName != null)
        {
            if(email.fromName.toLowerCase().contains('system administrator'))
            {
                result.success = true;
                return result;
            }
        }
        
        //filter to avoid duplicate cases being created in a short time
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
            boolean isAutoCase=isAutoEmail(email.subject);
            System.debug('isAutoCase'+isAutoCase);
            boolean isECCheck=false;
            String[] subjectValues;
            String assetNumber = '';
            String emailAddress = '';
            String priority = '';
            string ecCheck='';
            if(isAutoCase)
            {
                subjectValues= parseSubjectValues(email.subject);
                assetNumber = subjectValues[0];
                emailAddress = subjectValues[1];
                priority = subjectValues[2];
                ecCheck=subjectValues[3];
                if(!subjectValues.isEmpty() && !String.isEmpty(ecCheck))
                {
                    isECCheck=true;
                }
            }
             System.debug('isECCheck'+isECCheck);
            if(isAutoCase && !isECCheck)
            {
                //subjectValues = parseSubjectValues(email.subject);
                //String assetNumber = subjectValues[0];
                //String emailAddress = subjectValues[1];
                //String  priority = subjectValues[2];
                Contact contact = findContactByEmail(emailAddress);
                Asset asset = findAssetByNumber(assetNumber);
                if(asset != null)
                {
                    if(contact == null)
                    {
                        Map<String, String> bodyValues = parseBodyValues(email.plainTextBody);
                        String contactName = emailAddress;
                        if(bodyValues.containsKey('Name'))
                        {
                            contactName = bodyValues.get('Name');
                        }
                        contact = createContactByMail(emailAddress, contactName, asset.AccountId);
                    }
                    createCaseByMail(email, contact.Id, asset.Id, priority);
                    result.success = true;
                }
                else
                {
                    result.success = false;
                    result.message = 'Asset cannot be found.';
                }
            }
            else
            {
                //check whether the contact exists, we'll create a new contact if not
                Contact contact = findContactByEmail(email.fromAddress);
                if(contact != null)
                {   
                    //check whether the mail is a new one or a reply
                    String[] caseNumbers = parseCaseNumber(email.subject);
                    Case theCase = findCaseByNumber(caseNumbers);
                    
                    if(theCase == null)
                    {  
                        //no such case exists, create new  
                        theCase = createCaseByMail(email, contact.Id);  
                        addAttachmentsToCase(theCase, email);      
                    }
                    else
                    {  //case exists, update it
                        addAttachmentsToCase(theCase, email);
                        insertCaseComment(theCase, email);
                    }
                    result.success = true;
                }
                else if(isECCheck)
                {
                     Case theCase = createCaseByMail(email, null); 
                     addAttachmentsToCase(theCase, email);
                }
                else
                {
                    //Stop creating contact, Feb 27, 2014
                    //contact = createContactByMail(email.fromAddress, email.fromName);
                    bounceEmailBack(email.fromAddress, result);
                }
            }
        }
        catch(exception e)
        {  
            result.success = false;
            result.message = 'Your message could not be processed. This is often because the body of the email was too large. Please resend in multiple emails of smaller size to add your comments to the case';
            String errorMessage = e.getMessage();
            result.message = errorMessage;
            if(!errorMessage.contains('STRING_TOO_LONG') && !errorMessage.contains('MAXIMUM_SIZE_OF_ATTACHMENT'))
            {
                SilverPeakUtils.logException('Silver Peak Exception in CaseSupportEmailHandler', 'An error ocurred when processing the email, the error message is ->' + errorMessage);
            }
        }
        return result;
    }  
    
    private static void bounceEmailBack(String emailAddress, Messaging.InboundEmailResult result)
    {
        result.success = false;
        List<EmailTemplate> templates = [select Id, Body from EmailTemplate where Id=:BounceEmailTemplateId limit 1];
        if(templates.size() > 0)
        {
            result.message = templates[0].Body;
        }
        else
        {
            result.message = 'contact does not exist';
        }
    }
    
    @testvisible
    public static Boolean isAutoEmail(String subject)
    {
        String regex1 = 'AUTOCASE:[\\s]*\\[[\\w\\d\\-]{17}\\]:\\[.+\\]:\\[.+\\]';
        String regex2 = 'AUTOCASE:[\\s]*\\[[\\w\\d]{12}\\]:\\[.+\\]:\\[.+\\]';
        String regex3 = 'AUTOCASE:[\\s]*\\[[\\w\\d\\-]{17}\\]:\\[.+\\]:\\[.+\\]:\\[.+\\]';
        String regex4 = 'AUTOCASE:[\\s]*\\[[\\w\\d]{12}\\]:\\[.+\\]:\\[.+\\]:\\[.+\\]';
        return Pattern.matches(regex1, subject) || Pattern.matches(regex2, subject)|| Pattern.matches(regex3, subject)|| Pattern.matches(regex4, subject);
    }
    
    
    
    @testvisible
    public static List<String> parseSubjectValues(String subject)
    {
        Pattern subjectPattern1 = Pattern.compile('AUTOCASE:[\\s]*\\[(.+)\\]:\\[(.+)\\]:\\[(.+)\\]:\\[(.+)\\]');
        Matcher subjectMatcher1 = subjectPattern1.matcher(subject);
        Pattern subjectPattern2 = Pattern.compile('AUTOCASE:[\\s]*\\[(.+)\\]:\\[(.+)\\]:\\[(.+)\\]');
        Matcher subjectMatcher2 = subjectPattern2.matcher(subject);
        if(subjectMatcher1.matches() &&  subjectMatcher1.groupCount() == 4 )
        {
            String asset = subjectMatcher1.group(1);
            String email = subjectMatcher1.group(2);
            String priority = subjectMatcher1.group(3);
            String gmsCheck=subjectMatcher1.groupCount() == 4?subjectMatcher1.group(4):'';
            return new List<String> { asset, email, priority, gmsCheck };
                }
        else if(subjectMatcher2.matches() &&  subjectMatcher2.groupCount() == 3 )
        {
            String asset = subjectMatcher2.group(1);
            String email = subjectMatcher2.group(2);
            String priority = subjectMatcher2.group(3);
            return new List<String> { asset, email, priority,''};
                }
        else
        {
            return new List<String> {'', '', '',''};
                }
    }
    
    private static Map<String, String> parseBodyValues(String body)
    {
        Map<String, String> result = new Map<String, String>();
        for(String line : body.split('(\r\n)|\r|\n'))
        {
            if(line != null && line != '')
            {
                String[] items = line.split(':', 2);
                if(items.size() == 2)
                {
                    String key = items[0].trim();
                    String value = items[1].trim();
                    result.put(key, value);
                }
            }
        }
        return result;
    }
    
    private static Contact findContactByEmail(String email)
    {
        if(String.isNotBlank(email) && email.length() >= 2)
        {
            List<List<Contact>> result = [find :email In EMAIL FIELDS RETURNING Contact(Id, Name) limit 1];
            //Contact[] contacts = [select Id, Name from contact where Email=:email or Second_Email__c=:email or Third_Email__c=:email limit 1];
            if(result[0].size() > 0)
            {
                return result[0][0];
            }
        }
        return null;
    }
    
    private static Asset findAssetByNumber(String assetNumber)
    {
        assetNumber = assetNumber.replaceAll('\\-', '').replaceAll('\\.', '');
        Asset[] assets = [select Id, AccountId from Asset where Name=:assetNumber limit 1];
        if(assets.size() > 0)
        {
            return assets[0];
        }
        else
        {
            return null;
        }
    }
    
    private static Case findCaseByNumber(String[] caseNumbers)
    {
        Case[] cases = [select Id, ownerId, CaseNumber, Subject, Priority, Severity__c, Description from Case where CaseNumber in :caseNumbers limit 1];
        if(cases.size() > 0)
        {
            return cases[0];
        }
        else
        {
            return null;
        }
    }
    
    @testvisible
    //extract the id between the last pair of brackets
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
    
    @testvisible
    //create a new contact with the specified email address and sender name.
    private static Contact createContactByMail(String emailAddress, String senderName, Id accId)
    {
        String firstName = '';
        String lastName = '';
        senderName = (senderName != null) ? senderName.trim() : '';
        if(senderName != '' && !senderName.contains('@'))
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
        if(lastName == '' || lastName == null)
        {
            lastName = 'Unknown';
        }
        //List<Account> accs = [select Id from Account where Name='Email Support Contacts' order by CreatedDate desc limit 1];
        //Id accId = (accs.size() > 0) ? accs[0].Id : null;
        Contact contact = new Contact(AccountId=accId, LastName = lastName, FirstName = firstName, Email = emailAddress, leadSource = 'Customer Service');
        insert contact;
        return contact;
    }
    
    //create a new case by email info.
    private static Case createCaseByMail(Messaging.InboundEmail email, Id contactId)
    {
        return createCaseByMail(email, contactId, null, null);
    }
    
    //create a new case by email info.
    public static Case createCaseByMail(Messaging.InboundEmail email, Id contactId, Id assetId, String priority)
    {
        Case cs = new Case(ContactId=contactId, subject=email.subject, AssetId=assetId, description=email.plainTextBody, status='Qualifying', Type='Incoming Email', CreatedByApex__c=true, RecordTypeId=emailSetup.caseRecordTypeId);          
        cs.OwnerId = Tier1Id;  //default owner is queue Tier1
        if(priority != null)
        {
            cs.Priority = matchPriority(priority);
        }
        insert cs;
        cs = [select CaseNumber, Id, OwnerId from Case where id=:cs.Id];
        return cs;
    }
    
    
    
    private static String matchPriority(String priority)
    {
        if(priority != null && priority != '')
        {
            Schema.Describefieldresult priorityDescribe = Case.Priority.getDescribe();
            List<Schema.Picklistentry> priorityItems = priorityDescribe.getPicklistValues();
            for(Schema.Picklistentry entry : priorityItems)
            {
                if(entry.getValue().toLowerCase().contains(priority.toLowerCase()))
                {
                    return entry.getValue();
                }
            }
        }
        return priority;
    }
    
    //add attachment to the specified case
    private static void addAttachmentsToCase(Case theCase, Messaging.InboundEmail email)
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
        {
            insert attachments;
        }
    }
    
    //add a comment to case
    private static CaseComment insertCaseComment(Case theCase, Messaging.InboundEmail email)
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
        CaseComment cc = new CaseComment(ParentId=caseId, CommentBody=body, isPublished=true);
        insert cc;
        if(email.fromAddress.contains('@silver-peak.com'))
        {
            theCase.UpdatedBy__c = 'Owner';
        }
        else
        {
            theCase.UpdatedBy__c = 'Customer';
        }
        theCase.CreatedByApex__c = true;
        update theCase;
        return cc;
    }
    
    @testvisible
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
}