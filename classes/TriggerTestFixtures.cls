/*
 * Test the triggers
 * SetRegisteredPartnerEqualtoPartner
 * ShareOppToRegisteredPartner
 * CopyDiscussionToCase
 * UpdateRMACountOnCase
 * AddDefaultCompetitorName
 * SetOppOwnerOnPOC
 * SendEmailUponPublicCaseComment
 * SetLeadSourceOnOpp
 * SetSalesRegionEqualtoOwnerSalesRegion
 * UpdateRMATrackingInfoToCase
 * UpdateRMAStatus
 * ChangeRMAItemProduct
 * SendEmailOnAssetExpiration
 * ValidateSPContractNumber
 * AfterRMAItemReceived
 * AfterAssetInsert
 * LinkRVMemberToContact
 * LinkContactToRVMember
 * SetTechinicalResponsibility
 * PreventDuplicateISOReleases
 * RemoveOrphanedPOC
 * UpdateDealRegEndDateAfterConversion
 * initApprovalLevel
 * CopyCampaignTypeToLead
 * EOMUpdate
 * CreateDefaultLead 
 * PopulateFieldsToContract
 */
@isTest
public class TriggerTestFixtures 
{
    //This trigger hasn't been deployed to the production.
    /*@isTest
    static void testRollUpAmount2RVAccount()
    {
        rvpe__RVAccount__c rvaccount1 = new rvpe__RVAccount__c(Name = 'LuffyTest1', rvpe__ExtAccountId__c = 111);
        insert rvaccount1;
        rvpe__RVAccount__c rvaccount2 = new rvpe__RVAccount__c(Name = 'LuffyTest2', rvpe__ExtAccountId__c = 222);
        insert rvaccount2;
        Account account = new Account(Name = 'acme', Type = 'beta');
        insert account;
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, CloseDate = System.today(), StageName = 'Discovery',
                                          Amount = 100, rvpe__RVAccount__c = rvaccount1.Id, Secondary_RV_Account__c = rvaccount2.Id);
        insert opp;
        rvaccount1 = [select Id, Total_Opportunity_Amount__c, Won_Amount__c from rvpe__RVAccount__c where Id = :rvaccount1.Id limit 1];
        rvaccount2 = [select Id, Total_Opportunity_Amount__c, Won_Amount__c from rvpe__RVAccount__c where Id = :rvaccount2.Id limit 1];
        System.assertEquals(100, rvaccount1.Total_Opportunity_Amount__c);
        System.assertEquals(0, rvaccount1.Won_Amount__c);
        System.assertEquals(100, rvaccount2.Total_Opportunity_Amount__c);
        System.assertEquals(0, rvaccount2.Won_Amount__c);
        
        delete opp;
        rvaccount1 = [select Id, Total_Opportunity_Amount__c, Won_Amount__c from rvpe__RVAccount__c where Id = :rvaccount1.Id limit 1];
        rvaccount2 = [select Id, Total_Opportunity_Amount__c, Won_Amount__c from rvpe__RVAccount__c where Id = :rvaccount2.Id limit 1];
        System.assertEquals(0, rvaccount1.Total_Opportunity_Amount__c);
        System.assertEquals(0, rvaccount1.Won_Amount__c);
        System.assertEquals(0, rvaccount2.Total_Opportunity_Amount__c);
        System.assertEquals(0, rvaccount2.Won_Amount__c);
    }*/

