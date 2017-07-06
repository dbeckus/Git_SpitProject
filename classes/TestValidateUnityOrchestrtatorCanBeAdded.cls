@IsTest
public class TestValidateUnityOrchestrtatorCanBeAdded {
    @IsTest
    public static void TestOrchCannotBeAddedonPOC()
    {
        Test.startTest();
        Account acc = new Account(Name='testECPOC',Unity_Orch_Admin_User__c='abc@abc.com',Unity_Orch_Domain__c='test123',Unity_Orch_Location__c='US East (N. Virginia) (Current Production)');
        insert acc;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Opportunity__c= opportunity.id;
        request.Evaluation_Product_1__c='EC-XS';
        request.Evaluation_Product_2__c='EC-XS';
        request.Quantity_Location_1__c=1;
        request.Quantity_Location_2__c=1;
        request.Is_Unity_Cloud_Orchestrator__c=true;
        insert request;
        try
        {
            request = new Request__c(POC_Contact__c = contact.Id);
            request.POC_Type__c='EdgeConnect';
            request.Opportunity__c= opportunity.id;
            request.Evaluation_Product_1__c='EC-XS';
            request.Evaluation_Product_2__c='EC-XS';
            request.Quantity_Location_1__c=1;
            request.Quantity_Location_2__c=1;
            request.Is_Unity_Cloud_Orchestrator__c=true;
            insert request;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Unity Cloud Orchestrator cannot be requested as there is an existing active cloud orch asset or POC on this account.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
    }
     
}