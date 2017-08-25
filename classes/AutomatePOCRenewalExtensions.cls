public class AutomatePOCRenewalExtensions implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    public List<License__c> gmsLicenseIds;
    public AutomatePOCRenewalExtensions() 
    {
        gmsLicenseIds= new List<License__c>();  
    }
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new AutomatePOCRenewalExtensions(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id,Opportunity__c, Opportunity__r.AccountId,POC_Type__c, POC_Contact__c, GMS_Needed__c, EvaluationProductHypervisor__c, Evaluation_Product_1__c, Evaluation_Product_2__c, Quantity_Location_1__c, Quantity_Location_2__c, Status__c, Actual_Ship_Date__c, Target_End_Date__c, VirtualProduct1__c, VirtualProduct2__c, VirtualProduct3__c, VirtualProduct4__c, VirtualProduct5__c, VirtualQuantity1__c, VirtualQuantity2__c, VirtualQuantity3__c, VirtualQuantity4__c, VirtualQuantity5__c  from Request__c where Id in (Select POCRequest__c from Asset where POCREquest__c!=null and Is_Asset_Eligible_For_POC_Renewal_Ext__c=true )]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Request__c> lstReq=(List<Request__c>)scope;
        List<License__c> licenseIds= new List<License__c>();
        List<License__c> virlicenseIds= new List<License__c>();
        List<Id> virIds= new List<Id>();
        for(Request__c pocReq: lstReq)
        {
            SavePoint sp= Database.setSavepoint();
            try
            {
                List<Asset> lstAssetsForRenewal=[Select Id, Name,License_End_Date__c,Renewal_Nodes__c,Product2.Name,Status,Ship_Date__c, Product2.Product_Category__c,Product2.NumberOfLicenses__c,Hosted_GMS__c,GMS_Nodes__c,Product2.Model__c,Renewal_Date__c,Licenses_Nodes__c,Bandwidth_Nodes__c from Asset where  POCRequest__c=:pocReq.Id and Product2.Family='Virtual Image' and Status='Customer Evaluation'];
                List<Asset> assets= new List<Asset>();
                List<Asset> ecOrchAsset= new List<Asset>();
                
                for(Asset item: lstAssetsForRenewal)
                {
                    item.Renewal_Date__c=pocReq.Target_End_Date__c;
                    if(item.Product2.Name.startsWith('EC-BASE')||item.Product2.Name.startsWith('EC-PLUS'))
                    {
                        item.Renewal_Nodes__c=item.Licenses_Nodes__c;
                    }
                    if(item.Product2.Name.startsWith('EC-BOOST'))
                    {
                        item.Renewal_Nodes__c= item.Bandwidth_Nodes__c;
                    }
                    if(item.Product2.Name=='EC-ORCH' || item.Product2.Model__c=='GX-V' || item.Product2.Product_Category__c == 'GMS')
                    {
                        ecOrchAsset.add(item);
                    }
                    else
                    {
                        assets.add(item);
                    }
                }
                if(pocReq.POC_Type__c=='WAN Op')
                {
                    virlicenseIds.addAll(RenewalAssetsHelper.CreateNewLicensesForBatch(assets));
                }
                else if(pocReq.POC_Type__c=='EdgeConnect' || pocReq.POC_Type__c=='Service Provider' || pocReq.POC_Type__c=='EC-SP-Term'||pocReq.POC_Type__c=='EC-SP-Term +Orch-SP'|| pocReq.POC_Type__c=='Perpetual'|| pocReq.POC_Type__c=='EC-SP-Metered'||pocReq.POC_Type__c=='Perpetual-Orchestrator SP'||pocReq.POC_Type__c=='EC-SP-Metered +Orch-SP')
                {
                    RenewalAssetsHelper.RenewEdgeConnectLicense(assets);
                }
                if(ecOrchAsset.size()>0)
                {
                    gmsLicenseIds.addAll(RenewalAssetsHelper.CreateNewLicensesForBatch(ecOrchAsset));
                }
                RenewalAssetsHelper.SendEmailsForPOCRequest(pocReq);
                RenewalAssetsHelper.ClearRenewalDate(assets);
                RenewalAssetsHelper.ClearRenewalDate(ecOrchAsset);
            }
            catch(Exception ex)
            {
                Database.Rollback(sp);
                SilverPEakUtils.logException(ex);
            }   
            
        }
        if(virlicenseIds.size()>0)
        {
            for(License__c item:virlicenseIds)
            {
                virIds.add(item.id);
            }
            if(!Test.isRunningTest())
            {
                AutomatePOCShipmentHelper.encryptLicenses(virIds);
            }
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            List<Id> gmsIds= new List<Id>();
            if(gmsLicenseIds.size()>0)
            {
                for(License__c item:gmsLicenseIds)
                {
                    gmsIds.add(item.id);
                }
                AutomatePOCShipmentHelper.encryptLicenses(gmsIds);
            }
            
            AutomatePOCRenewalExtensions obj= new AutomatePOCRenewalExtensions();
            System.scheduleBatch(obj, 'Automate POC Renewals', 60, 1);
        }
    }
    
}