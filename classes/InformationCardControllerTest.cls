@isTest
public class InformationCardControllerTest {
    @isTest
    static void testInformationCard()
    {
        Account acct = new Account(Name='testAcct');
        insert acct;
        Information_Card__c card = new Information_Card__c(Account__c=acct.Id, Status__c = 'New');
        insert card;
        ApexPages.currentPage().getparameters().put('id', card.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(card);
        InformationCardController ic = new InformationCardController(controller);
    }
}