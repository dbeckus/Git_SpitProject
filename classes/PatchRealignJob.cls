/*
 * Realigns patches after patch criteria changed or member changed
 */
public class PatchRealignJob implements Database.Batchable<SObject>, Database.Stateful
{
    private enum PatchRealignJobType { Lead, Account, Opportunity }
    private List<Id> patchIds;
    private PatchRealignJobType JobType;
    public Boolean RealignAll { get; set; }
    
    public PatchRealignJob(List<Id> patchIds)
    {
        this(patchIds, PatchRealignJobType.Lead);
    }
    
    public PatchRealignJob(List<Id> patchIds, PatchRealignJobType jobType)
    {
        this.patchIds = patchIds;
        this.JobType = jobType;
    }
    
    public Database.QueryLocator start(Database.BatchableContext context)
    {
        if(JobType == null)
        {
            return null;
        }
        String soql = 'select Id from ' + JobType.name();
        
        List<String> criteria = new List<String>();
        if(patchIds != null && patchIds.size() > 0)
        {
            if(RealignAll = true)
            {
                criteria.add('Patch__c in :patchIds');
            }
            else
            {
                return null;
            }
        }
        if(JobType == PatchRealignJobType.Lead)
        {
            criteria.add('IsConverted=false');
        }
        else if(JobType == PatchRealignJobType.Opportunity)
        {
            criteria.add('Type != \'Marketplace\'');
            criteria.add('IsClosed=false');
        }
        if(criteria.size() > 0)
        {
            soql += ' where ';
            soql += String.join(criteria, ' and ');
            soql = soql.removeEnd(' and ');
        }
        return Database.getQueryLocator(soql);
    }
    
    public void execute(Database.BatchableContext context, List<sObject> scope)
    {
        List<Id> recordIds = new List<Id>();
        for(sObject obj : scope)
        {
            obj.put('Trigger_Assignment__c', true);
            if(obj instanceOf Opportunity)
            {
                obj.put('Bypassing_Validation__c', true);
            }
        }
        Database.SaveResult[] saveResults = Database.update(scope, false);
        SilverPeakUtils.logDatabaseError(scope, saveResults);
    }
    
    public void finish(Database.BatchableContext context)
    {
        if(JobType == PatchRealignJobType.Lead)
        {
            PatchRealignJob job = new PatchRealignJob(patchIds, PatchRealignJobType.Account);
            Database.executeBatch(job, 10);
        }
        else if(JobType == PatchRealignJobType.Account)
        {
            PatchRealignJob job = new PatchRealignJob(patchIds, PatchRealignJobType.Opportunity);
            Database.executeBatch(job, 10);
        }
        else
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(UserInfo.getUserId());
            email.setPlainTextBody(buildEmailBody());
            email.setSaveAsActivity(false);
            email.setSubject('Patch Realignment Finished');
            Messaging.sendEmail(new List<Messaging.Email> { email }, false);
        }
    }
    
    private String buildEmailBody()
    {
        if(patchIds == null || patchIds.size() == 0)
        {
            return 'Patch Realignment has finished. All patches have been realigned.';
        }
        else
        {
            String result = 'Patch Realignment has finished. Following patches have been realigned: \r\n';
            for(Patch__c patch :  [select Id, Name, Patch_Name__c from Patch__c where Id in :patcHIds])
            {
                result += patch.Patch_Name__c + '\r\n';
            }
            return result;
        }
    }
}