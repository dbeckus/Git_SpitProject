/**
 * A Trigger handler of MDF Request.
 * Auto submits a MDF request created from partner portal for approval.
 * 
 *
 * @author  Matt Yuan
 * @created 8/5/2015
 * @version 1.0
 * @since   34.0
 *
 * @changelog
 * 8/5/2015 Matt Yuan - Created.
 */

public class MDFRequestTriggerHandlerForAutoSubmit extends TriggerHandler
{
    public override void afterInsert()
    {
        autoSubmitMDFRequest();
    }

    private void autoSubmitMDFRequest()
    {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(sObject sObj : Trigger.new)
        {
            MDF_Request__c mdfReq = (MDF_Request__c)sObj;
            if(mdfReq.Is_Portal_Request__c)
            {
                Approval.ProcessSubmitRequest submitReq = new Approval.ProcessSubmitRequest();
                submitReq.setComments('Submitting request for approval.');
                submitReq.setObjectId(mdfReq.Id);
                //submitReq.setSubmitterId(UserInfo.getUserId());
                //submitReq.setProcessDefinitionNameOrId('New_MDF_Request');
                //submitReq.setSkipEntryCriteria(true);
                requests.add(submitReq);
            }
        }
        try
        {
            List<Approval.ProcessResult> results = Approval.process(requests, false);
        }
        catch(Exception ex)
        {
            System.debug('An exception was thrown: ' + ex);
        }
    }
}