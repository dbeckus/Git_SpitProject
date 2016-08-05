/*
 * Updates MDF status to approved or defnied after PR status is changed
 */
trigger UpdateMdfStatusFromPR on Purchasing_Request__c (after update) 
{
    Set<Id> approvedPRs = new Set<Id>();
    Set<Id> rejectedPRs = new Set<Id>();
    Set<Id> pendingPRs = new Set<Id>();
    
    for(Purchasing_Request__c pr : Trigger.new)
    {
        Purchasing_Request__c oldPR = Trigger.oldMap.get(pr.Id);
        if(pr.Approval_Status__c == 'Final Approval' && oldPR.Approval_Status__c != 'Final Approval')
        {
            approvedPRs.add(pr.Id);
        }
        if(pr.Approval_Status__c == 'Rejected' && oldPR.Approval_Status__c != 'Rejected')
        {
            rejectedPRs.add(pr.Id);
        }
        if(pr.Amount_Increase__c == true && oldPR.Amount_Increase__c != true)
        {
            pendingPRs.add(pr.Id);
        }
    }
    List<MDF_Request__c> updatingMdfs = new List<MDF_Request__c>();
    List<MDF_Request__c> mdfs = [select Id, Purchasing_Request__c from MDF_Request__c where Purchasing_Request__c in :approvedPRs or Purchasing_Request__c in :rejectedPRs or Purchasing_Request__c in :pendingPRs];
    for(MDF_Request__c mdf : mdfs)
    {
        if(approvedPRs.contains(mdf.Purchasing_Request__c))
        {
            mdf.Approval_Status__c='Approved';
        }
        if(rejectedPRs.contains(mdf.Purchasing_Request__c))
        {
            mdf.Approval_Status_Hidden__c='Denied';
        }
        if(pendingPRs.contains(mdf.Purchasing_Request__c))
        {
            mdf.Approval_Status__c='Pending';
        }
        updatingMdfs.add(mdf);
    }
    if(updatingMdfs.size() > 0)
    {
        try
        {
            update updatingMdfs;
        }
        catch(Exception ex)
        {
            Trigger.new[0].addError('Failed to update status. The error message is: ' + ex.getMessage());
        }
    }
}