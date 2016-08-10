public class TestLeadToPOCAutomation 
{   
    /* This is disabled because the automation of marketplace trial is turned off
    @isTest
    static void testVXXModel() 
    {
        Test.startTest();
        
        //create new lead that will trigger the LeadToPOCAutomation
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Phone = '333';
        l.Email = '123@email.com';
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-X';
        insert l;
        
        Test.stopTest();
        
        List<Lead> leadlist = [select Id, IsConverted from Lead where Id =:l.Id limit 1];
        system.assertEquals(false, leadlist[0].isConverted);
        List<Lead> duplicateLeads = [select Id from Lead where Email=:l.Email limit 1];
        System.assertEquals(1, duplicateLeads.size());
    }
    
    @isTest
    static void testBlacklistedEmail() 
    {
        BlacklistedDomains__c blackDomain = new BlacklistedDomains__c(Domain__c='1-usa.com', Name='1-usa.com');
        insert blackDomain;
        
        Test.startTest();
        
        //create new lead that will trigger the LeadToPOCAutomation
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Email = 'Email12871@' + blackDomain.Domain__c;
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-2000';
        insert l;
        
        Test.stopTest();
        
        List<Lead> leadlist = [Select id, isConverted From Lead Where id =: l.id limit 1];
        system.assertEquals(false, leadlist[0].isConverted);
    }

    @isTest
    static void testNoContactFound() 
    {
        Test.startTest();
        
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Email = 'email12871@myemail.com';
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-2000';
        l.LeadSource = 'Web- Trial Request';
        insert l;
        
        Test.stopTest();
        
        List<Lead> leadlist = [select Id, IsConverted, LastName from Lead where Id =:l.id limit 1];
        System.assertEquals(true, leadlist[0].isConverted);
    }

    @isTest
    static void testContactFound() 
    {  
        Account acct = new Account(Name='Account19883');
        insert acct;
        Contact cont = new Contact(AccountId=acct.Id, FirstName='First19jnd712', LastName='Last 128740', Email='email12871@myemail.com');
        insert cont;
        
        List<Id> resultlist = new List<Id>();
        resultlist.add(cont.Id);
        Test.setFixedSearchResults(resultlist);
            
        Test.startTest();

        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Email = cont.email;
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-2000';
        l.LeadSource='Web- Trial Request';
        insert l;
    
        Test.stopTest();
        
        List<Lead> leadlist = [select Id, IsConverted, LastName from Lead where Id =:l.Id limit 1];
        System.assertEquals(true, leadlist[0].isConverted);
        System.assertEquals(cont.LastName, leadlist[0].LastName);
    }
    
    @isTest
    static void testLeadConvert()
    {
        //Curtis Christensen is the default creator of leads from web-2-lead
        List<User> users = [select Id from User where FirstName='Curtis' and LastName='Christensen' limit 1];
        if(users.size() == 1)
        {
            System.runAs(users[0])
            {
                Test.startTest();
                Lead web2Lead = new Lead(Truly_Free_POC_Setup__c=false, 
                                        Model_for_Trial__c='VX-2000', 
                                        Trial_Request_from_Marketplace__c=true, 
                                        Marketplace_Code__c='', Description='Web- Trial Request', 
                                        RecordTypeId=[select Id from RecordType where SObjectType='Lead' and Name='Lead' limit 1].Id,
                                        Status='Suspect',
                                        Company='Silverfern',
                                        Country='Australia',
                                        Email='test@test.com',
                                        FirstName='Rene',
                                        LastName='Lahaye',
                                        LeadSource='Web- Trial Request'
                                    );
                insert web2Lead;
                Test.stopTest();
                List<Lead> leadlist = [select Id, IsConverted from Lead where Id =:web2Lead.Id limit 1];
                System.assertEquals(true, leadlist[0].isConverted);
            }
        }
        else
        {
            System.assert(false, 'Customer Serivce user does not exist');
        }
    }
    
    @isTest
    static void testCampaignLink()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Campaign campaign1 = new Campaign(Name = 'test marketplace code', Type = 'Email', Status = 'Planned');
        insert campaign1;
        Campaign campaign2 = new Campaign(Name = 'test VRX-8', Type = 'Email', Status = 'Planned');
        insert campaign2;
        Campaign campaign3 = new Campaign(Name = 'test last_mkt_campaign', Type = 'Email', Status = 'Planned');
        insert campaign3;
        Partner_Account_Profile__c pap = new Partner_Account_Profile__c(Marketplace_Code_1_Campaign__c = campaign1.Id, Account__c=acc.Id, Marketplace_1__c='test');
        insert pap;
        ProductCampaignMapping__c mapping = new ProductCampaignMapping__c(Name='VRX-8', CampaignId__c=campaign2.Id);
        insert mapping;
        
        Test.startTest();
        Lead testLead = new Lead(FirstName = '123', lastName = '456', Company = '789', Phone = '111', Email = '123@email.com', Last_Mkt_Campaign__c=campaign3.Id, Marketplace_Code__c = pap.Marketplace_1__c, Model_for_Trial__c='VRX-8', Trial_Request_from_Marketplace__c=true, LeadSource='Web- Trial Request');
        insert testLead;
        Test.stopTest();
        
        List<Lead> leadlist = [select Id, IsConverted, Last_Mkt_Campaign_Id__c from Lead where Id =:testLead.Id limit 1];
        System.assertEquals(true, leadlist[0].isConverted);
        System.assertEquals(campaign3.Id, leadlist[0].Last_Mkt_Campaign_Id__c);
        List<CampaignMember> campaignMembers = [select Id from CampaignMember where LeadId=:leadlist[0].Id];
        System.assertEquals(3, campaignMembers.size());
    }
    
    @isTest
    static void testExistedLeadFound()
    {
        Lead extLead = new Lead(FirstName='acme', LastName='acme', Company='acme', Email='test@email.com');
        insert extLead;
        
        Test.startTest();
        Lead newLead = new Lead(FirstName='acme 2', LastName='acme 2', Company='acme 2', Email=extLead.Email, Trial_Request_from_Marketplace__c=true, Model_for_Trial__c='VX-1000', LeadSource='Web- Trial Request');
        insert newLead;
        Test.stopTest();
        
        newLead = [select Id, FirstName, LastName, Company, Email, IsConverted from Lead where Id =:newLead.Id limit 1];
        System.assertEquals(true, newLead.IsConverted);
        extLead = [select Id, FirstName, LastName, Company, Email from Lead where Id=:extLead.Id limit 1];
        System.assertEquals('acme 2', extLead.FirstName);
        System.assertEquals('acme 2', extLead.FirstName);
        System.assertEquals('acme 2', extLead.FirstName);
    }
    
    @isTest(SeeAllData=true)
    static void testPurchaseRequest()
    {
        Test.startTest();
        Lead newLead = new Lead(FirstName='acme', LastName='acme', Company='acme', Email='acme@test.com', Trial_Request_from_Marketplace__c=true, Model_for_Trial__c='VX-5000-g-6,VX-9000-p-3, VX-6000-s-99', LeadSource = 'Web- Purchase Request');
        insert newLead;   
        Test.stopTest();
        
        newLead = [select Id, ConvertedOpportunityId from Lead where Id=:newLead.Id limit 1];
        
        List<Opportunity> opportunities = [select Id, Name, StageName, (select Id, UnitPrice from OpportunityLineItems) from Opportunity where Id=:newLead.ConvertedOpportunityId limit 1];
        System.assertEquals(1, opportunities.size());
        System.assertEquals('Technically Selected', opportunities[0].StageName);
        system.assertEquals(5, opportunities[0].OpportunityLineItems.size());
    }
    
    @isTest
    static void testLeadToPOCAutomationHelper()
    {
        Lead ld = new Lead(LastName='acme', Company='acme');
        insert ld;
        Account acc = new Account(Name='acme');
        insert acc;
        Campaign cp = new Campaign(Name='acme');
        Campaign cp2 = new Campaign(Name='acme');
        Campaign cp3 = new Campaign(Name='acme');
        insert new List<Campaign> { cp, cp2, cp3 };
        ProductCampaignMapping__c mapping = new ProductCampaignMapping__c(Name='VRX-8', CampaignId__c=cp.Id);
        insert mapping;
        Partner_Account_Profile__c pap = new Partner_Account_Profile__c(Account__c=acc.Id, Marketplace_1__c='code1', Marketplace_Code_1_Campaign__c=cp2.Id);
        insert pap;
        
        Test.startTest();
        LeadToPOCAutomationHelper.linkLeadToModelCampaign(ld.Id, 'VRX-8');
        LeadToPOCAutomationHelper.linkLeadToMarketplaceCampaign(ld.Id, pap.Marketplace_1__c);
        LeadToPOCAutomationHelper.linkLeadToCampaign(ld.Id, cp3.Id);
        Test.stopTest();       
        
        List<CampaignMember> members = [select Id from CampaignMember where LeadId=:ld.Id];
        System.assertEquals(3, members.size());
    }
    
    @isTest
    static void testResolveModelTrial()
    {
        List<LeadToPOCAutomationHelper.ModelInfo> models = null;
        models = LeadToPOCAutomationHelper.resolveModelTrial('VX-5000-G-6');
        System.assertEquals(1, models.size());
        System.assertEquals('VX-5000', models[0].Name);
        System.assertEquals('G', models[0].Type);
        System.assertEquals(6, models[0].Qty);
        
        models = LeadToPOCAutomationHelper.resolveModelTrial('VX-5000');
        System.assertEquals(1, models.size());
        System.assertEquals('VX-5000', models[0].Name);
        System.assertEquals(null, models[0].Type);
        System.assertEquals(null, models[0].Qty);  
        
        models = LeadToPOCAutomationHelper.resolveModelTrial('VX-5000-g-6,VX-9000-p-3, VX-10000-s-99');        
        System.assertEquals(3, models.size());
        System.assertEquals('VX-5000', models[0].Name);
        System.assertEquals('G', models[0].Type);
        System.assertEquals(6, models[0].Qty);    
        System.assertEquals('VX-9000', models[1].Name);
        System.assertEquals('P', models[1].Type);
        System.assertEquals(3, models[1].Qty);   
        System.assertEquals('VX-10000', models[2].Name);
        System.assertEquals('S', models[2].Type);
        System.assertEquals(99, models[2].Qty); 
        
        models = LeadToPOCAutomationHelper.resolveModelTrial('VX5000-G-6');
        System.assertEquals(1, models.size());
        System.assertEquals('VX5000', models[0].Name);
        System.assertEquals('G', models[0].Type);
        System.assertEquals(6, models[0].Qty);  
        
        models = LeadToPOCAutomationHelper.resolveModelTrial('acme');
        System.assertEquals(1, models.size());
        System.assertEquals('acme', models[0].Name);
        System.assertEquals(null, models[0].Type);
        System.assertEquals(null, models[0].Qty);  
    }*/
}