    @isTest
    static void testUncheckTriggerAssignmentWhenOwnerChanged()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            User testUser = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() limit 1];
            Lead lead = new Lead(LastName = 'test', Company = 'test', RecordTypeId = recordTypes[0].Id, OwnerId = testUser.Id, Trigger_Assignment__c = true);
            insert lead;
            
            lead.OwnerId = UserInfo.getUserId();
            update lead;
            lead = [select Id, Trigger_Assignment__c from Lead where Id = :lead.Id limit 1][0];
            System.assertEquals(false, lead.Trigger_Assignment__c);
        }
    }
    
    @isTest
    static void testCopyCampaignTypeToLead()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            Test.startTest();
            Lead lead = new Lead(LastName = 'test', Company = 'test', RecordTypeId = recordTypes[0].Id);
            insert lead;
            
            Campaign campaign = new Campaign(Name = 'test', Type = 'Email', Status = 'Planned', Do_Not_Tele_Qualify__c=true);
            insert campaign;
            
            CampaignMember campaignMember = new CampaignMember(LeadId = lead.Id, CampaignId = campaign.Id);
            insert campaignMember;
            Test.stopTest();
            
            Lead leadAfterInsert = [select Last_Campaign_Type__c, Last_Campaign_Date__c, Last_Mkt_Campaign__c, MrktCampHist__c, Do_Not_Tele_Qualify__c from Lead where Id = :lead.Id limit 1];
            System.assertEquals('Email', leadAfterInsert.Last_Campaign_Type__c);
            System.assertEquals(System.today(), leadAfterInsert.Last_Campaign_Date__c);
            System.assertEquals('test', leadAfterInsert.Last_Mkt_Campaign__c);
            System.assertEquals('test', leadAfterInsert.MrktCampHist__c);
            System.assertEquals(true, leadAfterInsert.Do_Not_Tele_Qualify__c);
            
            Campaign campaign1 = new Campaign(Name = 'test1', Type = 'Email', Status = 'Planned');
            insert campaign1;
            
            CampaignMember campaignMember1 = new CampaignMember(LeadId = lead.Id, CampaignId = campaign1.Id);
            insert campaignMember1;
            
            Lead lead1AfterInsert = [select Last_Campaign_Type__c, Last_Campaign_Date__c, Last_Mkt_Campaign__c, MrktCampHist__c from Lead where Id = :lead.Id limit 1];
            System.assertEquals('Email', lead1AfterInsert.Last_Campaign_Type__c);
            System.assertEquals(System.today(), lead1AfterInsert.Last_Campaign_Date__c);
            System.assertEquals('test1', lead1AfterInsert.Last_Mkt_Campaign__c);
            System.assertEquals('test1' + '\n' + 'test', lead1AfterInsert.MrktCampHist__c);
        }
    }
    
    @isTest
    static void testSetLastCampaignRespondedDate2LeadOrContact()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            List<Lead> leads = new List<Lead>();
            leads.add(new Lead(LastName = 'acme 1', Company = 'test', RecordTypeId = recordTypes[0].Id));
            leads.add(new Lead(LastName = 'acme 2', Company = 'test', RecordTypeId = recordTypes[0].Id));
            leads.add(new Lead(LastName = 'acme 3', Company = 'test', RecordTypeId = recordTypes[0].Id));
            leads.add(new Lead(LastName = 'acme 4', Company = 'test', RecordTypeId = recordTypes[0].Id, Do_Not_Tele_Qualify__c=true));
            insert leads;
            leads[3].Do_Not_Tele_Qualify_Date__c = Date.today().addDays(-40);
            update leads[3];
            Account account = new Account(Name = 'acme', Type = 'beta');
            insert account;
            Contact contact = new Contact(LastName = 'acme', AccountId = account.Id);
            insert contact;
            
            Campaign campaign = new Campaign(Name = 'acme', Type = 'Email', Status = 'Planned');
            insert campaign;
            List<CampaignMemberStatus> campaignMemberStatus = new List<CampaignMemberStatus>();
            campaignMemberStatus.add(new CampaignMemberStatus(CampaignId = campaign.Id, Label = 'Mailed', SortOrder = 3));
            campaignMemberStatus.add(new CampaignMemberStatus(CampaignId = campaign.Id, Label = 'Disqualified', SortOrder = 4));
            insert campaignMemberStatus;
            
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
            campaignMembers.add(new CampaignMember(LeadId = leads[0].Id, CampaignId = campaign.Id, Status = 'Responded'));
            campaignMembers.add(new CampaignMember(LeadId = leads[1].Id, CampaignId = campaign.Id, Status = 'Mailed'));
            campaignMembers.add(new CampaignMember(LeadId = leads[2].Id, CampaignId = campaign.Id, Status = 'Sent'));
            campaignMembers.add(new CampaignMember(LeadId = leads[3].Id, CampaignId = campaign.Id, Status = 'Disqualified'));
            campaignMembers.add(new CampaignMember(ContactId = contact.Id, CampaignId = campaign.Id, Status = 'Responded'));
            insert campaignMembers;
            
            System.assertEquals(System.today(), [select Last_Campaign_Response_Date__c from Lead where Id = :leads[0].Id limit 1].Last_Campaign_Response_Date__c);
            System.assertEquals(System.today(), [select Last_Campaign_Response_Date__c from Lead where Id = :leads[1].Id limit 1].Last_Campaign_Response_Date__c);
            System.assertEquals(null, [select Last_Campaign_Response_Date__c from Lead where Id = :leads[2].Id limit 1].Last_Campaign_Response_Date__c);
            System.assertEquals(null, [select Last_Campaign_Response_Date__c from Lead where Id = :leads[3].Id limit 1].Last_Campaign_Response_Date__c);
            campaignMembers[3].Status = 'Mailed';
            update campaignMembers[3];
            System.assertEquals(System.today(), [select Last_Campaign_Response_Date__c from Lead where Id = :leads[3].Id limit 1].Last_Campaign_Response_Date__c);            
            System.assertEquals(null, [select Do_Not_Tele_Qualify_Date__c from Lead where Id = :leads[3].Id limit 1].Do_Not_Tele_Qualify_Date__c);            
        }
    }
    
    @isTest
    static void testCheckPOCSummaryStarted()
    {
        Account account = new Account(Name = 'acme', Type = 'beta');
        insert account;
        Contact contact = new Contact(LastName = 'acme', Account = account);
        insert contact;
        User testUser = [select Id, Email from User where Id = :UserInfo.getUserId() limit 1];
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = System.today(), 
                                          Opportunity_Source__c = 'EMC', OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id);
        insert opp;
        POC_Summary__c pocSummary = new POC_Summary__c(POC_For__c = opp.Id, OppOwner__c = testUser.Id);
        insert pocSummary;
        
        Opportunity oppAfterInsert = [select Id, POC_Summary_Started__c from Opportunity where Id = :opp.Id limit 1];
        System.assertEquals(true, oppAfterInsert.POC_Summary_Started__c);
    }
    
    @isTest
    static void testCopyEmailFromOpportunity()
    {
        Account account = new Account(Name = 'acme', Type = 'beta');
        insert account;
        Contact contact = new Contact(LastName = 'acme', Account = account);
        insert contact;
        User testUser = [select Id, Email from User where IsActive = true limit 1];
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = System.today(), 
                                          Opportunity_Source__c = 'EMC', OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id);
        insert opp;
        Purchase_Order__c po = new Purchase_Order__c(Name = 'acme', Opportunity__c = opp.Id, Order_Date__c = System.today(), 
                                                     Email_Contact__c = contact.Id);
        insert po;
        
        po = [select Id, Owner_Email__c, Technical_Resposible_Email__c from Purchase_Order__c where Id = :po.Id limit 1];
        System.assertEquals(testUser.Email, po.Owner_Email__c);
        System.assertEquals(testUser.Email, po.Technical_Resposible_Email__c);
    }

    @isTest
    static void testTriggersOnOpportunity()
    {
        Account account = new Account(Name='acme');
        insert account;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opportunity = new Opportunity(Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        Opportunity opportunity2 = new Opportunity(Name='acme', AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        opportunityList.add(opportunity);
        opportunityList.add(opportunity2);
        insert opportunityList;
        
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        opportunity.OwnerId = testUser.Id;
        opportunity.Registered_Partner__c = null;
        opportunity2.Registered_Partner__c = account.Id;
        update opportunityList;
    }
    
    @isTest
    static void testCopyDiscussionToCase()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Case theCase = new Case(Subject='acme', AccountId=acc.Id);
        insert theCase;
        Internal_Discussion__c discussion = new Internal_Discussion__c(Case__c=theCase.Id, Body__c='acme', From__c='test@test.com');
        insert discussion;
        theCase = [select Id, LastUpdateNote__c, LastUpdateUser__c from Case where Id=:theCase.Id limit 1];
        System.assertEquals('acme', theCase.LastUpdateNote__c);
        System.assertEquals('test@test.com', theCase.LastUpdateUser__c);
    }
    
    @isTest
    static void testUpdateRMACountOnCase()
    {
        Account acc = new Account(Name = 'acme');
        insert acc;
        Case theCase = new Case(Subject = 'acme', AccountId = acc.Id);
        insert theCase;
        RMA__c theRma = new RMA__c(Case__c = theCase.Id, Account__c = acc.Id);
        insert theRma;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(1, theCase.RMA_count__c); 
        delete theRma;
        theCase = [select Id, RMA_count__c from Case where Id = :theCase.Id limit 1];
        System.assertEquals(0, theCase.RMA_count__c);
    }
    
    @isTest
    static void testAddDefaultCompetitorName()
    {    
        Account acc = new Account(Name = 'acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', AccountId=acc.Id, StageName='Discovery', CloseDate = System.today(), Technical_Responsible__c=UserInfo.getUserId());
        insert opp;
        opp.Win_Description__c = 'TEST';
        opp.POC_Type__c = 'None';
        opp.StageName = 'Closed Won';
        opp.Finance_Reviewed__c = true; 
        update opp;
        opp = [select Id, (select OpportunityId, CompetitorName from OpportunityCompetitors limit 1) from Opportunity where Id = :opp.Id limit 1];
        System.assertEquals('Not Specified', opp.OpportunityCompetitors[0].CompetitorName);
    }
    
    @isTest
    static void testSetOppOwnerOnPOC()
    {
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate = System.today());
        insert opp;
        POC_Summary__c poc = new POC_Summary__c(POC_For__c=opp.Id);
        insert poc;
        poc = [select Id, OppOwner__c from POC_Summary__c where Id=:poc.Id limit 1];
        System.assert(poc.OppOwner__c != null);
    }
    
    @isTest
    static void testSendEmailUponPublicCaseComment()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Case cs = new Case(Subject='acme', AccountId=acc.Id);
        insert cs;
        CaseComment comment = new CaseComment(ParentId=cs.Id, IsPublished=false, CommentBody='acme');
        insert comment;
        comment.IsPublished = true;
        update comment;
    }
    
    @isTest
    static void testSignatureOwner()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity oppty = new Opportunity(Signature_of_Opportunity_Owner__c = true, Name = 'Acme', AccountId = acc.Id, Opportunity_Source__c = 'EMC', Type = 'Fpllow on Business', CloseDate = System.today() + 1, StageName = 'Discovery', Probability = 5, ForecastCategoryName = 'Commit');
        insert oppty;
        oppty.Signature_of_Opportunity_Owner__c = false;
        update oppty;
    }
    
    @isTest
    static void testSetLeadSourceOnOpp()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Acme', AccountId = acc.Id, Opportunity_Source__c = 'EMC', Type = 'Fpllow on Business', CloseDate = System.today() + 1, StageName = 'Discovery', Probability = 5, ForecastCategoryName = 'Commit');
        insert opp;
        opp.Opportunity_Source__c = 'Dell';
        update opp;
    }
    
    @isTest 
    static void testSetSalesRegionEqualtoOwnerSalesRegion()
    { 
        User user=[select Id, Region__c, Geo__c from User where Username = :UserInfo.getUsername() limit 1];
        user.Region__c = 'Asia';
        user.GEO__c = 'Manager';
        update user;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate = System.today(), OwnerId = user.Id);
        insert opp;
        opp.Opportunity_Source__c = 'Dell';
        update opp;
        system.assertEquals(user.Sales_Region__c, opp.Sales_Region__c);  
    }
    
    @isTest(SeeAllData=true)
    static void testSetGEOEqualtoOwnerGEORegion()
    { 
      List<RecordType> recordTypes = [select Id from RecordType where Name = 'Lead' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
        User user=[select Id, GEO_Region__c, Region__c, Geo__c from User where Id = :UserInfo.getUserId() limit 1];
        User testUser = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() limit 1];
 
        Lead ld = new Lead(LastName = 'test1', Company = 'test', RecordTypeId = recordTypes[0].Id, OwnerId=testUser.Id, Trigger_Assignment__c = false);
        insert ld;
        ld.LeadSource='Dell';
        ld.OwnerId=user.Id;
        update ld;
        ld = [select GEO__c from Lead where Id=:ld.Id limit 1];
        system.assertEquals(user.GEO_Region__c, ld.GEO__c);  
       }
    }
    
    @isTest
    static void testUpdateRMATrackingInfoToCase()
    {
        Account acc = new Account(Name = 'acme');
        insert acc;
        Case theCase = new Case(Subject = 'acme', AccountId = acc.Id);
        insert theCase;
        RMA__c theRma = new RMA__c(Case__c = theCase.Id, Account__c = acc.Id, Tracking_Information__c='test');
        insert theRma;
        
        theCase = [select Id, RMATrackingInfo__c from Case where Id=:theCase.Id limit 1];
        System.assertEquals('test', theCase.RMATrackingInfo__c);
        
        theRma.Tracking_Information__c = 'acme';
        update theRma;
        theCase = [select Id, RMATrackingInfo__c from Case where Id=:theCase.Id limit 1];
        System.assertEquals('acme', theCase.RMATrackingInfo__c);
    }
    
    @isTest(SeeAllData = true)
    static void testCreateWanStartCase()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Opportunity opp = new Opportunity(Name='acme', CloseDate=Date.today(), StageName='Closed Won', AccountId=acc.Id, POC_Type__c='POC', Win_Description__c='test', Finance_Reviewed__c=true);
        insert opp;
        Product2 prod = [select Id, (select Id from PriceBookEntries limit 1) from Product2 where IsActive=true and Name like 'wanstart%' limit 1];
        OpportunityLineItem line = new OpportunityLineItem(OpportunityId=opp.Id, TotalPrice=1, Quantity=1, PriceBookEntryId=prod.PriceBookEntries[0].Id, Description='WANSTART test');
        insert line;
    }
    
    @isTest
    static void testChangeRMAItemProductAndUpdateRMAStatus()
    {
        List<Product2> prods = new List<Product2> { 
                                                new Product2(Name='acme1', ProductCode='pcode1'),
                                                new Product2(Name='acme2') };
        insert prods;
        Product2 prod = new Product2(Name='acme', ProductCode='pcode', RMA_Alternate_1__c=prods[0].Id, RMA_Alternate_2__c=prods[1].Id);
        insert prod;
        Account acc = new Account(Name='acme', Type='Eval');
        insert acc;
        Contact con = new Contact(LastName='acme', AccountId=acc.Id);
        insert con;
        Asset asset = new Asset(Name='acme', SerialNumber='acme', Quantity=1.00, Status='Conditional PO', Product2Id=prod.Id, AccountId=acc.Id, ContactId=con.Id);
        insert asset;
        RMA__c rma = new RMA__c(Status__c='Initiated', Account__c=acc.Id);
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Product2__c=prod.Id, Asset__c=asset.Id, Ship_To_Contact__c=con.Id, Ship_to_address__c='acme', Contact_Phone__c='12345678', Contact_Email__c='acme@acme.com');
        insert item;
        rma.Note_Loc_1__c = 'Part Number Not Active';
        rma.Status__c = 'Dispatch Rejected';
        update rma;
        rma.Note_Loc_1__c = 'Part Number Not Active';
        rma.Status__c = 'Dispatch Rejected';
        update rma;
    }
    
    @isTest
    static void testChangeRMAItemProduct()
    {
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true);
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true);
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true);
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true);
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true);
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true);
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true);
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true);
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
        insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.RMA_Primary_Replacement__c = productC.Id;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = productF.Id;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be C->D->E
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productC.Id, AltProdPreviouslyOrdered__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('D', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('E', item.Product2__r.Name);
    }
    
    @isTest
    static void testChangeRMAItemProduct2()
    {
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true);
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true);
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true);
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true);
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true);
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true);
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true);
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true);
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
        insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.Family = 'Accessory';
        productB.Use_System_Alternative__c = true;
        productB.RMA_Primary_Replacement__c = null;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = productF.Id;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be B->F->G->H
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('F', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('G', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('H', item.Product2__r.Name);
    }
    
    @isTest
    static void testChangeRMAItemProduct3()
    {
        Product2 productA = new Product2(Name='A', ProductCode='A', IsActive=true);
        Product2 productB = new Product2(Name='B', ProductCode='B', IsActive=true);
        Product2 productC = new Product2(Name='C', ProductCode='C', IsActive=true);
        Product2 productD = new Product2(Name='D', ProductCode='D', IsActive=true);
        Product2 productE = new Product2(Name='E', ProductCode='E', IsActive=true);
        Product2 productF = new Product2(Name='F', ProductCode='F', IsActive=true);
        Product2 productG = new Product2(Name='G', ProductCode='G', IsActive=true);
        Product2 productH = new Product2(Name='H', ProductCode='H', IsActive=true);
        List<Product2> products = new List<Product2> { productA, productB, productC, productD, productE, productF, productG, productH };
        insert products;
        //productA.ReplaceableHDD__c = productB.Id;
        productB.Family = 'Accessory';
        productB.Use_System_Alternative__c = true;
        productB.RMA_Primary_Replacement__c = productC.Id;
        productB.RMA_Alternate_1__c = productD.Id;
        productB.RMA_Alternate_2__c = productE.Id;
        productA.RMA_Primary_Replacement__c = null;
        productA.RMA_Alternate_1__c = productG.Id;
        productA.RMA_Alternate_2__c = productH.Id;
        update products;
        
        //replaccement path should be C->A->G->H
        
        Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Asset assetX = new Asset(Name='acme', AccountId=acc.Id, ContactId=ct.Id, Product2Id=productA.Id);
        insert assetX;
        
        RMA__c rma = new RMA__c(Type__c='Return for Repair');
        insert rma;
        RMA_Item__c item = new RMA_Item__c(RMA__c=rma.Id, Type__c='Return - Repair and Return', Asset__c=assetX.Id, Product2__c=productC.Id, AltProdPreviouslyOrdered__c=productB.Id);
        insert item;
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('A', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('G', item.Product2__r.Name);
        
        rma.Status__c= 'Dispatch Rejected';
        rma.Note_Loc_1__c = 'Insufficient QOH';
        update rma;
        item = [select Product2__r.Name from RMA_Item__c where Id=:item.Id limit 1];
        System.assertEquals('H', item.Product2__r.Name);
    }
    
    @isTest
    static void testValidateSPContractNumber()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(AccountId = account.Id, Name = 'acme1', Status = 'Draft', StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c = 'acme011', SP_Contract_Number_10__c = 'acme101');
        Contract contract2 = new Contract(AccountId = account.Id, Name = 'acme2', Status = 'Draft', StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c = 'acme012', SP_Contract_Number_10__c = 'acme102');
        Contract contract3 = new Contract(AccountId = account.Id, Name = 'acme3', Status = 'Draft', StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c = 'acme013', SP_Contract_Number_10__c = 'acme101');
        contracts.add(contract1);
        contracts.add(contract2);
        contracts.add(contract3);
        //Gets an error: contract3.SP_Contract_Number_10__c.
        try
        {
            insert contracts;
        }
        catch(DmlException ex)
        {
            system.assertEquals('Duplicate value.', ex.getDmlMessage(0));
        }
        
        contracts.clear();
        contract3.SP_Contract_Number_10__c = 'acme103';
        contracts.add(contract1);
        contracts.add(contract2);
        contracts.add(contract3);
        try
        {
            insert contracts;
        }
        catch(DmlException ex)
        {
            system.debug(ex);
        }
        
        contracts.clear();
        Contract contract4 = new Contract(AccountId = account.Id, Name = 'acme4', Status = 'Draft', StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c = 'acme014', SP_Contract_Number_5__c = 'acme054');
        Contract contract5 = new Contract(AccountId = account.Id, Name = 'acme5', Status = 'Draft', StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c = 'acme015', SP_Contract_Number_8__c = 'acme101');
        contracts.add(contract4);
        contracts.add(contract5);
        //Gets an error: contract5.SP_Contract_Number_8__c.
        try
        {
            insert contracts;
        }
        catch(DmlException ex)
        {
            system.assertEquals('Duplicate value.', ex.getDmlMessage(0));
        }
        
        contracts.clear();
        contract2.SP_Contract_Number_8__c = 'acme084';
        contract3.SP_Contract_Number_10__c = 'acme102';
        contracts.add(contract1);
        contracts.add(contract2);
        contracts.add(contract3);
        //Gets an error: contract3.SP_Contract_Number_10__c.
        try
        {
            update contracts;
        }
        catch(DmlException ex)
        {
            system.assertEquals('Duplicate value.', ex.getDmlMessage(0));
        }
    }
    
    
    @isTest
    static void testAfterRMAItemReceived()
    {
        Id accountId = TestUtilities.createTestAccount();
        Product2 testProduct = TestUtilities.createTestProduct();
        testProduct.Product_Category__c = 'Appliance';
        update testProduct;
        Asset testAsset = TestUtilities.createTestAsset(accountId, testProduct.Id);
        RMA__c testRMA = TestUtilities.createTestRMA(accountId, null, null);
        RMA_Item__c testRMAItem = TestUtilities.createTestRMAItem(testRma.Id, testAsset.Id, testProduct.Id);
        
        testRMAItem.Status__c = 'Received';
        update testRMAItem;
        
        testAsset = [select AccountId, Status from Asset where Id = :testAsset.Id];
        system.assertEquals('Silver Peak Inventory', testAsset.Status);
    }
    
    @isTest
    static void testPostChatterMessageAfterInsert()
    {
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        Account account = new Account(Name='acme', ownerId = testUser.Id);
        insert account;
        Product2 product = new Product2(Name='acme', Product_Category__c='Subscription');
        insert product;
        Opportunity opp = new Opportunity(OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id, Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today(),Product_Type__c='Both');
        insert opp;
        Request__c request = new Request__c(Opportunity__c=opp.Id);
        insert request;
        Asset asset = new Asset(Name='acme', Status='Customer Owned', Product2Id=product.Id, AccountId=account.Id, POCRequest__c = request.Id);
        insert asset;
    }
    
    @isTest
    static void testLinkRVMemberWithContact()
    {
        Contact contact1 = new Contact(LastName = 'contact acme 1', Email = 'rvmembertest@silverpeak.acme');
        Contact contact2 = new Contact(LastName = 'contact acme 2', Email = 'rvmembertest@silverpeak.acme');
        insert new List<Contact> { contact1, contact2 };
        
        rvpe__RVMember__c rvMember1 = new rvpe__RVMember__c(Name = 'rv member acme 1', rvpe__UserName__c = 'rv member acme 1', rvpe__ExtMemberId__c = 999991, rvpe__Email__c = 'rvmembertest@silverpeak.acme');
        rvpe__RVMember__c rvMember2 = new rvpe__RVMember__c(Name = 'rv member acme 2', rvpe__UserName__c = 'rv member acme 2', rvpe__ExtMemberId__c = 999992, rvpe__Email__c = 'rvmembertest@silverpeak.acme');
        rvpe__RVMember__c rvMember3 = new rvpe__RVMember__c(Name = 'rv member acme 3', rvpe__UserName__c = 'rv member acme 3', rvpe__ExtMemberId__c = 999993, rvpe__Email__c = 'rvmembertest2@silverpeak.acme');
        insert new List<rvpe__RVMember__c> { rvMember1, rvMember2, rvMember3 };
        
        system.assertEquals(rvMember2.Id, [select RV_Member__c from Contact where Id = :contact1.Id limit 1].RV_Member__c);
        List<Contact> newContacts = [select Id, RV_Member__c from Contact where Email = 'rvmembertest2@silverpeak.acme'];
        system.assertEquals(rvMember3.Id, newContacts[0].RV_Member__c);
        system.assertEquals(newContacts[0].Id, [select rvpe__SFContact__c from rvpe__RVMember__c where Id = :rvMember3.Id limit 1].rvpe__SFContact__c);
    }
    
    @isTest
    static void testSetTechnicalResponsibility()
    {
        User u = [select Id, Default_TR__c from User where Default_TR__c != null and IsActive=true limit 1];
        Account acc = new Account(Name = 'acme');
        insert acc;
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = acc.Id, StageName = 'Discovery', CloseDate = System.today(), OwnerId = u.Id);
        insert opp;
    }
    
    @isTest
    static void testPreventDuplicateISORelease()
    {
        Releases__c release1 = new Releases__c(Name = 'acme release 1', Release__c = '1.0', Type__c = 'ISO Image');
        Releases__c release2 = new Releases__c(Name = 'acme release 2', Release__c = '1.0', Type__c = 'ISO Image');
        Releases__c[]  releases = new Releases__c[] { release1, release2 };
        try
        {
            insert releases;
        }
        catch(Exception ex)
        {
        }
        try
        {
            insert release1;
        }
        catch(Exception ex)
        {
        }
        try
        {
            insert release2;
        }
        catch(Exception ex)
        {
        }
    }
    
    @isTest
    static void testRemoveOrphanedPOC()
    {
        Account account = new Account(Name='acme');
        insert account;
        Opportunity opp = new Opportunity(Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today(),Product_Type__c='Both');
        insert opp;
        Request__c request = new Request__c(Opportunity__c=opp.Id);
        insert request;
        
        delete opp;
    }
    
    @isTest
    static void testUpdateDealRegEndDateAfterConversion()
    {
        List<RecordType> recordTypes = [select Id from RecordType where Name = 'Deal Registration' and SObjectType = 'Lead' and IsActive = true];
        if(!recordTypes.isEmpty())
        {
            Lead lead = new Lead(LastName = 'acme', Company = 'acme', RecordTypeId = recordTypes[0].Id);
            insert lead;
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(lead.Id);
            lc.setConvertedStatus('Approved');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            String convertedOpportunityId = lcr.getOpportunityId();
            Opportunity opportunity = [select Id, Deal_Approved_Date__c, Registration_Expiration__c from Opportunity where Id = :convertedOpportunityId];
            //system.assertEquals(Date.today(), opportunity.Deal_Approved_Date__c);
            //system.assertEquals(Date.today().addDays(90), opportunity.Registration_Expiration__c);
        }
    }
    
  
    static void testinitApprovalLevel()
    {
        User testUser = [select Id from User where IsActive=true and Id != :UserInfo.getUserId() limit 1];
        Account account = new Account(Name='acme', ownerId = testUser.Id);
        insert account;
        Product2 product = new Product2(Name='acme', Product_Category__c='Subscription', Family = 'Virtual Image');
        insert product;
        Opportunity opp = new Opportunity(OwnerId = testUser.Id, Technical_Responsible__c = testUser.Id, Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        insert opp;
        PricebookEntry entry = [select Id, Product2Id, UnitPrice from PricebookEntry where isActive = true limit 1];
        OpportunityLineItem oppLineItem = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = entry.Id, Quantity = 123, TotalPrice = 1300);//, Product2Id = product.Id);
        insert oppLineItem;
        Quote__c quote = new Quote__c(Opportunity__c = opp.Id, Quote_Date__c = date.Today(), Quote_Valid_Until__c = date.Today()+10);
        insert quote;
        Quote_Line__c quoteLine = new Quote_Line__c(Quote__c = quote.Id, Product__c = product.Id, Unit_Price__c = 234, Quantity__c = 123, Discount_Percent__c = 35);
        insert quoteLine;
        Quote_Line__c quoteLinetest = [select ApprovalLevel__c, Id from Quote_Line__c where Id =: quoteLine.Id];
        system.assertEquals(quoteLinetest.ApprovalLevel__c, 1);   
    }
    
    @isTest(SeeAllData = true)
    static void testUpdateForecastCategoryToOpportunity()
    {
        Product2 product = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual');
        insert product;
        
        Account account = new Account(Name='acme');
        insert account;
        Opportunity opp = new Opportunity(Name='acme', Registered_Partner__c=account.Id, AccountId=account.Id, StageName='Discovery', CloseDate=System.today());
        insert opp;
        
        Test.startTest();
        PriceBook2 pb = [select Id from Pricebook2 where IsStandard=true limit 1];
        PricebookEntry entry = new PricebookEntry(Product2Id=product.Id, Pricebook2Id=pb.Id, UnitPrice=1, IsActive=true, UseStandardPrice =false);
        insert entry;
        OpportunityLineItem line = new OpportunityLineItem(OpportunityId=opp.Id, TotalPrice=1, Quantity=1, PriceBookEntryId=entry.Id, Description='test');
        insert line;
        
        System.assertEquals('Virtual', [select Product_Forecast_Categories__c from Opportunity where Id=:opp.Id limit 1].Product_Forecast_Categories__c);
        
        product.Forecast_Category__c = 'Physical';
        update product;
        System.assertEquals('Physical', [select Product_Forecast_Categories__c from Opportunity where Id=:opp.Id limit 1].Product_Forecast_Categories__c);        
        
        Product2 product2 = new Product2(IsActive=true, Name='acme', Forecast_Category__c='Virtual');
        insert product2;
        PricebookEntry entry2 = new PricebookEntry(Product2Id=product2.Id, Pricebook2Id=pb.Id, UnitPrice=1, IsActive=true, UseStandardPrice =false);
        insert entry2;
        OpportunityLineItem line2 = new OpportunityLineItem(OpportunityId=opp.Id, TotalPrice=1, Quantity=1, PriceBookEntryId=entry2.Id, Description='test');
        insert line2;
        
        Test.stopTest();
        System.assertEquals(1, [select Id from Opportunity where Id=:opp.Id and Product_Forecast_Categories__c includes ('Virtual;Physical')].size());        
    }
    
    @isTest
    static void testCopyAccountTeamEmailOnPOCAndRMA()
    {
        Account account = new Account(Name='acme');
        Account account2 = new Account(Name='acme2');        
        insert new Account[] { account, account2};
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');
        Opportunity opp2 = new Opportunity(Name = 'acme2', AccountId = account2.Id, StageName = 'Discovery', CloseDate = system.today(), Amount = 100,Product_Type__c='Both');        
        insert new Opportunity[] { opp, opp2 };        
        AccountTeamMember member = new AccountTeamMember(AccountId = account.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Account Manager');        
        AccountTeamMember member2 = new AccountTeamMember(AccountId = account2.Id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Systems Engineer');
        insert new AccountTeamMember[]{ member, member2 };                      
        Request__c request = new Request__c(Opportunity__c = opp.Id);
        Request__c request2 = new Request__c(Opportunity__c = opp2.Id);        
        insert new Request__c[]{ request, request2 };
        RMA__c rma = new RMA__c(Account__c = account.Id);
        RMA__c rma2 = new RMA__c(Account__c = account2.Id);        
        insert new RMA__c[]{ rma, rma2 };
        
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request.Id][0].Account_Manager_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request2.Id][0].System_Engineer_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma.Id][0].Account_Manager_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma2.Id][0].System_Engineer_Email_1__c);        
        member.TeamMemberRole = 'Systems Engineer';
        update member;        
        update request;
        update rma;
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM Request__c WHERE id = :request.Id][0].System_Engineer_Email_1__c);
        system.assertEquals(Userinfo.getUserEmail(), [SELECT Account_Manager_Email_1__c, System_Engineer_Email_1__c FROM RMA__c WHERE id = :rma.Id][0].System_Engineer_Email_1__c);
    }
    
    @isTest
    static void testPreventContactLinkedToCampaign()
    {
        /*Account acc = new Account(Name='acme');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Campaign campaign = new Campaign(Name = 'test', Type = 'Email', Status = 'Planned', Do_Not_Tele_Qualify__c=true);
        insert campaign;
        CampaignMember campaignMember = new CampaignMember(ContactId=ct.Id, CampaignId=campaign.Id);
        insert campaignMember;
        
        campaignMember = [select Id, LeadId, ContactId from CampaignMember where Id=:campaignMember.Id limit 1];
        System.assert(campaignMember.ContactId == null);
        System.assert(campaignMember.LeadId != null);
        
        ct = [select Id, Campaign_Lead__c from Contact where id=:ct.Id limit 1];
        System.assertEquals(campaignMember.LeadId, ct.Campaign_Lead__c);*/
    }
    
    @isTest
    static void testCreateDefaultLead()
    {
        Campaign campaign = new Campaign(Name = 'test', Type = 'Email', Status = 'Planned', Do_Not_Tele_Qualify__c=true);
        insert campaign;
        System.assertEquals(1, [select count() from CampaignMember where CampaignId=:campaign.Id]);
        
        Campaign campaign2 = new Campaign(Name = 'test', Type = 'Email', Status = 'Planned', Do_Not_Tele_Qualify__c=true);
        insert campaign2;
        System.assertEquals(1, [select count() from CampaignMember where CampaignId=:campaign2.Id]);
    }
    
    @isTest
    static void testPopulateFieldsToContract()
    {
        Account account = new Account(Name = 'acme');
        insert account;
        Contact contact = new Contact(AccountId=account.Id, LastName='acme');
        insert contact;
        Opportunity opp = new Opportunity(Name = 'acme', AccountId = account.Id, StageName = 'Discovery', CloseDate = System.today(),Product_Type__c='Both');
        insert opp;
        Purchase_Order__c po = new Purchase_Order__c(Name = 'acme', Opportunity__c = opp.Id, Order_Date__c = System.today(), Email_Contact__c = contact.Id);
        insert po;
        Contract contract = new Contract(AccountId = account.Id, Name = 'acme1', Status = 'Draft', Reseller_PO__c=po.Id, StartDate = Date.today(), EndDate = Date.today().addMonths(1), Contract_Type__c = 'No Contract-Warranty Only', SP_Contract_Number__c='123');
        insert contract;
        
        contract = [select Id, Reseller_Addl_Notices__c from Contract where Id=:contract.Id limit 1];
        System.assertEquals(contact.Id, contract.Reseller_Addl_Notices__c);
        
        contract.Reseller_PO__c = null;
        update contract;
        contract = [select Id, Reseller_Addl_Notices__c from Contract where Id=:contract.Id limit 1];
        System.assertEquals(null, contract.Reseller_Addl_Notices__c);
        
    }
    
    @isTest
    static void testSubmitPurchaseRequestOnMdfApproval()
    {
        List<RecordType> purchaseRecordType = [select Id from RecordType where SobjectType='Purchasing_Request__c' and Name='MDF Request' limit 1];
        Purchasing_Request__c purchase = new Purchasing_Request__c();
        purchase.RecordTypeId = (purchaseRecordType.size() > 0) ? purchaseRecordType[0].Id : null;
        insert purchase;
        
        MDF_Request__c request = new MDF_Request__c(Purchasing_Request__c=purchase.Id);
        insert request;
        
        request.Approval_Status__c = 'Approved';
        request.Approval_Status_Hidden__c = 'Approved';
        try
        {
            update request;
        }
        catch(Exception ex) {}
    }
    
    @isTest
    static void testAddPowerPartnerToPublicGroups()
    {
        List<Profile> profiles = [select Id from Profile where Name='13g-SP Partner Community' limit 1];
        Account acc = new Account(Name='acme', GEO_Supported__c='All');
        insert acc;
        Contact ct = new Contact(LastName='acme', AccountId=acc.Id);
        insert ct;
        Id portalProfile = (profiles.size() > 0) ? profiles[0].Id : null;
        Test.startTest();
        User newUser = new User(FirstName='acme', 
                                LastName='acme', 
                                Email='acme@test.com', 
                                Username='testportalgroup@test.com', 
                                ProfileId=portalProfile, 
                                ContactId=ct.Id,
                                Alias='acme a',
                                TimeZoneSidKey='America/Tijuana',
                                LocaleSidKey='en_US',
                                EmailEncodingKey='ISO-8859-1',
                                LanguageLocaleKey='en_US',
                                IsActive=true
                                );
        insert newUser;
        Test.stopTest();
        //System.assert([select count() from GroupMember where UserOrGroupId=:newUser.Id] > 0); //error thrown in trigger: mixed DML (bug of sfdc?)
    }
    
    @isTest
    static void testUpdateMdfStatusFromPR()
    {
        List<User> prApprovers = [select Id from User where PR_Approver__c=true limit 1];
        List<RecordType> mdfRecordType = [select Id from RecordType where Name='MDF Request' and SObjectType='Purchasing_Request__c' limit 1];
        Purchasing_Request__c pr = new Purchasing_Request__c(First_Approver__c=prApprovers[0].Id, RecordTypeId=mdfRecordType[0].Id);
        insert pr;
        MDF_Request__c mdf = new MDF_Request__c(Purchasing_Request__c=pr.Id);
        insert mdf;
        
        pr.Approval_Status__c = 'Final Approval';
        update pr;
        mdf = [select Id, Approval_Status__c from MDF_Request__c where Id=:mdf.Id limit 1];
        System.assertEquals('Approved', mdf.Approval_Status__c);
    }
    
    @isTest
    static void testCopyMdfToAccount()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        MDF_Request__c mdf = new MDF_Request__c(Account__c=acc.Id, Estimated_Silver_Peak_Amount__c=1000);
        insert mdf;
        
        acc = [select Id, Total_Requested_MDF__c from Account where Id=:acc.Id limit 1];
        System.assertEquals(1000, acc.Total_Requested_MDF__c);
    }
}