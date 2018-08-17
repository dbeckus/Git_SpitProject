@IsTest
public class TestPartnerAccountSummary {
    
    @isTest(SeeAllData=true)
    public static void CheckPageName_OpenOpp()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        System.debug('acc'+acc.Id);
        Account acc1 = new Account(Name='testACC');
        insert acc1;
        System.debug('acc1'+acc1.Id);
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Profile prof = [SELECT Id FROM Profile WHERE Name='13g-SP Partner Community']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=contact.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc1.Id;
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Registering_Partner__c=acc.Id;
        opportunity.Registering_Partner_Sales_Rep__c=contact.Id;
        opportunity.First_CAM_Assigned__c=usr.Id;
        insert opportunity;
        
        
        
        OpportunityShare oppShare = new OpportunityShare(OpportunityId=opportunity.Id,UserOrGroupId=usr.Id,OpportunityAccessLevel='Edit');
        insert oppShare;
        System.runAs(usr)
        {
            System.debug(opportunity.Registering_Partner__c);
            System.debug(opportunity.Registering_Partner_Sales_Rep__c);
            PageReference pageRef= Page.PartnerAccountSummary;
            Test.setCurrentPage(pageRef);
            PartnerAccountSummaryController obj= new PartnerAccountSummaryController();
            System.assertEquals(1, obj.OpenOppsList.size());
        }
        
    }
    
    @isTest(SeeAllData=true)
    public static void CheckPageName_RenewalOpp()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        Account acc1 = new Account(Name='testACC');
        insert acc1;
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Opportunity opportunity = new Opportunity();
        Profile prof = [SELECT Id FROM Profile WHERE Name='5-SP Contract Mgr']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        AccountShare accShare = new AccountShare(AccountId=acc.Id,UserOrGroupId=usr.Id,AccountAccessLevel='Edit',OpportunityAccessLevel='Edit');
        insert accShare;
        AccountShare acc1Share = new AccountShare(AccountId=acc1.Id,UserOrGroupId=usr.Id,AccountAccessLevel='Edit',OpportunityAccessLevel='Edit');
        insert acc1Share;
        System.runAs(usr)
        {
            opportunity.Name = 'acme';
            opportunity.AccountId = acc1.Id;
            opportunity.StageName = 'Discovery';
            opportunity.Dead_Reason__c = 'acme';
            opportunity.CloseDate = Date.today().addYears(1);
            opportunity.Type = 'Support Renewal';
            opportunity.Opportunity_Source__c = 'Other';
            opportunity.POC_Type__c = 'POC';
            opportunity.Product_Type__c = 'Both';
            opportunity.Deal_Type__c = 'Replication';
            opportunity.Registering_Partner__c=acc.Id;
            opportunity.Registering_Partner_Sales_Rep__c=contact.Id;
            opportunity.First_CAM_Assigned__c=usr.Id;
            insert opportunity;
            
        }
        Profile prof1 = [SELECT Id FROM Profile WHERE Name='13g-SP Partner Community']; 
        User usr1 = new User(Alias = 'standt', Email='testUser@uniquetest1.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = prof1.Id, ContactId=contact.Id,
                             TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest1.com');
        
        usr1.IsActive =true;
        insert usr1;
        OpportunityShare oppShare = new OpportunityShare(OpportunityId=opportunity.Id,UserOrGroupId=usr1.Id,OpportunityAccessLevel='Edit');
        insert oppShare;
        System.runAs(usr1)
        {
            //PageReference pageRef= Page.ShowRenewalOppRelatedListToPartner;
            //Test.setCurrentPage(pageRef);
            PageReference pageRef= Page.PartnerAccountSummary;
            Test.setCurrentPage(pageRef);
            PartnerAccountSummaryController obj= new PartnerAccountSummaryController();
            System.assertEquals(1, obj.RenewalOppsList.size());
        }
        
        
        
    }
    
    @isTest(SeeAllData=true)
    public static void CheckPageName_OpenLeads()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        
        Lead lead = new Lead();
        
        lead.FirstName= 'acme';
        lead.LastName= 'acme';
        lead.Email= 'abc@abc.com';
        lead.Company= 'abcabc.com';
        lead.leadSource='Deal Registration';
        lead.Registered_Partner__c=acc.Id;
        lead.Registered_Partner_Sales_Rep__c=contact.Id;
        lead.Status='Submitted';
        insert lead;
        Profile prof = [SELECT Id FROM Profile WHERE Name='13g-SP Partner Community']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest1.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=contact.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest1.com');
        
        usr.IsActive =true;
        insert usr;
        LeadShare leadShare = new LeadShare(LeadId=lead.Id,UserOrGroupId=usr.Id,LeadAccessLevel='Edit');
        insert leadShare;
        System.runAs(usr)
        {
            //PageReference pageRef= Page.ShowPendingDealRegToPartner;
            //Test.setCurrentPage(pageRef);
            //
            PageReference pageRef= Page.PartnerAccountSummary;
            Test.setCurrentPage(pageRef);
            PartnerAccountSummaryController openOpps= new PartnerAccountSummaryController();
            System.assertEquals(1, openOpps.PendingDealReg.size());
        }
        
        
    }
    
    @isTest(SeeAllData=true)
    public static void RequestTrial_OpenOpp()
    {
        Account acc = new Account(Name='testECPOC');
        insert acc;
        System.debug('acc'+acc.Id);
        Account acc1 = new Account(Name='testACC');
        insert acc1;
        System.debug('acc1'+acc1.Id);
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Profile prof = [SELECT Id FROM Profile WHERE Name='13g-SP Partner Community']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, ContactId=contact.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc1.Id;
        opportunity.StageName = 'Discovery';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Registering_Partner__c=acc.Id;
        opportunity.Registering_Partner_Sales_Rep__c=contact.Id;
        opportunity.First_CAM_Assigned__c=usr.Id;
        insert opportunity;
        
        
        
        OpportunityShare oppShare = new OpportunityShare(OpportunityId=opportunity.Id,UserOrGroupId=usr.Id,OpportunityAccessLevel='Edit');
        insert oppShare;
        System.runAs(usr)
        {
            System.debug(opportunity.Registering_Partner__c);
            System.debug(opportunity.Registering_Partner_Sales_Rep__c);
            PageReference pageRef= Page.PartnerAccountSummary;
            Test.setCurrentPage(pageRef);
            PartnerAccountSummaryController obj= new PartnerAccountSummaryController();
            System.assertEquals(1, obj.OpenOppsList.size());
            obj.OpenOppsList[0].IsChecked=true;
            Test.startTest();
            obj.RequestTrial();
            Test.stopTest();
        }
        
    }
}