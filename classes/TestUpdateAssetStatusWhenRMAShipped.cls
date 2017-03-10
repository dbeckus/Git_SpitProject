@IsTest
public class TestUpdateAssetStatusWhenRMAShipped {
    @IsTest
    public static void Test()
    {
       	Profile profile = [select Id from Profile where Name='12-SP Portal' limit 1];
        Account acc = new Account(Name='acme');
        insert acc;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Contact contact = new Contact(LastName='test user', AccountId=acc.Id);
        insert contact;
        User destinationUser = new User(FirstName='acme', LastName='acme', Email='test@test.com', Username='test@test.com', ProfileId=profile.Id, ContactId=contact.Id, Alias='test', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        insert destinationUser;
        Contract contract = new Contract(AccountId=acc.Id, Status='Draft', Contract_Type__c='Gold', StartDate=Date.today(), EndDate=Date.today().addYears(1), SP_Contract_Number__c='123');
        insert contract;
        contract.Status = 'Activated';
        update contract;
        Product2 prod = new Product2(Name='NX-9700', ProductCode='NX-9700', Model__c='NX-9700',Family='Product');
        insert prod;
        Product2 prod2 = new Product2(Name='VX-9000', ProductCode='VX-9000', Model__c='VX-9000', Family='Virtual Image');
        insert prod2;
        Asset nxAsset = new Asset(Name='acme', SerialNumber='acme', Status='Customer Owned', Product2Id=prod.Id, AccountId=acc.Id, ContactId=destinationUser.ContactId, Contract_Number__c=contract.Id);
        insert nxAsset;
        CmaProductMapping__c mapping = new CmaProductMapping__c(Name='NX9700 to VX9000', NX__c='NX-9700', VX__c='VX-9000');
        insert mapping;
        
        Test.startTest();
        System.runAs(destinationUser)
        {
            PickAssetForNewCmaController pickAssetCtrl = new PickAssetForNewCmaController();
            pickAssetCtrl.searchKey = 'acme';
            PageReference result = pickAssetCtrl.searchRecord();
            System.assert(result != null);
            pickAssetCtrl.cancel();
            pickAssetCtrl.previous();
            pickAssetCtrl.next();
            pickAssetCtrl.goToCma();
            
            PageReference assetPage = new PageReference('/apex/ConvertRmaToCma?id=' + nxAsset.Id);
            Test.setCurrentPage(assetPage);
            ConvertRmaToCmaController convertCtrl = new ConvertRmaToCmaController();
            PageReference convertResult = convertCtrl.convert();
            System.assert(convertResult != null);
            System.assert(convertctrl.CmaId != null);

            PageReference convertResultPage = new PageReference('/apex/CmaConvertConfirm?id=' + convertctrl.CmaId);
            Test.setCurrentPage(convertResultPage);
            CmaConvertConfirmController confirmController = new CmaConvertConfirmController();
            System.assertNotEquals('Error', confirmController.VxAssetId);
            
            CmaConvertComponentController componentController = new CmaConvertComponentController();
            componentController.CmaRecordId = convertctrl.CmaId;
            System.assertEquals(1, componentController.Cmas.size());
            System.assertEquals('NX-9700', componentController.Cmas[0].NxModel);
            System.assertEquals('VX-9000', componentController.Cmas[0].VxModel);
            
            RMA__c objRMA= new RMA__c();
            objRMA.Id=convertctrl.CmaId;
            objRMA.Status__c='Shipped';
            objRMA.Type__c='Convert to Virtual';
            update objRMA;
            Asset assetRec=[Select status from Asset where Id=:nxAsset.Id];
            System.assertEquals('Pending Return – Conversion', assetRec.Status);
            
        }
        Test.stopTest();
        
        
    }

}