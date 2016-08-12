@IsTest
public class TestRMAListComponentController {
    @IsTest
    public static void Test()
    {
        Contact contact = new Contact(LastName = 'acme');
        insert contact;  
        RMAListComponentController controller = new RMAListComponentController();
        controller.RequestId = null;
        List<RMA__c> rmas = controller.RMAs;
        
        
    }
}