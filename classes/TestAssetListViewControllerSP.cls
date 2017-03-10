@isTest
public class TestAssetListViewControllerSP
{
    @isTest
    public static void testAssetListView()
    {
        Asset asset1 = createTestData();
        //Asset asset2 = createTestData();
        AssetListViewController_SP controller = new AssetListViewController_SP();
        system.assertEquals(1, controller.AssetsInCurrentPage.size());
        system.assert(!controller.HasNext);
        controller.SearchAsset = '001BBC039649';
        controller.searchAssets();
        system.assert(!controller.HasNext);
        controller.SearchAsset = '';
        controller.searchAssets();

        ApexPages.currentPage().getParameters().put('fieldName', 'Contract_Number__r.ContractNumber;Contract_Status__c');
        controller.sortTable();
        controller.AssetsInCurrentPage.get(0).AssetRecord.Customer_Notes__c = 'test inline edit';
        controller.saveAsset();
        system.assert([select id from Asset where Customer_Notes__c != null] != null);
        
        controller.sendListToCurrentUser();
        controller.ServiceProvider = true;
        controller.ListView = 'NXToVX_Subscriptions';
        controller.sendListToCurrentUser();
    }

    @isTest
    public static void testCSVUpload()
    {
        Asset asset1 = createTestData();
        Asset asset2 = createTestData();
        String body = 'Id,Product Model,Serial Number,Ship Date,License Key,End Customer,Reference,Deployment Date,Customer Notes\r';
               body += asset1.Id + ',TEST MODEL1,001BBC039645,5/11/2015,eydK-je/+-rtfz-A/eF-kY2j-qBMQ-dH+N-qaZX-woVG-yGH1-Gotm-2vTQ-bSx5-Jg1v-asSd-AbZw-6hI1-Xr+S-K21q-nme+-wLVp-Ng==,ZYX Company,"",1/1/2015,test 2\r';
               body += asset2.Id + ',TEST MODEL1,001BBC039649,5/11/2015,f+nl-jdrH-DJGs-Gu3m-BfY1-t/U1-0Thx-47Rc-rqIM-RCc8-zN3c-9vQq-DQOU-Pk4G-t8PV-d36t-3Nx4-0Aq3-H8RI-9mQj-B6Hk-pQ==,ZYX Company,Test PO,"",test test2\r';
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        email.subject = 'test';
        env.fromAddress = 'user@acme.com';
        inAtt.body = blob.valueOf(body);
        inAtt.fileName = 'Assets.csv';
        inAtt.mimeTypeSubType = 'application/csv';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt }; 

        UpdateAssetsFromCSVFile emailServiceObj = new UpdateAssetsFromCSVFile();
        emailServiceObj.handleInboundEmail(email, env);
    }

    private static Asset createTestData()
    {
        Account account = new Account(Name = 'acme');
        insert account;
		Account spAccount = new Account(Name = 'Silver Peak Systems');
        insert spAccount;
        Product2 product = new Product2();
        product.Name = 'EC-BASE-SP';
        product.ProductCode = 'acme';
        product.Product_Type__c='EC-SP-Perpetual';
        insert product;

        Asset asset = new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = account.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Owned';
        asset.Quantity = 1;
        insert asset;
        return asset;
    }
    
}