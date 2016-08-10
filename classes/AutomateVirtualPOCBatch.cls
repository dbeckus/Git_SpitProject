public class AutomateVirtualPOCBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    Set<string>	successPOCIds;
    Set<string> errorPOCIds;
    Set<string> unityPocsIds;
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new AutomateVirtualPOCBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        List<Date> lstDates= new List<Date>();
        lstDates.add(Date.today());
        lstDates.add(Date.today().addDays(-1));
        return Database.getQueryLocator([Select Id,Name,POC_Contact__c from Request__c where Requested_Delivery_Date__c in:lstDates and  POC_Type__c='WAN Op' and Status__c='Approved to Ship' and IsAllVirtual__c=1 and VirtualProduct1__c != null]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        successPOCIds = new Set<string>();
        errorPOCIds = new Set<string>();
        unityPocsIds= new Set<string>();
        List<Id> licenseIds= new List<Id>();
        Boolean isCustomerUser=false;
        Boolean isPartnerUser =false;
        if(scope.size()>0)
        {
            for(sObject item :scope)
            {
                
                Request__c pocRequest= (Request__c)item;
                System.Savepoint sp= Database.setSavepoint();
                try
                {
                    isCustomerUser = AutomatePOCShipmentHelper.ValidateCustomerPortalLogic(pocRequest.POC_Contact__c);
                    
                    if(!isCustomerUser)
                    {
                        isPartnerUser = AutomatePOCShipmentHelper.ValidatePartnerPortalLogic(pocRequest.POC_Contact__c);
                        
                    }
                    if( isCustomerUser || isPartnerUser)
                    {
                        successPOCIds.add(string.valueof(pocRequest.Name));
                        licenseIds.addAll(AutomatePOCShipmentHelper.FulfillPocs(pocRequest.Id));
                        if(AutomatePOCShipmentHelper.IsUnityCloudIntelligenceInPoc(pocRequest.Id))
                        {
                            unityPocsIds.add(pocRequest.Name);
                        }
                        
                    }
                    else
                    {
                        errorPocIds.add(string.valueof(pocRequest.Name));
                    }
                }
                catch(Exception ex)
                {
                    Database.rollback(sp);
                    SilverPeakUtils.logException(ex);
                    errorPocIds.add(string.valueof(pocRequest.Name));
                    if(successPOCIds.contains(pocRequest.Name))
                    {
                        successPOCIds.remove(pocRequest.Name);
                    }
                    continue;
                }
                
                
            }
            
            if(successPOCIds.size()>0)
            { AutomatePOCShipmentHelper.SendBatchSuccessToShipmentTeam(successPOCIds);}
            if(unityPocsIds.size()>0)
            { AutomatePOCShipmentHelper.SendUnityCloudNotifications(unityPocsIds);}
            if(errorPocIds.size()>0)
            { AutomatePOCShipmentHelper.SendErrorNotificationEmailToShipmentTeam(errorPocIds);}
            
            try
            {
                //encryp 
                List<Id> virtualLicenseIds = new List<Id>();
                for(License__c virtualLicense : [select Id from License__c where Id in :licenseIds and AssetId__r.Product2.Model__c!='GX-V' And AssetId__r.Product2.Product_Category__c !='GMS'])
                {
                    virtualLicenseIds.add(virtualLicense.Id);
                }
                if(virtualLicenseIds.size() > 0)
                {
                    AutomatePOCShipmentHelper.encryptLicenses(virtualLicenseIds);
                }
                
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex); 
            }
            
            
            
            
        }
        
    }
    
    public void finish(Database.BatchableContext context)
    {
        AutomateGMSLicenseJob obj = new AutomateGMSLicenseJob();
        Database.executeBatch(obj);
    }
}