@IsTest
public class TestSetAccountNameFromCaseContact {
    
    /*@IsTest
    public static void UpdateAccountOnInsert()
    {
        Account acc = new Account(Name='Test Account1');
        insert acc;
        Account acc1 = new Account(Name='Test Account2');
        insert acc1;
        Contact con= new Contact(FirstName='Test Con',LastName='LastName',AccountId=acc.Id);
        insert con;
        Case caseInfo= new Case(ContactId=con.Id,AccountId=acc1.Id,Subject='Test',Origin='Email');
        insert caseInfo;
        Case caseoutput =[Select AccountId from Case where Id=:caseInfo.Id];
        System.assertEquals(acc.id, caseoutput.AccountId);
    }
    @IsTest
    public static void UpdateAccountOnUpdate()
    {
        Account acc = new Account(Name='Test Account1');
        insert acc;
        Account acc1 = new Account(Name='Test Account2');
        insert acc1;
        Contact con= new Contact(FirstName='Test Con',LastName='LastName',AccountId=acc.Id);
        insert con;
        Case caseInfo= new Case(ContactId=con.Id,Subject='Test',Origin='Email');
        insert caseInfo;
        Case caseoutput =[Select AccountId from Case where Id=:caseInfo.Id];
        System.assertEquals(acc.id, caseoutput.AccountId);
        Account acc3 = new Account(Name='Test Account2');
        insert acc3;
        Contact con3= new Contact(FirstName='Test Con',LastName='LastName',AccountId=acc3.Id);
        insert con3;
        caseoutput.ContactId=con3.Id;
        update caseoutput;
        
        Case caseoutput1 =[Select AccountId from Case where Id=:caseInfo.Id];
        System.assertEquals(acc3.id, caseoutput1.AccountId);
    }
    */
    
}