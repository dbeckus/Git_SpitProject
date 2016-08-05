@IsTest
public class NoDispatchForECOneYearProductTest {
    
    /*
 	 @IsTest 
    public static void NoDispatchForECOneYearProduct_OperationsProfile()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
            new Product2(Name='EC-M',Family='Product', ProductCode='EC-M') };
                insert pros;
        Product2 pro = new Product2(Name='EC-M', Family='Product', ProductCode='acme', Model__c='acme', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00,Status='Customer Owned', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Return for Repair'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
            new NewRMAController.ProductInfo('System'),
                new NewRMAController.ProductInfo('HDD'),
                new NewRMAController.ProductInfo('SSD'),
                new NewRMAController.ProductInfo('Power Supply') };
                    proInfos[0].Selected = true;
        proInfos[1].Selected = false;
        proInfos[2].Selected = false;
        proInfos[3].Selected = false;
        
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'acme';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        controller.isEntitledForRMA(asset.Id);
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        controller.createCase();
        NewRMAController.loadContactFromCase(null);
        
        con.Email = 'test@test.com';
        update con;
        PageReference page2 = new PageReference('/newrma?id=' + acc.Id);
        Test.setCurrentPageReference(page2);
        controller.getRMA().Type__c  = 'Advance Replace';
        controller.saveAndNew();
        RMA__c rma = new RMA__c();
        RMA_Item__c rmaItem = new RMA_Item__c();
        controller.setRMA(rma);
        controller.setRMAItem(rmaItem);
        controller.setContact(con);
        NewRMAController.parseAssetAddress('acme');
        controller.save();
       
        
        Profile p = [SELECT Id FROM Profile WHERE Name='9-Operations Manager']; 
        User u = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
    
        u.IsActive =true;
        System.runAs(u) {
            // The following code runs as user 'u' 
           
            RMA__c updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
            updatedRMA.Status__c ='Dispatched';
            update updatedRMA;
           
            
        }
        
        
        
    }
    
     @IsTest 
    public static void NoDispatchForECOneYearProduct_NonOperationsProfile()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
            new Product2(Name='EC-M', Family='Product',ProductCode='EC-M') };
                insert pros;
        Product2 pro = new Product2(Name='EC-M', Family='Product', ProductCode='EC-M', Model__c='EC-M', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00,Status='Customer Owned', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Return for Repair'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
            new NewRMAController.ProductInfo('System'),
                new NewRMAController.ProductInfo('HDD'),
                new NewRMAController.ProductInfo('SSD'),
                new NewRMAController.ProductInfo('Power Supply') };
                    proInfos[0].Selected = true;
        proInfos[1].Selected = false;
        proInfos[2].Selected = false;
        proInfos[3].Selected = false;
        
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'acme';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        controller.isEntitledForRMA(asset.Id);
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        controller.createCase();
        NewRMAController.loadContactFromCase(null);
        
        con.Email = 'test@test.com';
        update con;
        PageReference page2 = new PageReference('/newrma?id=' + acc.Id);
        Test.setCurrentPageReference(page2);
        controller.getRMA().Type__c  = 'Advance Replace';
        controller.saveAndNew();
        RMA__c rma = new RMA__c();
        RMA_Item__c rmaItem = new RMA_Item__c();
        controller.setRMA(rma);
        controller.setRMAItem(rmaItem);
        controller.setContact(con);
        NewRMAController.parseAssetAddress('acme');
        controller.save();
       
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUserSA@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUserSA@uniquetest.com');
        	u.IsActive =true;
        	
        	System.runAs(u) {

            RMA__c updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
        	
            updatedRMA.Status__c ='Dispatched';
            update updatedRMA;
            updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
            System.assertEquals('Initated', updatedRMA.Status__c);
        }
    }
    
     @IsTest 
    public static void DispatchForECOneYearProductEvalStatus_NonOperationsProfile()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
            new Product2(Name='EC-M', Family='Product',ProductCode='EC-M') };
                insert pros;
        Product2 pro = new Product2(Name='EC-M', Family='Product', ProductCode='EC-M', Model__c='EC-M', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00,Status='Customer Evaluation', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Return for Repair'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
            new NewRMAController.ProductInfo('System'),
                new NewRMAController.ProductInfo('HDD'),
                new NewRMAController.ProductInfo('SSD'),
                new NewRMAController.ProductInfo('Power Supply') };
                    proInfos[0].Selected = true;
        proInfos[1].Selected = false;
        proInfos[2].Selected = false;
        proInfos[3].Selected = false;
        
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'acme';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        controller.isEntitledForRMA(asset.Id);
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        controller.createCase();
        NewRMAController.loadContactFromCase(null);
        
        con.Email = 'test@test.com';
        update con;
        PageReference page2 = new PageReference('/newrma?id=' + acc.Id);
        Test.setCurrentPageReference(page2);
        controller.getRMA().Type__c  = 'Advance Replace';
        controller.saveAndNew();
        RMA__c rma = new RMA__c();
        RMA_Item__c rmaItem = new RMA_Item__c();
        controller.setRMA(rma);
        controller.setRMAItem(rmaItem);
        controller.setContact(con);
        NewRMAController.parseAssetAddress('acme');
        controller.save();
       
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='testUserSA@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUserSA@uniquetest.com');
        	u.IsActive =true;
        	
        	System.runAs(u) {

            RMA__c updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
        	
            updatedRMA.Status__c ='Dispatched';
            update updatedRMA;
            updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
            System.assertEquals('Dispatched', updatedRMA.Status__c);
        }
    }
    
     @IsTest 
    public static void DispatchForNonECProducts()
    {
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
            new Product2(Name='VX-500', ProductCode='VX-500') };
                insert pros;
        Product2 pro = new Product2(Name='VX-500', ProductCode='VX-500', Model__c='VX-500', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00,Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Return for Repair'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
            new NewRMAController.ProductInfo('System'),
                new NewRMAController.ProductInfo('HDD'),
                new NewRMAController.ProductInfo('SSD'),
                new NewRMAController.ProductInfo('Power Supply') };
                    proInfos[0].Selected = true;
        proInfos[1].Selected = false;
        proInfos[2].Selected = false;
        proInfos[3].Selected = false;
        
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'acme';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        controller.isEntitledForRMA(asset.Id);
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        controller.createCase();
        NewRMAController.loadContactFromCase(null);
        
        con.Email = 'test@test.com';
        update con;
        PageReference page2 = new PageReference('/newrma?id=' + acc.Id);
        Test.setCurrentPageReference(page2);
        controller.getRMA().Type__c  = 'Advance Replace';
        controller.saveAndNew();
        RMA__c rma = new RMA__c();
        RMA_Item__c rmaItem = new RMA_Item__c();
        controller.setRMA(rma);
        controller.setRMAItem(rmaItem);
        controller.setContact(con);
        NewRMAController.parseAssetAddress('acme');
        controller.save();
       
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
       
             
        User u = new User(Alias = 'standt', Email='testUserSA@uniquetest.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='testUserSA@uniquetest.com');
        	u.IsActive =true;
        	
        	System.runAs(u) {
          
                
            
            RMA__c updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
            updatedRMA.Status__c ='Dispatched';
         
            update updatedRMA;
          
            updatedRMA = [Select Id, Status__c from RMA__c where Id= :controller.getRMA().id];
            System.assertEquals('Dispatched', updatedRMA.Status__c);
        }
    }*/
}