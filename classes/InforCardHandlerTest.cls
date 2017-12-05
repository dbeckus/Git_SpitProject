@isTest
public class InforCardHandlerTest {
    @isTest
    static void testInforCardHandle()
    {
        Account acct = new Account(Name='testAcct');
        insert acct;
        Information_Card__c card1 = new Information_Card__c(Account__c=acct.Id, Status__c = 'New');
        insert card1;
        Information_Card__c card2 = new Information_Card__c(Account__c=acct.Id);
        insert card2;
        card1.Status__c = 'Rejected';
        update card1;
        //verify the status
        card1 = [Select Id, Status__c from Information_Card__c where Id =: card1.Id];
        system.assertEquals('Child Account Created', card1.Status__c);
        card2.Status__c = 'Approved';
        update card2;
        card2 = [Select Id, Status__c from Information_Card__c where Id =: card2.Id];
        system.assertEquals('Merged', card2.Status__c);
    }
}