/*
 * Updates the SendT60Email, SendT90Email and SendExpirationEmail on Account when hitting the end date.
 */
global class ContractExpirationNotification implements Schedulable, Database.Batchable<sObject>, Database.Stateful
{
    private Integer t0Contracts;
    private Integer t60Contracts;
    private Integer t90Contracts;
    
    global void execute(SchedulableContext sc)
    {
        ContractExpirationNotification notification = new ContractExpirationNotification();
        Database.executeBatch(notification, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        t0Contracts = 0;
        t60Contracts = 0;
        t90Contracts = 0;
        return Database.getQueryLocator([select Id, (select Id, EndDate from Contracts where Status='Activated' and EndDate in (:Date.today().addDays(-1), :Date.today(), :Date.today().addDays(60), :Date.today().addDays(90)) and Include_For_Notice__c=1) from Account where Id in (select AccountId from Contract where Status='Activated' and EndDate in (:Date.today().addDays(-1), :Date.today(), :Date.today().addDays(60), :Date.today().addDays(90)) and Include_For_Notice__c=1)]);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> objs)
    {
        List<Contract> contracts = new List<Contract>();
        if(objs.size() > 0)
        {
            Boolean sending = false;
            Account acc = (Account)objs[0];
            System.debug(acc);
            for(Contract ct : acc.Contracts)
            {
                if(ct.EndDate == Date.today().addDays(-1))
                {
                    ct.Status = 'Expired';
                    contracts.add(ct);
                    sending = true;
                }
                else if(ct.EndDate == Date.today())
                {
                    if(hasActiveAssets(ct.Id))
                    {
                        ct.Trigger_Notice__c = 'T0';
                        contracts.add(ct);
                        acc.SendExpirationEmail__c = true;
                        sending = true;
                        t0Contracts++;
                    }
                }
                else if(ct.EndDate == Date.today().addDays(60))
                {
                    ct.Trigger_Notice__c = 'T60';
                    contracts.add(ct);
                    acc.SendExpirationEmail__c = true;
                    sending = true;
                    t60Contracts++;
                }
                else if(ct.EndDate == Date.today().addDays(90))
                {
                    ct.Trigger_Notice__c = 'T90';
                    contracts.add(ct);
                    acc.SendExpirationEmail__c = true;
                    sending = true;
                    t90Contracts++;
                }
            }
            if(sending)
            {
                try
                {
                    update contracts;
                    update acc;
                }
                catch(Exception ex)
                {
                    String message = 'Error occured when sending the contract expiration email on account: ' + acc.Id + '. The error message is: \r\n' + ex.getMessage();
                    sendEmail('Error occured when sending the contract expiration email', message);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        String message = 'T0 contracts updated: ' + t0Contracts + '\r\nT60 contracts updated: ' + t60Contracts + '\r\nT90 contracts updated: ' +t90Contracts;
        sendEmail('Contract Expiration Notification Finished', message);
    }
    
    private void sendEmail(String subject, String body)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new String[] { 'notifications@silver-peak.com'});
        mail.setUseSignature(false);
        if(!Test.isRunningTest())
        {
        	Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }
    
    private Boolean hasActiveAssets(Id contractId)
    {
        for(Asset asset : [select Id, Status from Asset where Contract_Number__c=:contractId])
        {
            if(asset.Status == 'Conditional PO' || asset.Status == 'Customer Owned' || asset.Status == 'Cold Spare' || asset.Status.startsWith('Pending Return'))
            {
                return true;
            }
        }
        return false;
    }
}