public class PORenewECAssetsBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new PORenewECAssetsBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        
        return Database.getQueryLocator([Select Shipment_Id__r.PurchaseOrder__c from Shipped_Line__c where Asset__c in(Select Id from Asset where Product2.Product_Type__c ='EDGECONNECT' and Renewal_Start_Date__c<=:Date.today() and  Renewal_Date__c!=null) ]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        Set<Id> lstPO= new Set<Id>();
        for(sObject s:scope)
        {
            Shipped_Line__c item=(Shipped_Line__c)s;
            lstPO.add(item.Shipment_Id__r.PurchaseOrder__c);
        }
        if(lstPO.size()>0)
        {
            for(Id poId:lstPO)
            {
                Purchase_Order__c purchaseOrder= [Select Id,Opportunity__r.AccountId,Email_Contact__c from Purchase_Order__c where Id=:poId];
                List<Asset> lstAssets=[Select Id, Name,License_End_Date__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Is_Selected_For_Renewal__c,Renewal_Date__c,Renewal_Nodes__c ,License_Expiration__c,Renewal_Start_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c from Asset where Product2.Product_Type__c ='EDGECONNECT' and Renewal_Start_Date__c<=:Date.today() and Renewal_Date__c!=null and Id in (Select Asset__c from Shipped_Line__c where Shipment_Id__r.PurchaseOrder__c =:poId) ];
                if(lstAssets!=null && lstAssets.size()>0)
                {
                    SavePoint sp= Database.setSavepoint();
                    try
                    {
                        RenewalAssetsHelper.CheckUnCheckAssets(lstAssets, true);
                        RenewalAssetsHelper.SendEmailsForPurchaseOrder_Reduction(purchaseOrder);
                        RenewalAssetsHelper.RenewEdgeConnectNodes(lstAssets);
                        RenewalAssetsHelper.ClearRenewalDate(lstAssets);
                        RenewalAssetsHelper.CheckUnCheckAssets(lstAssets, false);
                    }
                    catch(Exception ex)
                    {
                        Database.Rollback(sp);
                        SilverPEakUtils.logException(ex);
                        continue;
                    }
                    
                }
            }
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        
    }
}