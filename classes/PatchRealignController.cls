/*
 * Controller of page PatchRealign
 */
public with sharing class PatchRealignController 
{
    private List<Patch__c> patches;
    
    public PatchRealignController() 
    {
        String patchIds = ApexPages.currentPage().getParameters().get('id');
        if(String.isNotBlank(patchIds))
        {
            patches = [select Id from Patch__c where Id in :patchIds.split(',')];
            RealignAll = true;
        }
        else
        {
            patches = new List<Patch__c>();
            RealignAll = true;
        }
        aborted = false;
        LeadCount = [select count() from Lead where Patch__c in :patches];
        OpportunityCount = [select count() from Opportunity where Patch__c in :patches];
        AccountCount = [select count() from Account where Patch__c in :patches];
        DateTime ruleEngineDeployDate = DateTime.newInstance(PatchRuleHelper.LastDeploymentDate);
        HasPendingUpdate = [select Id from Patch__c where Id in :patches and Timestamp__c>:ruleEngineDeployDate limit 1].size() > 0;
    }

    public Boolean InProgress 
    {
        get
        {
            return [select Id from AsyncApexJob where ApexClassID in (select Id from ApexClass where Name='PatchRealignJob') and Status in ('Holding', 'Queued', 'Preparing', 'Processing') limit 1].size() > 0;
        }
    }
    public Boolean RealignAll { get; set; }
    public Boolean HasPendingUpdate { get; set; }
    public Integer LeadCount { get; set; }
    public Integer OpportunityCount { get; set; }
    public Integer AccountCount { get; set; }
    public Boolean aborted { get; set; }
    
    public PageReference init()
    {
        Boolean autoStart = ApexPages.currentPage().getParameters().get('start') == '1';
        if(autoStart)
        {
            startProcess();
        }
        return null;
    }
    
    public PageReference startProcess()
    {
        if(!InProgress && !HasPendingUpdate)
        {
            List<Id> patchIds = new List<Id>();
            for(Patch__c patch : patches)
            {
                patchIds.add(patch.Id);
            }
            PatchRealignJob job = new PatchRealignJob(patchIds);
            if(RealignAll == true)
            {
                job.RealignAll = true;
            }
            Database.executeBatch(job, 10);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'The patch realignment job is submitted. You can close this window now. An email will be sent to you after the job is complete.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You must wait the pending process complete to start a new realignment job.'));
        }
        return null;
    }
    
    public PageReference abortProcess()
    {
        List<AsyncApexJob> jobs = [select Id from AsyncApexJob where ApexClassID in (select Id from ApexClass where Name='PatchRealignJob') and Status in ('Holding', 'Queued', 'Preparing', 'Processing') limit 1];
        if(jobs.size() > 0)
        {
            System.abortJob(jobs[0].Id);
            aborted = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Realignment process is aborted.'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No process found.'));
        }
        return null;
    }
}