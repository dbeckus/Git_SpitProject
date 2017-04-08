@IsTest
public class TestTriggerActiveAssetCountFromContract {
	@IsTest
    public static void TriggerAssetCountContractStatusChange()
    {
        Account acc = new Account(name='acme',Type='Prospect');
        insert acc;
        Contract con= new Contract();
        con.AccountId=acc.id;
        con.Contract_Type__c='Gold';
        insert con;
        
        con.Status='Activated';
        update con;
        
        Account testAcc= [Select Trigger_Active_Asset_Count__c from Account where Id=:acc.id];
        System.assert(testAcc.Trigger_Active_Asset_Count__c==true);
        
    }
    
    @IsTest
    public static void TriggerAssetCountContractAccountChange()
    {
        Account acc = new Account(name='acme',Type='Prospect');
        insert acc;
        Account acc1 = new Account(name='acme 1',Type='Prospect');
        insert acc1;
        Contract con= new Contract();
        con.AccountId=acc.id;
        con.Contract_Type__c='Gold';
        insert con;
        
        con.AccountId=acc1.Id;
        update con;
        Account testAcc= [Select Trigger_Active_Asset_Count__c from Account where Id=:acc.id];
        System.assert(testAcc.Trigger_Active_Asset_Count__c==true);
        
    }
    
}