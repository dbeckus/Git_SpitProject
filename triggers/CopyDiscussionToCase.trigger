/*
 * copies the discussion body and user email to its parent case
 * and sets the UpdatedBy field to 'Internal' to trigger a workflow rule to send emails out.
 */
trigger CopyDiscussionToCase on Internal_Discussion__c (after insert) 
{
    List<Case> cases = new List<Case>();
    for(Internal_Discussion__c discussion : trigger.new)
    {
        Case parentCase = new Case(Id=discussion.Case__c, LastUpdateNote__c=discussion.Body__c, LastUpdateUser__c=discussion.From__c, UpdatedBy__c='Internal');
        cases.add(parentCase);
    }
    update cases;
}