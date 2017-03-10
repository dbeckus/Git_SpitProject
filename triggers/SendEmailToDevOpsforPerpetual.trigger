trigger SendEmailToDevOpsforPerpetual on Account (after update) {
    
    for(Account acc:Trigger.New)
    {
        Account oldAcc=Trigger.OldMap.get(acc.Id);
        if(acc.Service_Provider_Account_Type__c=='Perpetual-Orchestrator SP' || acc.Service_Provider_Account_Type__c=='Metered-Orchestrator SP')
        {
            
            if(oldAcc.Cloud_Portal_Account_Key__c==null && acc.Cloud_Portal_Account_Key__c!=null && oldAcc.Cloud_Portal_Account_Name__c==null && acc.Cloud_Portal_Account_Name__c!=null)
            {
                
                String templateString='Please find the additional details to create orchestrator \n\n CloudPortal Account Name : {0} \n CloudPortal Account Key : {1}\n Service Provider Domain : {2}\n Service Provider Location: {4}\n\n Service Provider Admin User: {3}\n \n';
                String[] arguments = new String[] {acc.Cloud_Portal_Account_Name__c,acc.Cloud_Portal_Account_Key__c,acc.Service_Provider_Domain__c,acc.Service_Provider_Admin_User__c,acc.Service_Provider_Location__c};
                    string bodyText= string.format(templateString,arguments);
                //Send Email to DevOps Team
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {'prane@silver-peak.com','notifications@silver-peak.com'};
                    message.subject = 'Please create orchestrator MTO instance for '+ acc.Cloud_Portal_Account_Name__c;
                message.plainTextBody = bodyText;
                
                Messaging.SingleEmailMessage[] messages = 
                    new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: '
                                 + results[0].errors[0].message);
                }
                
                
            }
        }
    }
    
}