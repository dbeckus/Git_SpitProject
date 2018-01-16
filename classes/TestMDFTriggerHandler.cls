@IsTest
public class TestMDFTriggerHandler {
  @isTest
    static void testCopyMdfToAccount()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        MDF_Request__c mdf = new MDF_Request__c(Account__c=acc.Id, Estimated_Silver_Peak_Amount__c=1000);
        insert mdf;
        
        acc = [select Id, Total_Requested_MDF__c from Account where Id=:acc.Id limit 1];
        System.assertEquals(1000, acc.Total_Requested_MDF__c);
    }
    
    @isTest
    static void testUpdateMdfStatusFromPR()
    {
        List<User> prApprovers = [select Id from User where PR_Approver__c=true limit 1];
        List<RecordType> mdfRecordType = [select Id from RecordType where Name='MDF Request' and SObjectType='Purchasing_Request__c' limit 1];
        Purchasing_Request__c pr = new Purchasing_Request__c(First_Approver__c=prApprovers[0].Id, RecordTypeId=mdfRecordType[0].Id);
        insert pr;
        MDF_Request__c mdf = new MDF_Request__c(Purchasing_Request__c=pr.Id);
        insert mdf;
        
        pr.Approval_Status__c = 'Final Approval';
        update pr;
        mdf = [select Id, Approval_Status__c from MDF_Request__c where Id=:mdf.Id limit 1];
        System.assertEquals('Approved', mdf.Approval_Status__c);
    }
     @isTest
    static void testSubmitPurchaseRequestOnMdfApproval()
    {
        List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType='Purchasing_Request__c' and Name='MDF Request' limit 1];
        Purchasing_Request__c purchase = new Purchasing_Request__c();
        purchase.RecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
        insert purchase;
        
        MDF_Request__c request = new MDF_Request__c(Purchasing_Request__c=purchase.Id);
        insert request;
        
        request.Approval_Status__c = 'Approved';
        request.Approval_Status_Hidden__c = 'Approved';
        try
        {
            update request;
        }
        catch(Exception ex) {}
    }
    
    @isTest
    static void testMDFShare()
    {
        User portalUser = [select COntactId, COntact.AccountId from User where IsActive = true and UserType = 'PowerPartner' limit 1];
        MDF_Request__c mdf = new MDF_Request__c(Account__c = portalUser.Contact.AccountId);
        MDF_Request__c mdf2 = new MDF_Request__c(Account__c = portalUser.Contact.AccountId);
        insert new List<MDF_Request__c> {mdf, mdf2};
        mdf.Account__c = null;
        update mdf;
        ShareMDFToPartnerHelper.shareMDFs(new List<MDF_Request__c> {mdf, mdf2});
    }
    
    @isTest
    static void testMDFShareSchedule()
    {
        Test.startTest();
        ShareMDFToPartnerSchedule schedulable = new ShareMDFToPartnerSchedule();
        SchedulableContext ctx;
        schedulable.execute(ctx);
        Test.stopTest();
    }
    
    @isTest
    static void testMDFShareBatch()
    {
        Test.startTest();
        String soql = 'select Id, Account__c, OwnerId from MDF_Request__c where Account__c != null limit 1';
        ShareMDFToPartnerBatch currentBatchJob = new ShareMDFToPartnerBatch(soql);
        Database.executeBatch(currentBatchJob, 1);
        Test.stopTest();
    }
     @isTest
    static void testSubmitPurchaseRequestOnMdfApproval1()
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
    
     @isTest(seeAllData=true)
	public static void testSendEmailAndCreateCampaign()
    {
        List<User> currentUser = [Select Id, Profile.Name, Profile.Id, Name from User where Profile.Name != '13g-SP Partner Community' and IsActive = true limit 1];
        if(currentUser.isEmpty())
        {
            return;
        }
        Contact con = new Contact(LastName='Acme', Email='acme@test.com',FirstName='Acme');
        insert con;
        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', OwnerId = currentUser[0].Id, Contact__c = con.Id, Activity_Date__c = date.today());
        insert mdf;
        MDF_Request__c newMDF = [Select Id, Approval_status__c,Activity_Complete__c, MDF_Status__c, SendReminder__c from MDF_Request__c where Id =: mdf.Id];
        newMDF.Approval_Status__c = 'Approved';
        newMDF.Activity_Complete__c = false;
        newMDF.MDF_Status__c = 'Past Due';
        newMDF.SendReminder__c = true;
		Test.startTest();
        update newMDF;
        Test.stopTest();
		mdf = [Select Id, Campaign__c from MDF_Request__c where Id =: newMDF.Id];
		system.assertEquals(1, [Select Count() from Campaign where Id =: mdf.Campaign__c]);
    }
}