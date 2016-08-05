public class AutomateGMSLicenseJob implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new AutomateGMSLicenseJob(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
         List<Date> lstDates= new List<Date>();
        lstDates.add(Date.today());
        lstDates.add(Date.today().addDays(-1));
        return Database.getQueryLocator([Select Id,POCRequest__c from Asset where (Product2.Model__c ='GX-V'or Product2.Product_Category__c ='GMS' )and Key_Generated__c=false and POCRequest__c in (Select Id from Request__c where Requested_Delivery_Date__c in:lstDates and  POC_Type__c='WAN Op' and Status__c='Shipped')]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        System.debug('scope.size'+scope.size());
        List<Id> lstLicenses= new List<Id>();
        Set<Id> lstPocIds= new Set<Id>();
        if(scope.size()>0)
        {
            for(sObject item :scope)
            {
                Asset assetItem= (Asset)item;
                lstPocIds.add(assetItem.POCRequest__c);
                List<License__c> lstTempLicenses= [Select Id from License__c where AssetId__c=:assetItem.Id];
                if(lstTempLicenses!=null && lstTempLicenses.size()>0)
                {
                    for(License__c licItem: lstTempLicenses)
                    {
                        lstLicenses.add(licItem.Id);
                    }
                    
                }
            }
            System.debug('LstLicenses'+lstLicenses.size());
            List<Request__c> pocRequestList =[Select Name from Request__c where Id in: lstPocIds];
            Set<string> lstPocName= new Set<String>();
            if(pocRequestList!=null && pocRequestList.size()>0)
            {
                for(Request__c pocItem :pocRequestList)
                {
                    lstPocName.add(pocItem.Name);
                }
                
            }
            try
            {
                AutomatePOCShipmentHelper.encryptLicenses(lstLicenses);
            }
            catch(Exception ex)
            {
                SilverPeakUtils.logException(ex); 
            }
            
            AutomatePOCShipmentHelper.SendGMSLicenseStatusToShipmentTeam(lstPocName);
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {	
             AutomateVirtualPOCBatch obj= new AutomateVirtualPOCBatch();
        	 System.scheduleBatch(obj, 'Automate POC Shipments', 15);
        }
       
        
    }
}