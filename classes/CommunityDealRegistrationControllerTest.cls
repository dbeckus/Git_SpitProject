@isTest
public class CommunityDealRegistrationControllerTest 
{    
    
    @testSetup
    static void setup()
    {
        List<profile> p = [select Id from profile where name='13g-SP Partner Community' limit 1];
        Account testPortalAccount = new Account(Name='testPortalAccount', Type='Partner', Partner_Type__c='Distributor', GEO_Supported__c='APAC');
        insert testPortalAccount;
        Contact testPortalContact = new Contact(LastName='PortalContact', FirstName='Test', AccountId=testPortalAccount.Id);
        insert testPortalContact;
        User testPartnerUser = new User(Email = 'testuser@test.com', ProfileId = p[0].Id,Username = 'testuser@test.com.sp',Alias = 'TUS',TimeZoneSidKey = 'America/New_York',LocaleSidKey = 'en_US',EmailEncodingKey = 'ISO-8859-1',LanguageLocaleKey = 'en_US',ContactId = testPortalContact.Id,PortalRole = 'Manager',FirstName = 'Test',LastName = 'User');
        insert testPartnerUser;
        
    }
    
    @isTest
    static void test()
    {
        User testPartnerUser = [select Id from User where Email='testuser@test.com'];
        Account currAct = new Account(Name='Test',Type='Partner',Partner_Type__c='Reseller',GEO_Supported__c='APAC');
        insert currAct;
       	System.debug('currAct.Id'+currAct.Id);
        CommunityDealRegistrationController controller = null;
        System.runAs(testPartnerUser){
            SilverPeakUtils.BypassingTriggers = true;
            controller = new CommunityDealRegistrationController();
            List<CommunityDealRegistrationController.SelectOptionWrapper> resellers = CommunityDealRegistrationController.getAllResellers(controller.getRegionFilters());
            System.debug('resellers[0].Value'+resellers[0].Value);
            List<Contact> resellerContact = CommunityDealRegistrationController.getAllResellerContacts(resellers[0].Value);
            List<CommunityDealRegistrationController.SelectOptionWrapper> distributors = CommunityDealRegistrationController.getAllDistributors(controller.getRegionFilters());
            controller.leadRecord = buildLead();
            toSave(controller);
            controller.selectedResellerId = resellers[0].value;
            controller.selectedDistributorId = distributors[0].value;
            controller.leadRecord.DealReg_Reseller_Text__c = 'OtherReseller';
            toSave(controller);
            currAct = controller.getCurrUserAct();
        }
        Account toUpdate = new Account(Id=currAct.Id, Partner_Type__c = 'Reseller');
        update toUpdate;
        System.runAs(testPartnerUser){
            SilverPeakUtils.BypassingTriggers = true;
            controller = new CommunityDealRegistrationController();
            controller.selectedDistributorId = 'other';
            controller.leadRecord.DealReg_Distributor_Text__c = 'OtherDistributor';
            controller.selectedResellerId = '';
            toSave(controller);
        }
    }
    
    @isTest
    static Lead buildLead()
    {
        Lead result = new Lead();
        result.Company = 'TestCompany';
        result.FirstName = 'Tst';
        result.LastName = 'cuctomer';
        result.Phone = '12312312';
        result.PostalCode = '43435';
        result.Street = 'STest';
        result.City = 'San Francisco';
        result.State = 'California';
        result.Country = 'United States';
        result.Project_Name__c = 'TEST Project';
        result.Project_Description__c = 'TEST Description';
        result.Project_Budget_Amount__c = '12312';
        result.Competition__c = 'TEST';
        result.Deal_Source__c = 'Existing Customer';
        result.Deal_Type__c = 'Wan Op';
        result.I_brought_this_deal_to_Silver_Peak__c = 'Silver Peak';
        result.Deal_is_a_result_of_a_SP_funded_event__c = 'No';
        result.Are_u_registering_this_opp_for_someone__c = true;
        result.Partner_Rep_Name__c = 'TEST REP Name';
        result.Partner_Rep_Email__c = 'rep@exampl.com';
        result.Partner_Rep_Phone_Number__c = '1212312';
        return result;
    }
    
    static void toSave(CommunityDealRegistrationController controller)
    {
        PageReference ref = controller.Save();
    }
    
    /*
        Account acctReseller = new Account(Name='testResellerAcct', Type='Partner', Partner_Type__c='Reseller', GEO_Supported__c='APAC');
        Account acctDistributor = new Account(Name='testDistributorAcct', Type='Partner', Partner_Type__c='Distributor', GEO_Supported__c='APAC');
        insert acctReseller;
        insert acctDistributor;
        Contact resellerCtc = new Contact(LastName='reseller', FirstName='Test', AccountId=acctReseller.Id);
        Contact distributorCtc = new Contact(LastName='reseller', FirstName='Test', AccountId=acctDistributor.Id);
        insert resellerCtc;
        insert distributorCtc; 
    */
}