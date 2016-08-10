trigger UpdateAccountIsPartner  on Account (after update) {
    private List<Id> acctIds = new List<Id>();
    for(Account acct : Trigger.new)
    {
        if(acct.Partner_Application_Status__c == 'Approved' && Trigger.oldMap.get(acct.Id).Partner_Application_Status__c != 'Approved')
        {
            acctIds.add(acct.Id);
        }
    }
    if(acctIds.size() > 0)
    {
        List<Account> acctList = [select Id, IsPartner from Account where Id in: acctIds]; 
        for(Account acct : acctList)
        {
            acct.IsPartner = true;
        }
        try
        {
            update acctList; 
        }catch(Exception ex)
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toaddress = New String[] {UserInfo.getUserEmail()};
            email.setPlainTextBody('UpdateAccountIsPartner Error:' + ex.getMessage() );
            email.setToAddresses(toaddress);
            Messaging.sendEmail(New Messaging.SingleEmailMessage[] {email});
        }
    }
}