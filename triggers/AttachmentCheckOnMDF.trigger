/*
 * Makes sure MDF event is filled before Portal user uploads an attachment to MDF
 */
trigger AttachmentCheckOnMDF on Attachment (before insert) 
{
    /*
    List <Id> mdfIds = new List <Id>();
    List <Attachment> attachments = new List<Attachment>();
    List <MDF_Request__c> mdfs = new List <MDF_Request__c>();
    for(Attachment att : Trigger.new)
    {
        if(att.ParentId.getSObjectType() == Schema.MDF_Request__c.SObjectType && UserInfo.getUserType() == 'PowerPartner')
        {
            mdfIds.add(att.ParentId);
            attachments.add(att);
        }
    }
    if(mdfIds.size() > 0)
    {
         mdfs = [select Id, Total_Attendees__c, Total_Leads_Generated__c, Total_Qualified_Leads__c, Result_Detail__c, Activity_Complete__c, Estimated_Pipeline_Value__c, Requested_Reimbursement_Amount__c from MDF_Request__c where Id in: mdfIds];
    }
    if(mdfs.size() > 0)
    {
        for(Attachment att : attachments)
        {
            for(MDF_Request__c mdf : mdfs)
            {
                if(mdf.Id == att.ParentId)
                {
                    if(!hasEventFilled(mdf))
                    {
                        att.addError('Event Details are Required Before you Upload Your Documents.');
                    }
                    break;
                }
            }
        }   
    }
    public Boolean hasEventFilled(MDF_Request__c mdf)
    {
        return (mdf.Total_Attendees__c != null && mdf.Total_Leads_Generated__c != null && mdf.Total_Qualified_Leads__c != null && mdf.Result_Detail__c != null && mdf.Activity_Complete__c == true && mdf.Estimated_Pipeline_Value__c != null && mdf.Requested_Reimbursement_Amount__c != null); 
    }
    */
}