/*
 * Sends outbound emails after Email_Sending checkbox is checked on POC
 */
trigger SendPOCSummaryEmail on POC_Summary__c (after update) 
{
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    Set<Id> pocIds = new Set<Id>();
    for(POC_Summary__c poc : Trigger.new)
    {
        POC_Summary__c oldPoc = Trigger.oldMap.get(poc.Id);
        if(poc.Email_Sending__c == true && oldPoc.Email_Sending__c != true)
        {
            pocIds.add(poc.Id);
        }
    }
    if(pocIds.size() > 0)
    {
        SendPocSummaryControler.sendBatchEmails(pocIds);
    }
}