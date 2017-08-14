@IsTest
public class TestTriggerActiveAssetCountFromContract {
	@IsTest
    public static void TriggerAssetCountContractStatusChange()
    {
        Account acc = new Account(name='acme',Type='Prospect');
        insert acc;
        Account spAcc = new Account(name='Silver Peak Systems',Type='Prospect');
        insert spAcc;
		Product2 product = new Product2();
        product.Name = 'VX-2000';
        product.ProductCode = 'VX-2000';
        product.Model__c = 'VX-2000';
        product.Product_Type__c = 'NX/VX';
        product.Family='Virtual Image';
        insert product;
        
        Asset asset= new Asset();
        asset.Name = '001BBC039649_t';
        asset.SerialNumber = '001BBC039649_t';
        asset.AccountId = acc.Id;
        asset.Product2Id = product.Id;
        asset.Status = 'Customer Subscription';
        asset.Ship_Date__c = Date.today();
        asset.Quantity = 1;
       
        insert asset;
        Contract con= new Contract();
        con.AccountId=acc.id;
        con.Contract_Type__c='Gold';
        insert con;
        asset.Contract_Number__c=con.Id;
        update con;
        asset.Is_Customer_Asset__c=true;
        update asset;
        con.Status='Activated';
        update con;
        Asset testAsset= [Select Is_Customer_Asset__c from Asset where Id=:asset.id];
        System.assert(testAsset.Is_Customer_Asset__c==true);
        
    }
}