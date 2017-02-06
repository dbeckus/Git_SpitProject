/*
* Includes some method for POC Request Automation
*/
public class PocRequestAutomationHelper
{
    public static final String EvalRmaRecordTypeId = '012500000005H0o';
    public static final String EvalRMAItemRecordTypeId = '012500000005H0y';
    
    public static void removePocLinkOnAsset(Set<Id> pocIds)
    {
        List<Request__c> requests = [select Id, Status__c, (select POCRequest__c from Assets__r) from Request__c where Id in :pocIds];
        List<Asset> assets = new List<Asset>();
        for(Request__c request : requests)
        {
            for(Asset asset : request.Assets__r)
            {
                asset.POCRequest__c = null;
                assets.add(asset);
            }
        }
        try
        {
            Database.update(assets, false);
        }
        catch(DmlException ex)
        {
            throw new PocRequestAutomationException(ex.getMessage());
        }
    }
    
    public static void removePocLinkOnAssetAndSetStatus(Set<Id> assetIds)
    {
        List<Asset> assets = new List<Asset>();
        for(Id assetId : assetIds)
        {
            assets.add(new Asset(Id=assetId, POCRequest__c=null, Status='Silver Peak Inventory'));
        }
        try
        {
            Database.update(assets, false);
        }
        catch(DmlException ex)
        {
            throw new PocRequestAutomationException(ex.getMessage());
        }
    }
    
    public static void CreateEvalRMA(Set<Id> pocIds)
    {
        List<RMA__c> rmas = new List<RMA__c>();
        List<Asset> assets = new List<Asset>();
        List<Asset> partVirtualAssets = new List<Asset>();
        List<Asset> changeAssets = new List<Asset>();
        List<Asset> trashyAssets = new List<Asset>();
        Set<Id> AssetIds = new Set<Id>();
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        
        Map<Id, List<RMA_Item__c>> rmaItemMap = new Map<Id, List<RMA_Item__c>>(); //key: poc id, value: rma line items
        List<Request__c> requests = [select Id, Name, Status__c, IsAllVirtual__c, POC_Contact__c, Evaluation_Product_1__c, Ship_To_Location_1__c, Opportunity__r.AccountId, Opportunity__r.Type, Opportunity__r.StageName, Opportunity__r.Amount, (select Id, Product2Id, Product2.Product_Family_Clean__c, Hosted_GMS__c, Account.Name from Assets__r), (select Id from RMAs__r where RecordTypeId=:EvalRmaRecordTypeId) from Request__c where Id in :pocIds];
        
        Id accountId;
        List<Account> accounts = [select Id, Name from Account where Name = 'EMAIL SUPPORT CONTACTS'];
        if(accounts != null && accounts.size() > 0)
        {
            accountId = accounts[0].Id;
        }
        else
        {
            throw new PocRequestAutomationException('Email support contacts not found.');
        }
        
        for(Request__c request : requests)
        {
            if(request.RMAs__r.size() == 0)
            {
                RMA__c rma = new RMA__c(Account__c=request.Opportunity__r.AccountId, RecordTypeId=EvalRmaRecordTypeId, Request__c=request.Id, Status__c='Initiated', Type__c='Eval Return', Contact_Loc_1__c=request.POC_Contact__c, Product__c=request.Evaluation_Product_1__c, Address1__c=request.Ship_To_Location_1__c);
                List<RMA_Item__c> items = new List<RMA_Item__c>();
                for(Asset asset : request.Assets__r)
                {
                    if(asset.Product2.Product_Family_Clean__c == 'Virtual')
                    { 
                        if(asset.Hosted_GMS__c)
                        {
                            asset.AccountId = accountId;
                            changeAssets.add(asset);
                        }
                        else
                        {
                            partVirtualAssets.add(asset);
                        }
                    }
                    else
                    {
                        items.add(new RMA_Item__c(Asset__c=asset.Id, Product2__c=asset.Product2Id, RecordTypeId=EvalRMAItemRecordTypeId, Type__c='Return - Refurbish and Stock', Status__c='Not Dispatched'));
                        assets.add(asset);
                    }
                }
                trashyAssets.addAll(partVirtualAssets);
                partVirtualAssets.clear();
                if(items.size() > 0)
                {
                    rmas.add(rma);
                }
                rmaItemMap.put(request.Id, items);
            }
            if(request.Opportunity__r.Type == 'Marketplace' && request.Opportunity__r.Amount == 0)
            {
                //request.Opportunity__r.StageName = 'Closed Dead';
                opportunityIds.add(request.Opportunity__c);
            }    
        }
        SavePoint sp = Database.setSavePoint();
        opportunities = [select Id, StageName from Opportunity where Id in :opportunityIds];
        for(Opportunity opportunity : opportunities)
        {
            opportunity.StageName = 'Closed Dead';
            opportunity.Bypassing_Validation__c = true;
        }
        try
        {
            update opportunities;
            upsert rmas;
            for(Asset asset : trashyAssets)
            {
                AssetIds.add(asset.Id);
            }
            deleteAssets(AssetIds);
            update changeAssets;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new PocRequestAutomationException(ex.getMessage());
        }
        List<RMA_Item__c> rmaItems = new List<RMA_Item__c>();
        for(RMA__c rma : rmas)
        {
            List<RMA_Item__c> items = rmaItemMap.get(rma.Request__c);
            if(items != null)
            {
                for(RMA_Item__c item : items)
                {
                    item.RMA__c = rma.Id;
                    rmaItems.add(item);
                }
            }
        }
        try
        {
            upsert rmaItems;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new PocRequestAutomationException(ex.getMessage());
        }
        for(Asset asset : assets)
        {
            asset.Status = 'Pending Return – Eval';
            asset.Evaluation_End_Date__c = Date.today();
        }
        try
        {
            update assets;
        }
        catch(DmlException ex)
        {
            Database.rollback(sp);
            throw new PocRequestAutomationException(ex.getMessage());
        }
    }
    
