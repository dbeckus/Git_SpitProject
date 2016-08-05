@isTest
public class CaseAuditBatchJobTest
{
	@isTest
    static void testCaseAuditBatchJob()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        RecordType caseIncomingEmail = [select Id from RecordType where sObjectType='Case' and Name='Incoming Email' limit 1];
        Case cs = new Case(Subject='acme', ContactId=ct.Id, RecordTypeId=caseIncomingEmail.Id, Priority='P1 - Urgent', Status='Active');
        insert cs;
        cs.OwnerId = UserInfo.getUserId();  //override owner id after assignment rule
        update cs;
        
        Test.StartTest();
        CaseAuditBatchJob batch = new CaseAuditBatchJob();
        Database.executeBatch(batch, 10); 
        Test.StopTest();
    }
}