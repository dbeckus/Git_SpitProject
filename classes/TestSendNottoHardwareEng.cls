@IsTest
public class TestSendNottoHardwareEng {
    
   /* @IsTest
    public static void TestSendNotification()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
            new Product2(Name='acme1', ProductCode='acme1'),
                new Product2(Name='acme2', ProductCode='acme2'),
                new Product2(Name='acme3', ProductCode='acme3') };
                    insert pros;
        Product2 pro = new Product2(Name='acme', ProductCode='acme', Model__c='acme', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        
        RMA__c rma = new RMA__c();
        rma.Status__c='Initiated';
        rma.Type__c='Advance Replace';
        rma.Account__c=acc.Id;
        insert rma;
        RMA_Item__c rmaItem = new RMA_Item__c();
        rmaItem.RMA__c=rma.id;
        rmaItem.Asset__c= asset.id;
        rmaItem.Product2__c= pro.id;
        rmaItem.Type__c='Advance Ship Unit';
        rmaItem.Status__c='Initiated';
        insert rmaItem;
        
        rma.Status__c='In FA/Recd';
        rma.Disposition__c='ENG FA';
        rma.Disposition_Notes__c='test';
        update rma;
        
    }*/
}