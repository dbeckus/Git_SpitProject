@IsTest
public class TestDefineChannelQuoteController {
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme');
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
    
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, '')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, '')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, '')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        
        //tests isValidInput method
        
    }
    
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_Save()
    {
        
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme');
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
   
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.PartnerData.Registering_PartnerId=partnerAcc.Id;
        controller.PartnerData.Registering_Partner_Sales_RepId=con.Id;
        controller.save();
        Opportunity expopp=[Select Id, Registering_Partner__c, Registering_Partner_Sales_Rep__c from Opportunity where Id=:opp.Id];
        System.assertEquals(partnerAcc.Id, expopp.Registering_Partner__c);
        System.assertEquals(con.Id, expopp.Registering_Partner_Sales_Rep__c);
    }
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_NAM_Validation()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;

        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Reseller Account is mandatory for North America Accounts.')) b = true;
        }
        system.assert(b);
    }
    
    static void testDefineChannelQuoteController_Distributor_Validation()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='APAC',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Type='Partner',GEO_Supported__c='APAC');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
       
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Distributor Account is mandatory for international accounts.')) b = true;
        }
        system.assert(b);
    }
    
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_NAM_Distributor_Validation()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=false,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
       
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.PartnerData.Registering_PartnerId=partnerAcc.Id;
        controller.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Distributor Partner Account is required as reseller doesnt have valid reseller agreement.')) b = true;
        }
        system.assert(b);
    }
    
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_Contact_Mismatch_Validation()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='NAM',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Partner_Level__c='Summit',GEO_Supported__c='NAM');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com');
        insert con;
        Contact con1 = new Contact(FirstName='TestFirstName1',LastName='TestLastName1', email='testUser1@testtechuser.com');
        insert con1;
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
       
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.PartnerData.Registering_PartnerId=partnerAcc.Id;
        controller.PartnerData.Registering_Partner_Sales_RepId=con1.Id;
        controller.save();
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('This contact does not belong to this Reseller Account.')) b = true;
        }
        system.assert(b);
    }
    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_Distributor_Contact_Validation()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='APAC',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Type='Partner',Partner_Type__c='Distributor',GEO_Supported__c='APAC');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com',Quote_Contact__c=true);
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id);
        insert opp;
       
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        controller.PartnerData.Registered_DistributorId=partnerAcc.Id;
        
        controller.save();
        Opportunity expopp=[Select Id, Registered_Distributor_Contact__c from Opportunity where Id=:opp.Id];
        System.assertEquals(con.Id, expopp.Registered_Distributor_Contact__c);
    }

    @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_InitialValues()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='APAC',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Type='Distributor',GEO_Supported__c='APAC');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com',Quote_Contact__c=true);
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Amount=1,Patch__c=patch.Id,Registering_Partner__c=partnerAcc.Id,Registering_Partner_Sales_Rep__c=con.Id);
        insert opp;

        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        System.assert(controller.InitialSelectedPartners.size()>0);
    }
     @Istest(SeeAllData=true)
    static void testDefineChannelQuoteController_Partner_Initiated()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User techUser = new User(Alias = 'standt', Email='testUser@testtechuser.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = prof.Id, GEO__c='APAC',
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser@testtechuser.com');
        
        techUser.IsActive =true;
        insert techUser;
        Patch__c patch= new Patch__c(RSM__c=techUser.Id);
        insert patch;
        
        Pricebook2 priceBook = new Pricebook2(Name='standard');
        insert priceBook;
        Account acc = new Account(Name='acme',Patch__c=patch.Id);
        insert acc;
        
        Account partnerAcc = new Account(Name='TestPartner', Reseller_Agreement__c=true,Type='Distributor',GEO_Supported__c='APAC');
        insert partnerAcc;
        Contact con = new Contact(FirstName='TestFirstName',LastName='TestLastName',AccountId=partnerAcc.Id, email='testUser@testtechuser.com',Quote_Contact__c=true);
        insert con;
        
        Opportunity opp = new Opportunity(Name='acme', StageName='Discovery', CloseDate=Date.today(), AccountId=acc.Id, Pricebook2id=priceBook.Id, Deal_Reg__c=true,Amount=1,Patch__c=patch.Id,Registering_Partner__c=partnerAcc.Id,Registering_Partner_Sales_Rep__c=con.Id);
        insert opp;
       
        
        PageReference page = new PageReference('/apex/DefineChannelForQuote?id=' + opp.Id);
        Test.setCurrentPage(page);
        DefineChannelQuoteController controller = new DefineChannelQuoteController();
        System.assert(DefineChannelQuoteController.InitResellerAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitDistributorAccounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitTier3Accounts(acc.Id, 'Test')!='');
        System.assert(DefineChannelQuoteController.InitResellerContacts(partnerAcc.Name, '')!='');
        System.assert(controller.InitialSelectedPartners.size()>0);
    }
}