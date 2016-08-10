@IsTest
public class TestDeleteDealRegRejectedLeads {

    @IsTest
    public static void DeleteRejectedLeadAfter30days()
    {
        Test.startTest();
        System.Address addr= new  System.Address();
       
        //create new lead that will trigger the LeadToPOCAutomation
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Phone = '333';
        l.LeadSource='Deal Registration';
        l.State='California';
        l.Status='Rejected';
        l.Lead_Rejected_Date__c= Date.today().addDays(-31);
        l.Email = '123@email.com';
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-X';
        insert l;
        DeleteDealRegRejectedLeads deleteLeadBatch= new DeleteDealRegRejectedLeads();
        Database.executeBatch(deleteLeadBatch);
        Test.stopTest();
        
        List<Lead> leadlist = [select Id from Lead where Id =:l.Id limit 1];
        system.assertEquals(0, leadlist.size());
      
    }
    
     @IsTest
    public static void DeleteRejectedLeadBefore30days()
    {
        Test.startTest();
        System.Address addr= new  System.Address();
       
        //create new lead that will trigger the LeadToPOCAutomation
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Phone = '333';
        l.LeadSource='Deal Registration';
        l.State='California';
        l.Status='Rejected';
        l.Lead_Rejected_Date__c= Date.today().addDays(-20);
        l.Email = '123@email.com';
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-X';
        insert l;
        DeleteDealRegRejectedLeads deleteLeadBatch= new DeleteDealRegRejectedLeads();
        Database.executeBatch(deleteLeadBatch);
        Test.stopTest();
        
        List<Lead> leadlist = [select Id from Lead where Id =:l.Id limit 1];
        system.assertEquals(1, leadlist.size());
      
    }
     @IsTest
    public static void DeleteRejectedLead_Today()
    {
        Test.startTest();
        System.Address addr= new  System.Address();
       
        //create new lead that will trigger the LeadToPOCAutomation
        Lead l = new Lead();
        l.FirstName = 'First19jnd712';
        l.LastName = 'Last128740';
        l.Company = 'Company1286329';
        l.Phone = '333';
        l.LeadSource='Deal Registration';
        l.State='California';
        l.Status='Rejected';
        l.Lead_Rejected_Date__c= Date.today();
        l.Email = '123@email.com';
        l.Trial_Request_from_Marketplace__c = true;
        l.Model_for_Trial__c = 'VX-X';
        insert l;
        DeleteDealRegRejectedLeads deleteLeadBatch= new DeleteDealRegRejectedLeads();
        Database.executeBatch(deleteLeadBatch);
        Test.stopTest();
        
        List<Lead> leadlist = [select Id from Lead where Id =:l.Id limit 1];
        system.assertEquals(1, leadlist.size());
      
    }
}