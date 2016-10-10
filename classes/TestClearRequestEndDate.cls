@IsTest
public class TestClearRequestEndDate {
    @isTest(SeeAllData=true)
    public static void ClearRequestEndDate_Test()
    {
        Account acc = new Account(Name='Test Acc');
        insert acc;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        
        insert opportunity;
        
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        usr.IsActive =true;
        insert usr;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Extension_Justification__c='Test';
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Type__c='Evaluation';
        request.Submission_Condition_Satisfied__c=true;
        request.Target_End_Date__c=Date.today().adddays(30);
        request.Status__c='Shipped - Extended';
        request.Opportunity__c=opportunity.Id;
        request.RSM__c=UserInfo.getUserId();
        request.RSM_Manager__c=UserInfo.getUserId();
        request.RSM_VP_Sales__c=UserInfo.getUserId();
        request.SE__c=UserInfo.getUserId();
        request.SE_Manager__c=UserInfo.getUserId();
        request.SE_Director__c=UserInfo.getUserId();
        request.VirtualProduct1__c = 'EC-BASE-1Y';
        request.VirtualQuantity1__c = 10;
        insert request;
        //request.Target_End_Date__c= Date.today().adddays(30);
        System.runAs(usr)
        {
            request.Requested_End_Date__c= Date.today().adddays(30);
            request.First_Extension_Granted__c=true;
            update request;
        }
        Request__c outputReq=[Select Id,Requested_End_Date__c from Request__c where Id=:request.id];
        System.assertEquals(null, outputReq.Requested_End_Date__c);
        
    }
    
    @IsTest
    public static void ClearRequestEndDate_ShouldnotClear()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.Extension_Justification__c='Test';
        
        request.TR_Approved__c=true;
        request.RSM_Approved__c=true;
        request.Submission_Condition_Satisfied__c=true;
        request.Target_End_Date__c=Date.today().adddays(5);
        request.Status__c='Shipped';
        insert request;
        request.Requested_End_Date__c= Date.today().adddays(30);
        update request;
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalQuantity1__c = 10;
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        
        Request__c outputReq=[Select Id,Requested_End_Date__c from Request__c where Id=:request.id];
        System.assertNotEquals(null, outputReq.Requested_End_Date__c);
        
    }
}