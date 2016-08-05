public class CloudPortalGetUpdatedAccountsJob implements  Schedulable, Database.Batchable<sObject>,Database.Stateful,Database.AllowsCallouts  {
    
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CloudPortalGetUpdatedAccountsJob(), 10);
    }
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id from Account where Cloud_Portal_Account_Key__c!=null or Cloud_Portal_Account_Name__c!=null ]);
    }
    public void execute(Database.BatchableContext context, List<sObject> scope)
    { 
        
        List<Account> lstAccountsToUpdate= new List<Account>();
        DateTime lastSyncDate= Datetime.newInstance(2016, 6, 3);// remember to push go live date
        ApexClass currentJobRef=[Select Id from ApexClass where Name='CloudPortalGetUpdatedAccountsJob' LIMIT 1];
        List<AsyncApexJob> lstJob= [Select Id,CreatedDate from AsyncApexJob where ApexClassId=:currentJobRef.Id and Status='Completed' and NumberOfErrors =0 order by CreatedDate desc];
        if(lstJob!=null && lstJob.size()>0)
        {
            lastSyncDate=lstJob[0].CreatedDate;
        }
        System.debug(lastSyncDate);
        long dateToUTC=(lastSyncDate.getTime())/1000;
        
        string token=CloudPortalAccountHelper.GetTokenFromPortal();
        CloudPortalGetUpdatedAccountsApi obj = new CloudPortalGetUpdatedAccountsApi(dateToUTC);
        obj.token=token;
        obj.execute();
        CloudPortalAccountList lstAccounts= obj.CPAccountList;
        if(lstAccounts!=null && lstAccounts.accounts!=null && lstAccounts.accounts.size()>0)
        {
            
            for(CloudPortalAccountList.CPAccount acc:lstAccounts.accounts)
            {
                if(acc.salesforceId!=null)
                {
                    lstAccountsToUpdate.add(new Account(Id=acc.salesforceId,Cloud_Portal_Account_Name__c=acc.name));
                }
                
            }
            
        }
        try
        {
            System.debug('lstAccountsToUpdate.size() '+lstAccountsToUpdate.size());
            
            if(lstAccountsToUpdate.size()>0)
            {
                update lstAccountsToUpdate;
            }
        }
        catch(Exception ex)
        {
            SilverPeakUtils.logException(ex);
        }
    }
    
    
    
    public void finish(Database.BatchableContext context)
    {
        
        
    }
}