/*
 * 1. Sends email to the case owners if the open case has not been udpated in 10 days.
 * 2. Sends email to the case owner if there is a P1 open case has not been updated over 24 hrs.
 * 3. Sends email to case owner and cc to Shabib if there is a P1 open case has not been updated over 24 hrs.
 */
global class CaseAuditBatchJob implements Database.Batchable<sObject>, Database.Stateful
{
    private Integer caseCount = 0;
    private Integer userCount = 0;
    private Id EmailAddressId = null;
    
    //implement batch method 
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        List<OrgWideEmailAddress> emailAddresses = [select Id, DisplayName, Address from OrgWideEmailAddress where Address like 'notifications@%'];
        if(emailAddresses.size() > 0)
        {
            EmailAddressId = emailAddresses[0].Id;
        }
        if(Test.isRunningTest())
        {
            return Database.getQueryLocator([select Id, Email from User where Id=:UserInfo.getUserId() limit 1]);
        }
        else
        {
            return Database.getQueryLocator([select Id, Email from User where IsActive=true and Email like '%@silver-peak.com']);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEMailMessage>();

        for(User usr : scope)
        {
            Integer T10 = (Test.isRunningTest()) ? 0 : 9;
            List<Case> openCasesOver10Days = [select Id, CaseNumber, Priority, Account.Name from Case where IsClosed=false and RecordType.Name in ('Incoming Email', 'Technical Support') and OwnerId=:usr.Id and Last_Update_Age__c >= :T10 order by Priority];
            if(openCasesOver10Days.size() > 0)
            {
                caseCount += openCasesOver10Days.size();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //email.setTargetObjectId('00530000000giMZ');  //for test purpose
                email.setTargetObjectId(usr.Id);
                email.setCcAddresses(new string[] { 'ssheikh@silver-peak.com' });
                email.setSubject('Case Audit');
                email.setHtmlBody(composeOpenCaseEmail(openCasesOver10Days));
                email.setSaveAsActivity(false);
                if(EmailAddressId != null)
                {
                    email.setOrgWideEmailAddressId(EmailAddressId);
                }
                mails.add(email);
            }
            Integer T1 = (Test.isRunningTest()) ? 0 : 1;
            List<Case> p1CasesT1 = [select Id, CaseNumber, Priority, Account.Name, Contact.Name, Contact.Phone, Description, LastModifiedDate from Case where IsClosed=false and RecordType.Name not in ('WANstart') and Priority='P1 - Urgent' and OwnerId=:usr.Id and Last_Update_Age__c=:T1];
            if(p1CasesT1.size() > 0)
            {
                caseCount += p1CasesT1.size();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //email.setTargetObjectId('00530000000giMZ'); //for test purpose
                email.setTargetObjectId(usr.Id);
                email.setSubject('Case Audit (P1)');
                email.setHtmlBody(composeP1OpenCaseEmail1(p1CasesT1));
                email.setSaveAsActivity(false);
                if(EmailAddressId != null)
                {
                    email.setOrgWideEmailAddressId(EmailAddressId);
                }
                mails.add(email);
            }
            Integer T2 = (Test.isRunningTest()) ? 0 : 2;
            List<Case> p1CasesT2 = [select Id, CaseNumber, Priority, Account.Name, Contact.Name, Contact.Phone, Description, LastModifiedDate from Case where IsClosed=false and Priority='P1 - Urgent' and RecordType.Name not in ('WANstart') and OwnerId=:usr.Id and Last_Update_Age__c>=:T2];
            if(p1CasesT2.size() > 0)
            {
                caseCount += p1CasesT2.size();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                //email.setTargetObjectId('00530000000giMZ');  //for test purpose
                email.setTargetObjectId(usr.Id);
                email.setCcAddresses(new string[] { 'ssheikh@silver-peak.com' });
                email.setSubject('Case Audit (P1)');
                email.setHtmlBody(composeP1OpenCaseEmail2(p1CasesT2));
                email.setSaveAsActivity(false);
                if(EmailAddressId != null)
                {
                    email.setOrgWideEmailAddressId(EmailAddressId);
                }
                mails.add(email);
            }
            if(openCasesOver10Days.size() > 0 || p1CasesT1.size() > 0 || p1CasesT2.size() > 0)
            {
                userCount++;
            }
        }
        if(mails.size() > 0)
        {
            if(!Test.isRunningTest())
            {
            	Messaging.sendEmail(mails);
            }
            mails = new List<Messaging.SingleEMailMessage>();
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if(caseCount > 0)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { 'prane@silver-peak.com' });
            email.setSubject('Case Audit Daily Summary');
            email.setPlainTextBody('Totally ' + userCount + ' users get notified. \r\nIncludes ' + caseCount + ' cases.\r\n' + Date.today().format());
            if(EmailAddressId != null)
            {
                email.setOrgWideEmailAddressId(EmailAddressId);
            }
            if(!Test.isRunningTest())
            {
            	Messaging.sendEmail(new Messaging.Email[] {email});
            }
        }
    }
    
    private String composeOpenCaseEmail(List<Case> cases)
    {
        String result = 'The following case(s) has not been updated in over ten days, please review and update as needed.<br/>';
        result += '<ul>';
        for(Case cs : cases)
        {
            result += '<li><a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + cs.Id + '">' + cs.CaseNumber + '</a>&nbsp;' + ((cs.Priority == null) ? '' : cs.Priority.substring(0, 2)) + '&nbsp;' + htmlEncode(cs.Account.Name) + '</li>';
        }
        result += '</ul>';    
        return result;
    }
    
    private String composeP1OpenCaseEmail1(List<Case> cases)
    {
        String result = 'Following case(s) is at "P1 - Urgent" and has not been updated over 24 hrs, please review and update as needed.<br/><br/>';
        result += '<table border="1" width="800px" style="border-collapse:collapse"><tr style="background-color:#eeeeee"><td>Case Number</td><td>Account Name</td><td>Contact</td><td>Phone Number</td><td>Last Modified Date</td><td>Description</td></tr>';
        for(Case cs : cases)
        {
            result += '<tr><td><a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + cs.Id + '">' + cs.CaseNumber + '</a></td><td>' + htmlEncode(cs.Account.Name) + '</td><td>' + htmlEncode(cs.Contact.Name) + '</td><td>' + cs.Contact.Phone + '</td><td>' + cs.LastModifiedDate.format() + '</td><td>' + htmlEncode(cs.Description) + '</td></tr>';
        }
        result += '</tr></table>';
        result += '<br/>If case is not a qualified P1 (system down, network down, competitive PoC), please set expectations with the customer and downgrade the case priority appropriately.';
        return result;
    }
    
    private String composeP1OpenCaseEmail2(List<Case> cases)
    {
        String result = 'Following case(s) is at "P1 - Urgent" and has not been updated over 48 hrs, please review and update as needed.<br/><br/>';
        result += '<table border="1" width="800px" style="border-collapse:collapse"><tr style="background-color:#eeeeee"><td>Case Number</td><td>Account Name</td><td>Contact</td><td>Phone Number</td><td>Last Modified Date</td><td>Description</td></tr>';
        for(Case cs : cases)
        {
            result += '<tr><td><a href="https://' + URL.getSalesforceBaseUrl().getHost() + '/' + cs.Id + '">' + cs.CaseNumber + '</a></td><td>' + htmlEncode(cs.Account.Name) + '</td><td>' + htmlEncode(cs.Contact.Name) + '</td><td>' + cs.Contact.Phone + '</td><td>' + cs.LastModifiedDate.format() + '</td><td>' + htmlEncode(cs.Description) + '</td></tr>';
        }
        result += '</tr></table>';
        result += '<br/>If case is not a qualified P1 (system down, network down, competitive PoC), please set expectations with the customer and downgrade the case priority appropriately.';
        return result;
    }
    
    private static String htmlEncode(String value)
    {
        if(value != null)
        {
            return value.replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');
        }
        else
        {
            return '';
        }
    }
}