@IsTest
public class TestRMATriggerHandler {
   @isTest
    static void TestUpdateRMACountOnCase()
    {
        Account acc = new Account(Name = 'acme');
        insert acc;
        Case theCase = new Case(Subject = 'acme', AccountId = acc.Id);
        insert theCase;
        Case altCase = new Case(Subject = 'acme1', AccountId = acc.Id);
        insert altCase;
        RMA__c theRma = new RMA__c(Case__c = theCase.Id, Account__c = acc.Id);
        insert theRma;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(1, theCase.RMA_count__c); 
        delete theRma;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(0, theCase.RMA_count__c);
        undelete theRma;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(1, theCase.RMA_count__c);
        theRma.Case__c=altCase.Id;
        update theRMA;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(0, theCase.RMA_count__c);
    }
    @IsTest
    public static void TestSendNotificationToHardwareEngineering()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
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
        
    }
       @isTest
    static void TestCopyAccountTeamEmailOnRMA()
    {
        Account account = new Account(Name='acme');
        Account account2 = new Account(Name='acme2');        
        insert new Account[] { account, account2};
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');
        Opportunity opp2 = new Opportunity(Name = 'acme2', AccountId = account2.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');        
        insert new Opportunity[] { opp, opp2 };        
        AccountTeamMember member = new AccountTeamMember(AccountId = account.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Manager');        
        AccountTeamMember member2 = new AccountTeamMember(AccountId = account2.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Systems Engineer');
        insert new AccountTeamMember[]{ member, member2 };                      
        RMA__c rma = new RMA__c(Account__c = account.Id);
        RMA__c rma2 = new RMA__c(Account__c = account2.Id);        
        insert new RMA__c[]{ rma, rma2 };       
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma.Id][0].Account_Manager_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma2.Id][0].System_Engineer_Email_1__c);        
        member.TeamMemberRole = 'Systems Engineer';
        update member;        
        update rma;
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma.Id][0].System_Engineer_Email_1__c);
    }
     @isTest
    static void TestUpdateRMATrackingInfoToCase()
    {
        Account acc = new Account(Name = 'acme');
        insert acc;
        Case theCase = new Case(Subject = 'acme', AccountId = acc.Id);
        insert theCase;
        RMA__c theRma = new RMA__c(Case__c = theCase.Id, Account__c = acc.Id, Tracking_Information__c='test');
        insert theRma;
        
        theCase = [select Id, RMATrackingInfo__c from Case where Id=:theCase.Id limit 1];
        System.assertEquals('test', theCase.RMATrackingInfo__c);
        
        theRma.Tracking_Information__c = 'acme';
        update theRma;
        theCase = [select Id, RMATrackingInfo__c from Case where Id=:theCase.Id limit 1];
        System.assertEquals('acme', theCase.RMATrackingInfo__c);
    }
    @isTest
    static void TestDispatchRMAItem()
    {
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true);
        insert productA;
        Account acc = new Account(Name='acme');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
       
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productA.Id);
        insert item;
        
        rma.Status__c= 'Dispatched';
        update rma;
       
    }
    @isTest
    static void TestDispatchRejectedRMA()
    {
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true);
        insert productA;
        Account acc = new Account(Name='acme');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
       
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productA.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c='Part Number Not Found';
        update rma;
       
    }
}