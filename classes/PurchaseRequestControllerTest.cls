@isTest
public class PurchaseRequestControllerTest
{
    @isTest
    public static void testController()
    {
        Purchasing_Request__c request = new Purchasing_Request__c(Vendor_Name__c = 'acme',Temporary__c = true, Send_PO_to_Vendor__c='NO');
        PageReference refer = new PageReference('/apex/PurchaseRequest');
        Test.setCurrentPage(refer);
        PurchaseRequestController controller = new PurchaseRequestController(new ApexPages.StandardController(request));
        controller.init();
        List<Purchase_Request_Lines__c> lines = controller.getLines();
        controller.getApprovers();
        
        lines[0].Qty__c = 1;
        lines[1].Qty__c = 2;

        controller.addLine();
        
        PageReference page = new PageReference('/apex/PurchaseRequest?index=2');
        Test.setCurrentPage(page);
        controller.removeLine();
        
        controller.request.Vendor_Name__c= 'acme';
        controller.attach.Name = 'acme';
        controller.attach.Body = Blob.valueOf('acme');
        controller.saveFile();
        
        controller.save();
        
        String[] attachments = controller.FileNames;
        System.assertEquals(1, attachments.size());
        System.assert(controller.request.Id != null);
 
        controller.formReset();
    }
}