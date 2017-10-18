public class TestFixtures {
	static testMethod void testMailService()
	{
		Messaging.InboundEmail email = new Messaging.InboundEmail();
		email.fromAddress = 'harry.zhang@meginfo.com'; 
		email.subject = 'test mail service';
		email.plainTextBody='test mail service';
		Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
		envelope.fromAddress = 'harry.zhang@meginfo.com';
		envelope.toAddress = 'support@45wt0rydc6b3qg7nykfb0e99n.in.salesforce.com';
		Messaging.InboundEmail.TextAttachment attachment = new Messaging.InboundEmail.TextAttachment();
		attachment.Body = 'test';
		attachment.Filename = 'Test';
		email.TextAttachments = new Messaging.InboundEmail.TextAttachment[] {attachment };
		
		myHandler handler = new myHandler();
		Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
		System.assertEquals(null, result.message);
		
		email.subject='test for mail service 028[20051116-1111]';
		email.plainTextBody='new case comment';
		result = handler.handleInboundEmail(email,envelope);
		System.assertEquals(null, result.message);
		
		email.fromAddress = 'kevin.cong@meginfo.com';
		email.subject = 'test mail service from kevin';
		envelope.fromAddress = 'harry zhang';
		result = handler.handleInboundEmail(email, envelope);
		System.assertEquals(null, result.message);
		
		email.fromAddress = 'kevin.cong@meginfo.com';
		email.subject = 'test mail out of office';
		envelope.fromAddress = 'harry zhang';
		result = handler.handleInboundEmail(email, envelope);
		System.assertEquals(null, result.message);
		
		email.fromAddress = 'kevin.cong@meginfo.com';
		email.fromName = 'System Administrator'; 
		email.subject = 'test mail for system administrator';
		result = handler.handleInboundEmail(email, envelope);
		System.assertEquals(null, result.message);
	}

	static testMethod void triggerTest()
	{
        
		Opportunity opportunity = new Opportunity(name = 'test opp', OwnerId = userInfo.getUserId(), StageName = 'Discovery', CloseDate = Date.Today(),Product_Type__c='Both');
		insert opportunity;
       
		List<request__c> requests = new List<request__c>();
		for(Integer i = 0; i < 10; i++)
		{
			Request__c request = new Request__c(Opportunity__c = opportunity.Id);
			requests.add(request);
		}
         Test.startTest();
		insert requests;
       
		request__c tmprequest = [select Opportunity_Owner__c from Request__c where Id = : requests[5].Id];
        Test.stopTest();
		System.assertEquals(userInfo.getName(), tmprequest.Opportunity_Owner__c);
		System.debug(tmprequest.Opportunity_Owner__c);
		delete requests;
		delete opportunity; 
       
	} 

	static testMethod void testTriggerTroubleshootAidOnCase()
	{		
		Troubleshoot_Aids__c troubleshootAid = new Troubleshoot_Aids__c(
			Field_Linked__c = 'DoesNotExist',
			Field_Value__c = 'Match',
			URL__c = 'http://www.ensemble.us.com/');
		insert troubleshootAid;
		
		Case c = new Case();
		insert c;
		
		System.assertEquals(null, [SELECT Troubleshoot_URL__c
								   FROM Case
								   WHERE Id = :c.Id].Troubleshoot_URL__c);
		
		troubleshootAid.Field_Linked__c = 'Reason';
		update troubleshootAid;
		
		update c;
		
		System.assertEquals(null, [SELECT Troubleshoot_URL__c
								   FROM Case
								   WHERE Id = :c.Id].Troubleshoot_URL__c);
		
		c.Reason = 'NoMatch';
		update c;
		
		System.assertEquals(null, [SELECT Troubleshoot_URL__c
								   FROM Case
								   WHERE Id = :c.Id].Troubleshoot_URL__c);
								   
		c.Reason = 'Match';
		update c;
		
		System.assertEquals('http://www.ensemble.us.com/', [SELECT Troubleshoot_URL__c
															FROM Case
															WHERE Id = :c.Id].Troubleshoot_URL__c);
															
		List<Case> cases = new List<Case>();
		for (Integer i = 0; i < 100; i++)
		{
			cases.add(new Case(
				Reason = 'Match'));
		}
		
		Test.startTest();
		insert cases;
		Test.stopTest();
	}
}