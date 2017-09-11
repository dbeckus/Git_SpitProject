/*
 * If a case comment is created with public status or created with private status but updated to public, then update the "UpdatedBy" field of the case, to trigger a workflow and send emails.
 */
trigger SendEmailUponPublicCaseComment on CaseComment (after update, after insert) 
{
    Set<Id> caseIds = new Set<Id>();
    Set<Id> setSPCase= new Set<Id>();
    for(CaseComment comment : Trigger.new)
    {
        if(Trigger.isUpdate)
        {
            CaseComment oldComment = Trigger.oldMap.get(comment.Id);
            if(comment.IsPublished == true && oldComment.IsPublished == false)
            {
                  caseIds.add(comment.ParentId);     
            }
        }
        else if(Trigger.isInsert)
        {
            //Ignore the comment if current user is a context user of email services, as the comment is from an email.
            List<EmailServicesAddress> emailService = [select Id from EmailServicesAddress where Function.IsActive=true and RunAsUserId=:UserInfo.getUserId()];
            List<User> lstUser= [Select Id,Email from User where Id=:comment.LastModifiedById];
            if(emailService.size() == 0)
            {
                if(comment.IsPublished == true)
                {
                    caseIds.add(comment.ParentId);
                    if(lstUser!=null && lstUser.size()>0)
                    {
                        if(lstUser[0].Email.contains('@silver-peak.com'))
                        {
                            setSPCase.add(comment.ParentId);
                        }
                    }
                   
                }
            }
        }
    }
    
    if(caseIds.size() > 0)
    {
        List<Case> cases = new List<Case>();
        
        for(Id caseId : caseIds)
        {
            if(setSPCase.contains(caseId))
                cases.add(new Case(Id=caseId, UpdatedBy__c='Owner'));
            else
                  cases.add(new Case(Id=caseId, UpdatedBy__c='Customer'));
            
        }
        update cases;
    }
}