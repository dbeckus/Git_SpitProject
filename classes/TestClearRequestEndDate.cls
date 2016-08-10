@IsTest
public class TestClearRequestEndDate {
    
    
    @IsTest
    public static void ClearRequestEndDate_Test()
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
        
        
        Approval.ProcessSubmitRequest req1 =new Approval.ProcessSubmitRequest();
        req1.setComments('Automatic submit.');
        req1.setObjectId(request.id);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
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