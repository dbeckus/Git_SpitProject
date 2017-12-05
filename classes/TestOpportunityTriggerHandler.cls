@IsTest
public class TestOpportunityTriggerHandler {
    @isTest
    public static void testTriggerPreventOpportunityDeletion()
    {
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Discovery');
        insert opp;
        
        User mockUser = [select Id from User where IsActive=true and Profile.PermissionsModifyAllData=false limit 1];
        System.runAs(mockUser)
        {
            try
            {
                delete opp;
                System.assert(true, 'You are not allowed to delete opportunities.');
            }
            catch(Exception ex) { /* Supposed to throw an exception */ }
        }
    }
    @IsTest
    public static void TestCalculateQuarterForOppData_Insert()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        Opportunity result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:opp.Id];
        System.assert(result.Fiscal_Quarter_Name__c!=null);
    }
    
    @IsTest
    public static void TestUpdateFirstOpportunityWinCheckBox_FirstOppClosed()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.Finance_Reviewed__c=true;
        opp.StageName='Closed Won';
        update opp;
        Opportunity result=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result.First_Win_Opportunity__c==true);
    }
    
    @IsTest
    public static void TestUpdateFirstOpportunityWinCheckBox_Uncheck()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.Finance_Reviewed__c=true;
        opp.StageName='Closed Won';
        update opp;
        Opportunity result=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result.First_Win_Opportunity__c==true);
        opp.StageName='PO in Process';
        update opp;
        Opportunity result1=[Select Id,First_Win_Opportunity__c from Opportunity where Id=:opp.Id];
        System.assert(result1.First_Win_Opportunity__c==false);        
    }
    
    
    @IsTest
    public static void TestCalculateQuarterForOppData_Update()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp = new Opportunity(Name='test', StageName='Discovery', CloseDate=Date.newInstance(2016,10,10),AccountId = acc.Id);
        insert opp;
        opp.CloseDate= Date.today().addDays(100);
        update opp;
        Opportunity result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:opp.Id];
        System.assert(result.Fiscal_Quarter_Name__c!=null);
    }
    
    @IsTest
    public static void CheckAllOppsUpdatedforAccount()
    {
        
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp1 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(30),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(100),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp2;
        Test.startTest();
        opp1.Finance_Reviewed__c=true;
        opp1.StageName='Closed Won';
        update opp1;
        
        List<Opportunity> result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:acc.Id];
        for(Opportunity opp: result)
        {
            System.assertEquals(opp.Type, 'Follow on Business');
        }
        Test.stopTest();
    }
    @IsTest
    public static void CheckAllOppsUpdatedforAccount_Clear()
    {
        
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        
        Opportunity opp1 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(30),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp1;
        Opportunity opp2 = new Opportunity(Name='test', StageName='New', CloseDate=Date.today().addDays(100),AccountId = acc.Id,Opportunity_Source__c='RSM',Type='New Business');
        insert opp2;
        Test.startTest();
        opp1.Finance_Reviewed__c=true;
        opp1.StageName='Closed Won';
        update opp1;
        
        List<Opportunity> result=[Select Id,Fiscal_Quarter_Name__c from Opportunity where Id=:acc.Id];
        for(Opportunity opp: result)
        {
            System.assertEquals(opp.Type, 'Follow on Business');
        }
        opp1.StageName='New';
        update opp1;
        Account acco=[Select Id, First_Asset_Quarter__c from Account where Id=:acc.Id];
        System.assertEquals(acco.First_Asset_Quarter__c, null);
        Test.stopTest();
    }
    @isTest
    public static void testMethodOne() {
        Account testAcct = new Account();
        testAcct.Name = 'Test Account';
        testAcct.Type = 'Prospect';
        insert testAcct;
        
        Contact testCon = new Contact();
        testCon.LastName = 'Test';
        testCon.email = 'test@example.com';
        testCon.phone = '1231231232';
        testCon.LeadSource = 'Inbound Call';
        testCon.Accountid = testAcct.Id;
        insert testCon;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opportunity';
        testOpp.Accountid = testAcct.Id;
        testOpp.Type = 'New Business';
        testOpp.CloseDate = System.Today() + 30;
        testOpp.StageName = 'New';
        insert testOpp;
        
        OpportunityContactRole testCR = new OpportunityContactRole();
        testCR.Contactid = testCon.Id;
        testCR.Opportunityid = testOpp.Id;
        insert testCR;
        
        update testOpp;
    } 
    @IsTest(SeeAllData=true)
    public static void TestData_Error()
    {
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship',Email='abc@abc.com');
        insert ct;
        Product2 prd = new Product2(Name='EC-XS', Family='Product', IsActive=true, ProductCode='500210-001');
        insert prd;
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        opportunity.Pricebook2Id = standardPricebookId;
        opportunity.StageName = 'New';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Contact__c = ct.id;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = '';
        pocRequest.PhysicalProduct1__c = 'EC-XS';
        pocRequest.Quantity_Location_1__c = 1;
        insert pocRequest;
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?pocId=' + pocRequest.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController controller = new ShippingInputFormController();
        controller.SNSets = '123456789012';
        controller.Process();
        controller.getProductList();
        controller.getPartNumberList();
        controller.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = controller.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        controller.ShippedLineList[0].SelectProductId = prd.Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            controller.save();
            
        }
        Test.stopTest();
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :controller.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        try
        {
            opportunity.StageName='Closed Dead';
            update opportunity;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This selected stage cannot be updated as it has active physical assets.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Opportunity resultOpp=[Select StageName from Opportunity where Id=:opportunity.Id];
        System.assertEquals('New', resultOpp.StageName);
    }
    
    @IsTest(SeeAllData=true)
    public static void TestData()
    {
        Account account = new Account(Name = 'test shipment');
        insert account;
        Contact ct = new Contact(AccountId = account.Id, LastName = 'test ship',Email='abc@abc.com');
        insert ct;
        Product2 prd = new Product2(Name='EC-XS', Family='Product', IsActive=true, ProductCode='500210-001');
        insert prd;
        
        Id standardPricebookId = TestUtilities.getStandardPricebookId();
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = account.Id;
        opportunity.Pricebook2Id = standardPricebookId;
        opportunity.StageName = 'New';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Product_Type__c='Both';
        opportunity.Solution_Type__c='Replication Acceleration';
        insert opportunity;
        
        Request__c pocRequest = new Request__c();
        pocRequest.Opportunity__c = opportunity.Id;
        pocRequest.POC_Contact__c = ct.id;
        pocRequest.POC_Type__c='EdgeConnect';
        pocRequest.GMS_Needed__c = '';
        pocRequest.PhysicalProduct1__c = 'EC-XS';
        pocRequest.Quantity_Location_1__c = 1;
        insert pocRequest;
        Test.startTest();
        PageReference pageRef = new PageReference('/apex/ShippingInputForm?pocId=' + pocRequest.Id);
        Test.setCurrentPage(pageRef);
        
        ShippingInputFormController controller = new ShippingInputFormController();
        controller.SNSets = '123456789012';
        controller.Process();
        controller.getProductList();
        controller.getPartNumberList();
        controller.Shipment.Ship_Date__c= Date.today();
        List<ShippingInputFormController.ShipLineInfo> lines = controller.ShippedLineList;
        //System.assert(controller.Shipment.POC_Request__c == pocRequest.Id);
        //System.assert(controller.ShippedLineList.size()==1);
        //System.assertEquals(false, lines[0].AssetIsExisted);
        controller.ShippedLineList[0].SelectProductId = prd.Id;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
            controller.save();
            
        }
        Test.stopTest();
        List<Shipment__c> shipmentList = [select Shipment_Account__c, Shipment_Contact__c, Shipment_Contract__c from Shipment__c where Id = :controller.Shipment.Id limit 1];
        System.assertEquals(1, shipmentList.size());
        try
        {
            opportunity.StageName='Meets Customer Requirements';
            update opportunity;
            
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('This selected stage cannot be updated as it has active physical assets.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Opportunity resultOpp=[Select StageName from Opportunity where Id=:opportunity.Id];
        System.assertEquals('Meets Customer Requirements', resultOpp.StageName);
        
    }
    @isTest
    public static void testUpdateOpportunity()
    {
        Contact con = new Contact(LastName = 'Test');
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'Test', StageName = 'Test', CloseDate = Date.today().addDays(10), ForecastCategoryName = 'Best Case');
        insert opp;
        
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c( SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = true, SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id);
        insert quote1;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c( SBQQ__Opportunity2__c = opp.Id, SBQQ__Primary__c = false, SBQQ__PrimaryContact__c = con.Id, Prepared_For__c = con.Id);
        insert quote2;
        
        opp.Contract_Activation_Date__c = Date.today();
        update opp;
        
        /*
System.assertEquals(Date.today(), [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote1.Id].SBQQ__StartDate__c);
System.assertEquals(null, [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote2.Id].SBQQ__StartDate__c);

opp.Contract_Activation_Date__c = null;
update opp;
System.assertEquals(Date.today().addDays(10), [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote1.Id].SBQQ__StartDate__c);
System.assertEquals(null, [select Id,SBQQ__StartDate__c from SBQQ__Quote__c where Id = :quote2.Id].SBQQ__StartDate__c);
*/
    }
    @isTest(SeeAllData = true)
    public static void testCreateWanStartCase()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Closed Won', AccountId=acc.Id, POC_Type__c='POC', Win_Description__c='test', Finance_Reviewed__c=true);
        insert opp;
        Product2 prod = [select Id, (select Id from PriceBookEntries limit 1) from Product2 where IsActive=true and Name like 'wanstart%' limit 1];
        OpportunityLineItem line = new OpportunityLineItem(OpportunityId=opp.Id, TotalPrice=1, Quantity=1, PriceBookEntryId=prod.PriceBookEntries[0].Id, Description='WANSTART test');
        insert line;
    }
    @isTest
    public static void testSetLeadSourceOnOpp()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Acme', AccountId = acc.Id, Opportunity_Source__c = 'EMC', Type = 'Fpllow on Business', CloseDate = System.today() + 1, StageName = 'Discovery', Probability = 5, ForecastCategoryName = 'Commit');
        insert opp;
        opp.Opportunity_Source__c = 'Dell';
        update opp;
    }
    @isTest
    public static void testRemoveOrphanedPOC()
    {
        Account account = new Account(Name='acme');
        insert account;
        Opportunity opp = new Opportunity(Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today(),Product_Type__c='Both');
        insert opp;
        Request__c request = new Request__c(Opportunity__c=opp.Id);
        insert request;
        
        delete opp;
    }
    @isTest 
    public static void activePOCsTrue(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-5;
        opp.Has_Active_POCs__c = False;
        insert opp;
        
        opp.Has_Active_POCs__c = True;
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(expectedDate, Opp1.POC_Start_Date__c);
        system.assertEquals(expectedDate, Opp1.POC_End_Date__c);
        system.assertEquals(5, Opp1.POC_Duration__c);
        system.assertEquals(5, Opp1.POC_Age__c);
    }
    
    //Test when Active POC's is unchecked
    @isTest
    public static void activePOCsFalse(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity1';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today();
        opp.POC_End_Date__c = Date.Today();
        opp.Has_Active_POCs__c = True;
        insert opp;
        
        opp.Has_Active_POCs__c = False;
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(expectedDate, Opp1.POC_Start_Date__c);
        system.assertEquals(expectedDate, Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(0, Opp1.POC_Age__c);
    }
    
    //Test when oppportunity is closed with active POC
    @isTest
    public static void OpportunityIsClosedWithActivePOC(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity2';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-10;
        opp.Has_Active_POCs__c = True;
        opp.Type = 'New Business';
        insert opp;
        
        opp.StageName = 'Closed Lost';
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        Date expectedDate = Date.newInstance(opp1.LastModifiedDate.year(),opp1.LastModifiedDate.month(),opp1.LastModifiedDate.day());
        system.assertEquals(Date.Today()-10, Opp1.POC_Start_Date__c);
        system.assertEquals(Date.Today(), Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(10, Opp1.POC_Age__c);
    }
    
    //Test when oppportunity is closed with no active POC's
    @isTest
    public static void OpportunityIsClosedWithoutActivePOC(){
        Opportunity opp = new Opportunity();
        opp.Name ='POC Age Opportunity3';
        opp.StageName = 'New';
        opp.CloseDate = Date.Today()+30;
        opp.POC_Start_Date__c = Date.Today()-10;
        opp.POC_End_Date__c = Date.Today()-10;
        opp.Has_Active_POCs__c = False;
        opp.Type = 'New Business';
        insert opp;
        
        opp.StageName = 'Closed Lost';
        update opp;
        Opportunity Opp1 =[Select Id, Name, POC_Start_Date__c, POC_End_date__c, POC_Age__c, POC_Duration__c, LastmodifiedDate from Opportunity where Id =:opp.Id];
        System.debug('opp1.POC_End_date__c'+opp1.POC_End_date__c);
        
        system.assertEquals(Date.Today()-10, Opp1.POC_Start_Date__c);
        system.assertEquals(Date.Today()-10, Opp1.POC_End_Date__c);
        system.assertEquals(Null, Opp1.POC_Duration__c);
        system.assertEquals(0, Opp1.POC_Age__c);
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.1- Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM1()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.6- Sales Engineer Team']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM2()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.0- Sales Management']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_RSM3()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='Discovery',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('RSM', output.Opportunity_Source__c);
            
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_ISR()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.3- Inside Sales']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='New',CloseDate=Date.today().addDays(90));
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('BDR-MQL', output.Opportunity_Source__c);
            
        }
    }
    @IsTest(SeeAllData=true)
    public static void TestPopulateOpportunitySource_PIO()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.3- Inside Sales']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        
        System.runAs(usr)
        {
            Test.startTest();
            Account acc= new Account(Name='acme') ;
            insert acc;
            
            Contact con= new Contact(LastName='Test',Email='abc@abc.com',AccountId=acc.Id);
            insert con;
            Opportunity opp= new Opportunity(Name='opptest',AccountId=acc.Id,Deal_Type__c='Replication',StageName='New',CloseDate=Date.today().addDays(90),Deal_Reg__c=true);
            insert opp;
            Test.stopTest();
            Opportunity output=[Select Id, Opportunity_Source__c from Opportunity where Id=:opp.Id];
            System.assertEquals('PIO', output.Opportunity_Source__c);
            
        }
    }
    
    @Istest(SeeAllData=true)
    public static void SetTechResponsibilityWhenNullAndNotNew()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        User rsmusr = new User(Alias = 'standt', Email='testUser@testrsmUser.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = prof.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testrsmUser.com',Default_TR__c=techUser.id);
        
        rsmusr.IsActive =true;
        insert rsmusr;
        
        System.runAs(rsmusr)
        { 
            Account acc= new Account(Name='Test Account');
            insert acc;
            
            Opportunity opp= new Opportunity(AccountId=acc.id,Name='Test Opp',StageName='Discovery',CloseDate=Date.today().addYears(1));
            insert opp;
            
            Opportunity outputOpp=[Select Id,Technical_Responsible__c from Opportunity where Id=:opp.Id];
            System.assertEquals(outputOpp.Technical_Responsible__c, techUser.id);
        }
        
    }
    @Istest(SeeAllData=true)
    public static void SetTechResponsibilityWhenNullAndNew()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        Profile profbdr = [SELECT Id FROM Profile WHERE Name='1.7- Renewal Specialist'];
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        User bdrusr = new User(Alias = 'standt', Email='testUser@testrsmUser.com', 
                               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = profbdr.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testbdrUser.com',Default_TR__c=techUser.id);
        
        bdrusr.IsActive =true;
        insert bdrusr;
        
        System.runAs(bdrusr)
        {
            Account acc= new Account(Name='Test Account');
            insert acc;
            
            Opportunity opp= new Opportunity(AccountId=acc.id,Name='Test Opp',StageName='New',CloseDate=Date.today().addYears(1));
            insert opp;
            
            Opportunity outputOpp=[Select Id,Technical_Responsible__c from Opportunity where Id=:opp.Id];
            System.assertEquals(outputOpp.Technical_Responsible__c, null);
        }
    }
    
    //opp updated with New TR who is not a Team Member
    @isTest
    public static void newTRAddedToTeam(){
        
        UserRole r = new UserRole(DeveloperName = 'Grade_4_Sys_Eng_NAM_Eastern', Name = 'Grade 4 Sys Eng NAM Eastern');
        insert r;
        
        User usr1= new User(LastName = 'Bell',FirstName = 'Rodney',Email = 'rbell@silver-peak.com',Username = 'rbell@silver-peak.com',
                            UserRoleId = r.id,TimeZoneSidKey  = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Alias = 'rbell',
                            ProfileId = [Select Id from Profile where name = '1.6- Sales Engineer Team'].Id);
        insert usr1;
        
        User usr2= new User(LastName = 'Lever',FirstName = 'Todd',Email ='tlever@silver-peak.com',Username = 'tlever@silver-peak.com',
                            UserRoleId = r.id,TimeZoneSidKey  = 'America/Los_Angeles',EmailEncodingKey = 'UTF-8',
                            LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',Alias = 'tlever',
                            ProfileId = [Select Id from Profile where name = '1.6- Sales Engineer Team'].Id);
        insert usr2;
        
        System.runAs(usr1){
            Account acc =  new Account(Name = 'Test Account',Type = 'Prospect');
            insert acc;
            
            Opportunity opp = new Opportunity(Name = 'Test Opportunity',AccountId = acc.Id,StageName = 'Qualified',CloseDate = Date.Today()+30,
                                              Type = 'Follow on Business',Deal_Type__c = 'WAN Op');
            insert opp;
            
            opp.Technical_Responsible__c = usr2.Id;
            update opp;
            
            List<OpportunityTeamMember> listOTM = [Select Id,OpportunityId,TeamMemberRole,UserId,OpportunityAccessLevel from OpportunityTeamMember where OpportunityId =:opp.Id
                                                   and UserId =:usr2.Id];
            system.assertEquals('Systems Engineer', listOTM[0].TeamMemberRole);
            system.assertEquals('Edit', listOTM[0].OpportunityAccessLevel);
        }
    }
}