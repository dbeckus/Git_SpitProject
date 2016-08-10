@IsTest
private class AcctWithTimelineTestClass {
    static void test()
    {        
        AccountWithTimeline__c acct = new AccountWithTimeline__c(Name = 'acme');
        acct.Total_Sales__c =13212342343.80;
        acct.Name__c = '0015000000Z7KhmAAF';
        acct.First_Order__c = Date.parse('2013-10-04');
        acct.Last_Order_Date__c = Date.parse('2013-12-04');
        acct.First_Order_Amt__c =123.80;
        acct.Ninety_Days_Total__c =1234.80;        
        acct.First_Year_Total__c = 234214.80;
        acct.Last_Order_Amt__c = 422.80;
        insert acct;  
        
    } 
}