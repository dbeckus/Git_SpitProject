/*
 * Sends notification to customers when asset is expiring/expired on T0, T30, T60, T90
 */
public class DeleteDealRegRejectedLeads implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
   
    private Integer deletedRecordCount = 0;
    public void execute(SchedulableContext context)
    {
        Database.executeBatch(new DeleteDealRegRejectedLeads(), 10);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
  
        return Database.getQueryLocator([select Id from Lead where LeadSource='Deal Registration' and Status='Rejected' and Lead_Rejected_Date__c =:Date.today().addDays(-31)]);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        if(scope.size()>0)
        {
            deletedRecordCount = scope.size();
            delete scope;
        }
    }
    
    public void finish(Database.BatchableContext context)
    {
        insert new ErrorLog__c(Subject__c='Deal Registrations Rejected Leads Deleted', Message__c='Deleted ' + deletedRecordCount + ' rejected Leads.');
    }
    
   
}