@IsTest
public class TestSendEmailToOppOwner {
    
    @IsTest
    public static void SendEmailAfterQuoteApproved()
    {
        Account testAccount = new Account(Name='acme');
        insert testAccount;
        Account partnerAccount = new Account(Name='partnerAccount',Type='Partner',Partner_Type__c='Reseller');
        insert partnerAccount;
        Contact testContact = new Contact(LastName='acme',AccountId=partnerAccount.Id,Email='abc@abc.com');
        insert testContact;
        Opportunity testOpp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Open', ForecastCategoryName ='Pipeline', AccountId=testAccount.Id);
        insert testOpp;
        
        OpportunityContactRole obj= new OpportunityContactRole();
        obj.OpportunityId=testOpp.Id;
        obj.ContactId=testContact.Id;
        obj.Role='Partner Contact';
        insert obj;
        
        
        SBQQ__Quote__c quote= new SBQQ__Quote__c();
        quote.Product_Type__c='EDGECONNECT';
        quote.SBQQ__Opportunity2__c=testOpp.Id;
        quote.Reseller_Partner__c=partnerAccount.Id;
        quote.Distributor_Partner__c=partnerAccount.Id;
        quote.Prepared_For__c=testContact.Id;
        quote.ApprovalStatus__c='Pending';
        insert quote;
        
        quote.ApprovalStatus__c='Approved';
        quote.Trigger_Email__c=true;
        update quote;
    }
    
}