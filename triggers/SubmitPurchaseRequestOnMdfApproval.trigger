/*
 * After MDF request is updated to approved, the approval process on PR is fired off.
 */
trigger SubmitPurchaseRequestOnMdfApproval on MDF_Request__c (after update) 
{
    //Do not fire on batch update
    if(Trigger.new.size() == 1)
    {
        for(MDF_Request__c mdf : Trigger.new)
        {
            MDF_Request__c oldMDF = Trigger.oldMap.get(mdf.Id);
            if(isApproval(mdf.Approval_Status_Hidden__c) && !isApproval(oldMDF.Approval_Status_Hidden__c))
            {
                List<Purchasing_Request__c> pr = [select Id, First_Approver__c, (select Id from Purchase_Request_Lines__r limit 1) from Purchasing_Request__c where Id=:mdf.Purchasing_Request__c limit 1];
                if(pr.size() > 0 && pr[0].First_Approver__c == null)
                {
                    mdf.addError('You cannot approve this MDF before the budget owner is set up on the related Purchase Request.');
                    return;
                }
                if(pr.size() > 0 && pr[0].Purchase_Request_Lines__r.isEmpty())
                {
                    mdf.addError('You cannot approve this MDF before any PR line is entered on the related Purchase Request.');
                    return;
                }
            }
            if(mdf.Approval_Status_Hidden__c == 'Approved' && oldMDF.Approval_Status_Hidden__c != 'Approved')
            {
                submitPR(mdf);
            }
        }
    }
    
    private Boolean isApproval(String text)
    {
        return String.isNotBlank(text) && (text.toLowerCase().contains('approved') || text.toLowerCase().contains('approval'));
    }
    
    private void submitPR(MDF_Request__c mdf)
    {
        if(mdf.Purchasing_Request__c != null)
        {
            try
            {
                List<ProcessInstanceStep> mdfApprovalHistory = [select Id, ActorId from ProcessInstanceStep where ProcessInstance.TargetObjectId=:mdf.Id and StepStatus='Approved' order by CreatedDate limit 1];
                List<ProcessInstance> prApproval = [select Id from ProcessInstance where TargetObjectId=:mdf.Purchasing_Request__c and Status in ('Started', 'Pending', 'Approved') limit 1];
                if((mdfApprovalHistory.size() > 0 && prApproval.size() == 0) || Test.isRunningTest())
                {
                    Approval.ProcessSubmitRequest process = new Approval.ProcessSubmitRequest();
                    process.setComments('Submit upon MDF approval.');
                    process.setObjectId(mdf.Purchasing_Request__c);
                    //just for testing
                    String submiter = Test.isRunningTest() ? UserInfo.getUserId() : mdfApprovalHistory[0].ActorId;
                    process.setSubmitterId(submiter);
                    Approval.ProcessResult result = Approval.process(process);
                    if(result.getInstanceStatus() != 'Pending')
                    {
                        mdf.addError('Failed to submit. The status is ' + result.getInstanceStatus());
                        SilverPeakUtils.logException('Failed to submit Purchase Request. [Id=' + mdf.Purchasing_Request__c + ']');
                    }
                }
            }
            catch(Exception ex)
            {
                mdf.addError(ex.getMessage());
                SilverPeakUtils.logException(ex);
            }
        }
        else
        {
            SilverPeakUtils.logException('MDF is approved, but it does not have a related PR to submit. [Id=' + mdf.Id + ']');
        }
    }
}