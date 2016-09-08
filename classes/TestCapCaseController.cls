@IsTest
public class TestCapCaseController {
    @IsTest
    public static void test1()
    {
        Account acc = new Account(Name='acc',IsCap__c=true);
        insert acc;
        Contact con = new Contact(FirstName='CapFirst',LastName='CapLastName',Email='captest@ac1222.com',AccountId=acc.Id);
        insert con;
        Case case1= new Case();
        case1.ContactId=con.Id;
        case1.AccountId=acc.Id;
        insert case1;
        ApexPages.StandardController stdCon= new ApexPages.StandardController(case1);
        CapCaseController obj = new CapCaseController(stdCon);
        
    }

}