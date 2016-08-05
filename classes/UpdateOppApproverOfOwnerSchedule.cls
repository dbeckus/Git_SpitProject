/**
* Updates opportunity QuoteApproverOfOwner__c field that new value equal Quote_Approver__c field on opportunity owner 
*/
global class UpdateOppApproverOfOwnerSchedule implements Database.Batchable<sObject>, Schedulable
{
    private Map<String, String> userMap; //key: user id, value: user.Quote_Approver
    private String query = 'Select Id, OwnerId, QuoteApproverOfOwner__c from Opportunity Where IsClosed = false order by CreatedDate desc';
    
    //implement schedule execute method
    global void execute(SchedulableContext SC)
    {       
        UpdateOppApproverOfOwnerSchedule oppBatch = new UpdateOppApproverOfOwnerSchedule();       
        Map<String, String> userMapSC = new Map<String, String>();
        for(User user : [Select Id, Quote_Approver__c from User ])   
        {
            userMapSC.put(user.Id, user.Quote_Approver__c);
        } 
        oppBatch.userMap = userMapSC;
        DataBase.executeBatch(oppBatch);        
    }
    
    //implement batch method 
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope)
    {
        updateOppApproverOfOwner(scope);
    }
    
    public void updateOppApproverOfOwner(List<Opportunity> opps)
    {
        List<Opportunity> oppList = new List<Opportunity>();        
        if(opps.size() > 0)
        {
            for(Opportunity opp : opps)
            {
                if(opp.QuoteApproverOfOwner__c != userMap.get(opp.OwnerId))
                {
                    opp.QuoteApproverOfOwner__c = userMap.get(opp.OwnerId);
                    oppList.add(opp);
                }
            }
        }
        try
        {
            //if a record fails, the reminder of the Update operation can still succeed
            Database.update(oppList, false);
        }
        catch(DmlException ex){}
    }
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
    @isTest
    static void testBatch()
    {
         Test.startTest();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String, String> userMapTest = new Map<String, String>();
        Account acc = new Account(name = 'acc1');       
        insert acc;
        User userStandt = [select Id, Quote_Approver__c from User where Id=:UserInfo.getUserId() limit 1];
        User userApprover = [select Id from User where IsActive=true and Id!=:UserInfo.getUserId() limit 1];
        userStandt.Quote_Approver__c = userApprover.Id;
        system.debug('###' + userStandt.Quote_Approver__c + '##' + userApprover.Id );
        update userStandt;
        userMapTest.put(userStandt.Id, userStandt.Quote_Approver__c);
        for(Integer i = 0; i < 10; i++)
        {
            Opportunity opp = new Opportunity(); 
            opp.Name = 'opp' + i;
            opp.CloseDate = Date.today();
            opp.StageName = 'Discovery';
            opp.Opportunity_Source__c = 'Dell';
            opp.Type = 'Follow on Business';
            opp.AccountId = acc.Id;
            opp.OwnerId = userStandt.Id;
            opp.Technical_Responsible__c=userApprover.Id;
            opp.Deal_Type__c='Replication';
            oppList.add(opp);
        }       
        insert oppList;
        
       
        UpdateOppApproverOfOwnerSchedule oppBatch = new UpdateOppApproverOfOwnerSchedule();
        oppBatch.query = 'Select Id, OwnerId, QuoteApproverOfOwner__c from Opportunity Where IsClosed = false and OwnerId =  \'' + userStandt.Id +'\' limit 10';
        oppBatch.userMap = userMapTest;
        Database.executeBatch(oppBatch); 
        Test.stopTest();
        
        system.assertEquals(database.countquery('Select count() from Opportunity where QuoteApproverOfOwner__c = \'' + userApprover.Id + '\''), 10);
    } 
    
    @isTest
    static void testSchedule()
    {       
        String p = '0 0 0 3 9 ? 2022';
        
        Test.startTest();               
        String jobId = system.schedule('testDailyUpdateOppSchedule', p, new UpdateOppApproverOfOwnerSchedule());
        CronTrigger ct = [Select id, CronExpression, TimesTriggered, NextFireTime from CronTrigger Where id = :jobId];
        System.assertEquals(p, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));       
        Test.stopTest();    
    }
    
   
}