    @Future
    public static void deleteAssets(Set<Id> assetsId)
    {
        Database.delete([select Id from asset where Id in: assetsId], false);
    }
    
    public static void closeRMAs(Set<Id> pocIds)
    {
        List<RMA__c> rmas = new List<RMA__c>();
        List<Request__c> requests = [select Id, (select Id from RMAs__r) from Request__c where Id in :pocIds];
        System.debug(requests);
        for(Request__c request : requests)
        {
            for(RMA__c rma : request.RMAs__r)
            {
                rma.Status__c = 'Closed';
                rmas.add(rma);
            }
        }
        try
        {
            update rmas;
        }
        catch(DmlException ex)
        {
            throw new PocRequestAutomationException(ex.getMessage());
        }
    }
    
    public static void updateAssetDate(Set<Id> pocIds)
    {
        List<Request__c> requests = [select Id, Target_End_Date__c, (select POCRequest__c from Assets__r) from Request__c where Id in :pocIds];
        List<Asset> assets = new List<Asset>();
        for(Request__c request : requests)
        {
            for(Asset asset : request.Assets__r)
            {
                asset.Evaluation_End_Date__c = request.Target_End_Date__c;
                assets.add(asset);
            }
        }
        try
        {
            update assets;
        }
        catch(DmlException ex)
        {
            throw new PocRequestAutomationException(ex.getMessage());
        }
    }
    
    public class PocRequestAutomationException extends Exception
    {
    }
    
    // Test the class when poc is not all virtual.
    @IsTest
    static void testPocRequestAutomationHelper()
    {
        
        Account silverPeakAccount = new Account(Name='Silver Peak Systems',EC_Customer_Date__c=Date.today());
        insert silverPeakAccount;
        Account supportAccount = new Account(Name='EMAIL SUPPORT CONTACTS',EC_Customer_Date__c=Date.today());
        insert supportAccount;
        Account account = new Account(Name='acme',EC_Customer_Date__c=Date.today());
        insert account;
        AccountTeamMember teamMember=new AccountTeamMember(AccountId=account.Id,UserId=UserInfo.getUserId(),TeamMemberRole='Account Manager');
        insert teamMember;
        
        User u = [select Id from User where Id != :UserInfo.getUserId() and IsActive = true limit 1];
        Opportunity opp = new Opportunity(AccountId=account.Id, Name='test', StageName='Open', CloseDate=Date.today(), ForecastCategoryName='Pipeline', OwnerId=u.Id);
        opp.Product_Type__c='Both';
        insert opp;
                Test.startTest();

        Request__c request = new Request__c(Opportunity__c=opp.Id, Evaluation_Product_1__c='NX 1700');
        insert request;
        
        Product2 product = new Product2(Name = 'test', IsActive = true, Family = 'Virtual Image');
        insert product;
        Asset asset = new Asset(Name='test', AccountId=account.Id, PocRequest__c=request.Id,Silver_Peak_Account__c=account.id);
        insert asset;
        Asset asset2 = new Asset(Name='test', AccountId=account.Id, PocRequest__c=request.Id,Silver_Peak_Account__c=account.id);
        insert asset2;
        
        
        Asset asset3 = new Asset(Name='test', AccountId=account.Id, PocRequest__c=request.Id, Product2Id = product.Id,Silver_Peak_Account__c=account.id);
        insert asset3;
                Test.stopTest();

        /*
        request.Status__c = 'Pending Return';
        update request;
        
request = [select Id, IsAllVirtual__c, (select Id, Status__c from RMAs__r) from Request__c where Id=:request.Id limit 1];
System.assertEquals(1, request.RMAs__r.size());



List<RMA_Item__c> items = [select Id, Status__c, Asset__c from RMA_Item__c where RMA__r.Request__c=:request.Id];
System.assertEquals(2, items.size());

items[0].Status__c = 'Received';
update items[0];

asset = [select Id, Status, PocRequest__c from Asset where Id=:items[0].Asset__c limit 1];
System.assertEquals('Silver Peak Inventory', asset.Status);
System.assertEquals(null, asset.PocRequest__c);

request.Status__c = 'Closed - Returned';
update request;


request = [select Id, (select Id, Status__c from RMAs__r) from Request__c where Id=:request.Id limit 1];
System.assertEquals('Closed', request.RMAs__r[0].Status__c);

request.Target_End_Date__c = Date.today().addDays(1);
update request;
*/
        
    } 
}