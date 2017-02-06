@isTest
public class SubmitPurchaseRequestOnMdfApprovalTest {
    @isTest
    static void testSubmitPurchaseRequestOnMdfApproval()
    {
        List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType='Purchasing_Request__c' and Name='MDF Request' limit 1];
        Purchasing_Request__c purchase = new Purchasing_Request__c(First_Approver__c = UserInfo.getUserId());
        purchase.RecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
        insert purchase;
        Purchase_Request_Lines__c  prl = new Purchase_Request_Lines__c (Purchasing_Request__c = purchase.Id);
        insert prl;
        
        MDF_Request__c request = new MDF_Request__c(Purchasing_Request__c=purchase.Id);
        insert request;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setObjectId(request.Id);
        Approval.ProcessResult result = Approval.Process(req);
        
        request.Approval_Status_Hidden__c = 'Approved';
        update request;
    }
}