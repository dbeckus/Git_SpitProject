@isTest 
public class AccountTimelineAssetsCountTest {

   public static void createTestAccounts() { 
      // fake test
       List<AccountWithTimeline__c> acctList = [SELECT Name__c, GMS__c, GX__c, NX__c, VRX__c, VX__c, SMALL__c, MEDIUM__c, LARGE__c FROM AccountWithTimeline__c];  
       for(AccountWithTimeline__c acct: acctList) {
           acct.GX__c = 10;
       }
       update acctList;
   }
}