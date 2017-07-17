public class CalculateCustomerDateonAccountBatch implements Schedulable, Database.Batchable<sObject>, Database.Stateful  {
public void execute(SchedulableContext context)
    {
        Database.executeBatch(new CalculateActiveAssetCountBatch(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        return Database.getQueryLocator([Select Id from Account where Trigger_Active_Asset_Count__c=true]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
       
        List<Account> lstAccount= (List<Account>)scope;
        List<Account> lstAccountToUpdate= new List<Account>();
        System.debug('execute');
        for(Account item: lstAccount)
        {
            //add logic here
            
            lstAccountToUpdate.add(new Account(Id=item.Id,Trigger_Active_Asset_Count__c=false));
        }
        if(lstAccountToUpdate.size()>0)
        {
            update lstAccountToUpdate;
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(!Test.isRunningTest())
        {
            CalculateCustomerDateonAccountBatch obj= new CalculateCustomerDateonAccountBatch();
            System.scheduleBatch(obj, 'Calculate Active Asset Count', 60, 1);
        }
        
    }
}