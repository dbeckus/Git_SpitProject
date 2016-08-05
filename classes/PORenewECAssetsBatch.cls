public class PORenewECAssetsBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new PORenewECAssetsBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
       
        return Database.getQueryLocator([Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,Renewal_Nodes__c ,License_Expiration__c,Renewal_Start_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c from Asset where Renewal_Start_Date__c=:Date.today().addDays(-1) and Renewal_Date__c!=null ]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Asset> lstAsset= (List<Asset>)scope;
        System.debug('lstAsset'+lstAsset);
        if(lstAsset!=null && lstAsset.size()>0)
        {
            if(RenewalAssetsHelper.RenewEdgeConnectLicense(lstAsset))
            {
                RenewalAssetsHelper.ClearRenewalDate(lstAsset);
            }
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        
    }
}