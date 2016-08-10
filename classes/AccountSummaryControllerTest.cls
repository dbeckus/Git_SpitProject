@isTest 
public class AccountSummaryControllerTest {

   public static void createTestAccounts() { 
      List<Account> accounts = new List<Account>{};
      for( Integer i =1; i <= 10; i++) {
          accounts.add(new Account(Name='Test Company ' + i));  
      }
      for( Integer i =1; i <= 5; i++) {
          accounts.add(new Account(Name='ATT ' + i));  
      }  
      insert accounts;
      ApexPages.StandardController sc = new ApexPages.StandardController(accounts[0]);
      AccountSummaryController ext = new AccountSummaryController(sc);
      System.assertEquals(ext.account, accounts[0]);
      List<Account> accts = AccountSummaryController.getAccounts('AT');
      
   }   
}