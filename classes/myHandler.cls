global class myHandler implements Messaging.InboundEmailHandler 
{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
	{ 
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		//code below count the total number of the inbound emails
		Email_Log__c emailLog = new Email_Log__c(Name = email.subject);
        insert emailLog;
		//filte the email from system administrator
		if(email.fromName != null)
		{
			if(email.fromName.toLowerCase().contains('system administrator'))
			{
				result.success = true;
				return result;
			}
		}
		
		//filter to avoid the duplicate cases
        if(checkDuplicateCase(email.subject))
		{
			result.success = false;
			return result;
		}
		
		//this string stores the keywords, the keywords are split by ; and all the characters are in low case.
		String keyWordString = 'mail delivery failure;out of office;undeliverable;spam notification';
		String[] keyWords = keyWordString.split(';');
		String tempSubject = email.subject.toLowerCase();
		for(String keyWord : keyWords)
		{
			if(tempSubject.contains(keyWord))
			{
				result.success = true;
				return result; 
			} 
		}

		String fromAddress = email.fromAddress;
		try
		{	
			Case theCase = null;
			//check whether the mail is a new one or a reply
			String caseNumber = parseCaseNumber(email.subject);
			if(caseNumber != null)
			{
				Case[] cases = [select Id, ownerId, CaseNumber, Subject, Priority, Severity__c, Description from Case where CaseNumber=:caseNumber limit 1];
				if(cases.size() > 0)
				{
					theCase = cases[0];	
				}
			}

			//check whether the contact exists, we'll create a new contact if not
			Contact[] contacts = [select Id, Name from contact where email =: email.fromAddress limit 1];
			Contact contact = null;
			if(contacts.size() > 0)
			{
				contact = contacts[0];
			}
			if(contact == null)
			{	
				contact = createContactByMail(email.fromAddress);					
			}

			if(theCase == null)
			{	
				//no such case exists, create new	
				theCase = createCaseByMail(email, contact.Id);	
				addAttachmentsToCase(theCase, email);			
			}
			else
			{	//case exists, update it
				addAttachmentsToCase(theCase, email);
				insertCaseComment(theCase, email);
			}
			result.success = true;
		}
		catch(exception e)
		{	
			result.success = true;
			result.message = 'An error ocurred when processing an email, the error message is ->' + e.getMessage();
		}
		return result;
	}	
	
	//extract the id between the last pair of brackets
	private String parseCaseNumber(string subject)
	{
		Integer startIndex = subject.lastIndexOf('[')+1;
		Integer endIndex = subject.lastIndexOf(']');
		Integer length = endIndex - startIndex;
		if(length >= 13 && length <= 17)
		{
			if(subject.Substring(startIndex + 8, startIndex + 9) == '-')
			{
				return subject.Substring(startIndex, endIndex);
			}
			else
			{
				return null;
			}
		}
		else
		{
			return null;
		}
	}
	
	//get the contact name
	private string[] parseContactName(string contactAddress)
	{
		string[] result = new string[2];
		string fName = '', lName = '';
		if(contactAddress.contains('"'))
		{
			Integer firstQuote = contactAddress.indexOf('"');
			String namesStr = contactAddress.subString(firstQuote+1, contactAddress.indexOf('"', firstQuote+1));
			String[] names = namesStr.split('\\s+', 2);
			if(names[1] != null)
			{
				fName = names[0];
				lName = names[1];
			}
			else
			{
				fName = '';
				lName = namesStr;
			}
			return new String[] {lName, fName};
		}
		else if (contactAddress.contains('<') && contactAddress.contains('>'))
		{
			contactAddress = contactAddress.subString(contactAddress.indexOf('<') + 1, contactAddress.indexOf('>'));
		}
		contactAddress = contactAddress.ReplaceAll('(?>@).+','');
		return new String[] {contactAddress, ''};
	}
	
	//create a new contact by email info.
	private Contact createContactByMail(string emailAddress)
	{
		string[] names = parseContactName(emailAddress);
		Contact contact = new Contact(lastName = names[0], email = emailAddress);
		if(names[1] != null && names[1] != '')
		{
			contact.firstName = names[1];
		}
		insert contact;
		return contact;
	}
	
	//create a new case by email info.
	private Case createCaseByMail(Messaging.InboundEmail email, Id contactId)
	{
		Case cs = new Case(ContactId=contactId, subject=email.subject, description=email.plainTextBody, status='Qualifying', Type='Incoming Email', CreatedByApex__c=true, RecordTypeId='012500000005AuO');					
		cs.ownerId='00G500000016yiB';
		insert cs;
		cs=[select CaseNumber, Id, ownerId from Case where id=:cs.Id];
		return cs;
	}
	
	//add attachment to the specified case
	private void addAttachmentsToCase(Case theCase, Messaging.InboundEmail email)
	{
		Attachment[] attachments = new List<Attachment>();
		String caseId = theCase.Id;
		
		if(email.BinaryAttachments != null)
		{
			//add BinaryAttachment to the object
			for(Messaging.InboundEmail.BinaryAttachment ba : email.BinaryAttachments)
			{
				Attachment ac = new Attachment(Body = ba.Body, ParentId = caseId, name = ba.fileName);	
				attachments.add(ac);		
			}
		}
		if(email.TextAttachments!=null)
		{
			//add TextAreaAttachment to the case object
			for(Messaging.InboundEmail.TextAttachment taa:email.TextAttachments)
			{
				Attachment ac = new Attachment(Body=Blob.valueOf(taa.Body),ParentId=caseId,name=taa.fileName);					
				attachments.add(ac);
			}
		}
		if(attachments != null && attachments.size() > 0)
		insert attachments;
	}

	//add a comment to case
	private CaseComment insertCaseComment(Case theCase, Messaging.InboundEmail email)
	{
		String caseId = theCase.Id;
		CaseComment cc = new CaseComment(ParentId=caseId, CommentBody=email.plainTextBody, isPublished=true);
		insert cc;
		theCase.CreatedByApex__c = true;	//update this field to trigger a workflow to send email
		update theCase;
		return cc;
	}
	
	private Boolean checkDuplicateCase(string theSubject)
	{
		List<Case> cases = [select Id, CreatedDate from Case where Subject = :theSubject order by CreatedDate desc limit 1];
		System.debug(cases);
		if(cases.size() == 1)
		{
			System.debug(cases[0]);
			Datetime theTime = cases[0].CreatedDate.addMinutes(5);
			System.debug(theTime);
			if(theTime > System.now())
			{
				return true;
			}
		}
		return false;
	}
}