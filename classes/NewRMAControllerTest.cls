@isTest
public class NewRMAControllerTest
{
    @isTest
    static void testConcateAddress()
    {
        String result = NewRMAController.concateAddress('st1', 'st2', 'city', 'state', 'zip', 'country', 'fn', 'la', 'phone');
        System.assertEquals('st1\r\nst2\r\ncity\r\nzip state\r\ncountry\r\nfn la phone', result);
        
        result = NewRMAController.concateAddress('st1', null, 'city', 'state', 'zip', 'country', 'fn', 'la', 'phone');
        System.assertEquals('st1\r\ncity\r\nzip state\r\ncountry\r\nfn la phone', result);
        
        result = NewRMAController.concateAddress('st1', 'st2', 'city', 'state', 'zip', 'country', null, '', null);
        System.assertEquals('st1\r\nst2\r\ncity\r\nzip state\r\ncountry', result);
        
        result = NewRMAController.concateAddress('st1', 'st2', 'city', 'state', 'zip', 'country');
        System.assertEquals('st1\r\nst2\r\ncity, state zip\r\ncountry', result);
    }
    
    @isTest
    static void testSystemProduct()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
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
    }
    
    @isTest
    static void testSystemProduct_RMA_ExpiredAsset()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
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
        Product2 pro = new Product2(Name='acme',Family='Product', ProductCode='acme', Model__c='acme', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        asset.Warranty_End_Date__c=Date.today().addDays(-1);
        update asset;
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        //caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        System.debug('caseInfo.Id'+ caseInfo.Id);
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        NewRMAController controller = new NewRMAController();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        
        // Check that the error message you are expecting is in pageMessages
        Boolean messageFound = false;
        
        for(ApexPages.Message message : pageMessages) {
            System.debug(message.getDetail());
            if(message.getDetail() == 'You cannot open RMA for the expired warranty/contract asset.') {
                   messageFound = true;        
               }
        }
        
        System.assert(messageFound);
    }
    @isTest
    static void testSystemProduct_AllowRMA_ExpiredAsset()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
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
        Product2 pro = new Product2(Name='acme',Family='Product', ProductCode='acme', Model__c='acme', RMA_Primary_Replacement__c=pros[0].Id);
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        asset.Warranty_End_Date__c=Date.today().addDays(-1);
        update asset;
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        //caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        caseInfo.Allow_RMA__c=true;
        update caseInfo;
        System.debug('caseInfo.Id'+ caseInfo.Id);
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        NewRMAController controller = new NewRMAController();
        
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertEquals(0, pageMessages.size());
    }
    @isTest
    static void testHDD()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
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
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id, Part_Number__c='acme');
        insert asset;
        
        ReplaceablePartNumberMatrix__c matrix = new ReplaceablePartNumberMatrix__c(Name='1', Product_PN__c=pro.ProductCode, Asset_PN__c=asset.Part_Number__c, HDD_PN__c=pros[0].ProductCode, SSD_PN__c=pros[1].ProductCode, PS_PN__c=pros[2].ProductCode);
        insert matrix;
        ValidateSlot__c slot1 = new ValidateSlot__c(Name='1', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='HDD', Start__c=1, End__c=9);
        ValidateSlot__c slot2 = new ValidateSlot__c(Name='2', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='SSD', Start__c=1, End__c=9);
        insert new List<ValidateSlot__c> {slot1, slot2};
        Test.startTest();
        
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Advance Replace'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
                                                        new NewRMAController.ProductInfo('System'),
                                                        new NewRMAController.ProductInfo('HDD'),
                                                        new NewRMAController.ProductInfo('SSD'),
                                                        new NewRMAController.ProductInfo('Power Supply') };
        proInfos[0].Selected = false;
        proInfos[1].Selected = true;
        proInfos[1].Slot = 5;
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
        controller.getRMAItem().ShipToStateOrProvince__c = 'CA';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        
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
        
        Test.stopTest();
    }
    
    @isTest
    static void testSSD()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
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
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id, Part_Number__c='acme');
        insert asset;
        
        ReplaceablePartNumberMatrix__c matrix = new ReplaceablePartNumberMatrix__c(Name='1', Product_PN__c=pro.ProductCode, Asset_PN__c=asset.Part_Number__c, HDD_PN__c=pros[0].ProductCode, SSD_PN__c=pros[1].ProductCode, PS_PN__c=pros[2].ProductCode);
        insert matrix;
        ValidateSlot__c slot1 = new ValidateSlot__c(Name='1', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='HDD', Start__c=1, End__c=9);
        ValidateSlot__c slot2 = new ValidateSlot__c(Name='2', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='SSD', Start__c=1, End__c=9);
        insert new List<ValidateSlot__c> {slot1, slot2};
        Test.startTest();
        
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Advance Replace'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
                                                        new NewRMAController.ProductInfo('System'),
                                                        new NewRMAController.ProductInfo('HDD'),
                                                        new NewRMAController.ProductInfo('SSD'),
                                                        new NewRMAController.ProductInfo('Power Supply') };
        proInfos[0].Selected = false;
        proInfos[1].Selected = false;
        proInfos[2].Selected = true;
        proInfos[2].Slot = 5;
        proInfos[3].Selected = false;
                                         
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'CA';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        
        Test.stopTest();
    }
    
    @isTest
    static void testNVME()
    {
        Account spAcc= new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        con.MailingStreet='address1 \r\n address2';
        insert con;
        List<Product2> pros = new List<Product2> { 
                                                new Product2(Name='acme1', ProductCode='acme1'),
                                                new Product2(Name='acme2', ProductCode='acme2'),
                                                new Product2(Name='acme3', ProductCode='acme3'),
                                                new Product2(Name='acme4', ProductCode='acme4',IsActive=true)};
        insert pros;
        Product2 pro = new Product2(Name='acme', ProductCode='acme', Model__c='acme');
        insert pro;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=pro.Id, AccountId=acc.Id, ContactId=con.Id, Part_Number__c='acme');
        insert asset;
        
        ReplaceablePartNumberMatrix__c matrix = new ReplaceablePartNumberMatrix__c(Name='1', Product_PN__c=pro.ProductCode, Asset_PN__c=asset.Part_Number__c, HDD_PN__c=pros[0].ProductCode, SSD_PN__c=pros[1].ProductCode, PS_PN__c=pros[2].ProductCode,NVME_PN__c=pros[3].ProductCode);
        insert matrix;
        ValidateSlot__c slot1 = new ValidateSlot__c(Name='1', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='HDD', Start__c=1, End__c=9);
        ValidateSlot__c slot2 = new ValidateSlot__c(Name='2', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='SSD', Start__c=1, End__c=9);
        ValidateSlot__c slot3 = new ValidateSlot__c(Name='3', Model__c=pro.Model__c, AssetPN__c=asset.Part_Number__c, Type__c='NVME', Start__c=6, End__c=9);
        insert new List<ValidateSlot__c> {slot1, slot2,slot3};
        Test.startTest();
        
        NewRMAController controller = new NewRMAController();
        Case caseInfo = new Case(Subject='acme', Status='On Hold', Origin='Email', AssetId=asset.Id, AccountId=acc.Id, ContactId=con.Id);
        caseInfo.Type = controller.getRecordTypeId('System Change Request', 'Case');
        insert caseInfo;
        
        PageReference page = new PageReference('/newrma?id=' + caseInfo.Id);
        Test.setCurrentPageReference(page);
        
        controller = new NewRMAController();
        controller.getRMA().Type__c = 'Advance Replace'; 
        controller.getRMAItem().Delivery_Class__c = 'Next Business Day';
        List<NewRMAController.ProductInfo> proInfos = new List<NewRMAController.ProductInfo> {
                                                        new NewRMAController.ProductInfo('System'),
                                                        new NewRMAController.ProductInfo('HDD'),
                                                        new NewRMAController.ProductInfo('SSD'),
                                                        new NewRMAController.ProductInfo('Power Supply'),
                                                        new NewRMAController.ProductInfo('NVME')};
        proInfos[0].Selected = false;
        proInfos[1].Selected = false;
        proInfos[2].Selected = false;
        proInfos[4].Selected = true;
        proInfos[4].Slot = 7;
        proInfos[3].Selected = false;
                                         
        controller.Products = proInfos;
        controller.getContact().LastName = 'acme';
        controller.getRMAItem().Contact_Email__c = 'test@test.com';
        controller.getRMAItem().Contact_Phone__c = '123456789';
        controller.getRMAItem().ShipToCountry__c = 'USA';
        controller.getRMAItem().ShipToAddress__c = 'acme';
        controller.getRMAItem().ShipToAddressAdditional__c = 'acme';
        controller.getRMAItem().ShipToCity__c = 'acme';
        controller.getRMAItem().ShipToStateOrProvince__c = 'CA';
        controller.getRMAItem().ShipToPostalCode__c = '100000';
        
        controller.getDeliveryClasses();
        controller.previous();
        controller.next();
        controller.getRMATypes();
        controller.save();
        controller.cancel();
        
        Test.stopTest();
    }
    
    @isTest
    static void testParseAddress()
    {
        NewRMAController controller = new NewRMAController();
        String[] addressInfo = NewRMAController.parseAddress('street1\r\nstreet2\r\ncity, state zip\r\ncountry');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('street2', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('country', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('street1\r\ncity, state zip\r\ncountry');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('country', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('street1\r\nstreet2\r\ncity, state zip');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('street2', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('USA', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('street1\r\ncity, state\r\ncountry');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('', addressInfo[4]);
        System.assertEquals('country', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('street1\r\ncity, state zip');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('USA', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('city, state zip\r\ncountry');
        System.assertEquals('', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('country', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('city, state zip');
        System.assertEquals('', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('city', addressInfo[2]);
        System.assertEquals('state', addressInfo[3]);
        System.assertEquals('zip', addressInfo[4]);
        System.assertEquals('USA', addressInfo[5]);
        
        addressInfo = NewRMAController.parseAddress('street1');
        System.assertEquals('street1', addressInfo[0]);
        System.assertEquals('', addressInfo[1]);
        System.assertEquals('', addressInfo[2]);
        System.assertEquals('', addressInfo[3]);
        System.assertEquals('', addressInfo[4]);
        System.assertEquals('USA', addressInfo[5]);
    }
}