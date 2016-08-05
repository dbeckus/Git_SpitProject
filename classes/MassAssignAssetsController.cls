/**
 * The controller of VF page "MassAssignAssets".
 */
public class MassAssignAssetsController
{
    private String accountId;
    private String contractId;
    
    public MassAssignAssetsController(ApexPages.StandardController controller)
    {
        Contract contract = (Contract)controller.getRecord();
        contractId = contract.Id;
        accountId = contract.AccountId;
        Succeeded = false;
    }
    
    public Boolean Succeeded { get; private set; } //return to the front-end, decide whether to redirect the page.
    public List<AssetInfo> Assets
    {
        get
        {
            if(Assets == null)
            {
                Assets = new List<AssetInfo>();
                for(Asset asset : [Select Id, Name, Product2Id, Product2.ProductCode, Product2.Name, Ship_Date__c, Status, Warranty_Start_Date__c, Warranty_End_Date__c, Evaluation_Start_Date__c, Evaluation_End_Date__c, Contract_Number__c from Asset where AccountId = :accountId and Status = 'Customer Owned' and (NOT Product2.Name like 'EC%') and Contract_Number__c = null order by Name])
                {
                    Assets.add(new AssetInfo(asset));
                }
            }
            return Assets;
        }
        set;
    }
    
    public PageReference assignAssets()
    {
        List<Asset> assetsToAssign = new List<Asset>();
        for(AssetInfo assetInfo : Assets)
        {
            if(assetInfo.IsSelected)
            {
                Asset asset = assetInfo.Asset;
                asset.Contract_Number__c = contractId;
                assetsToAssign.add(asset);
            }
        }
        if(!assets.isEmpty())
        {
            try
            {
                update assetsToAssign;
                Succeeded = true;
            }
            catch(Exception ex)
            {
                Succeeded = false;
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }
    
    public class AssetInfo
    {
        public AssetInfo(Asset asset)
        {
            this.IsSelected = false;
            this.Asset = asset;
        }
        
        public Boolean IsSelected { get; set; }
        public Asset Asset { get; private set; }
    }
    
    @isTest
    static void testMassAssignAssetsController()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contract contract = new Contract(AccountId = account.Id, SP_Contract_Number__c = 'acme', Status = 'Draft', Contract_Type__c = 'Gold', StartDate = Date.today(), EndDate = Date.today().addMonths(1), ContractTerm = 1);
        insert contract;
        Product2 product = new Product2(Name = 'acme');
        insert product;
        Asset asset = new Asset(Name = 'acme', SerialNumber = 'acme', AccountId = account.Id, Product2Id = product.Id, Status = 'Customer Owned');
        insert asset;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        MassAssignAssetsController controller = new MassAssignAssetsController(sc);
        system.assertEquals(1, controller.Assets.size());
        controller.Assets[0].IsSelected = true;
        controller.assignAssets();
        
        system.assertEquals(1, [select count() from Asset where Contract_Number__c = :contract.Id]);
    }
}