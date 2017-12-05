@ISTest
public class TestDeleteSPContractsForExpiredPOC {
    @ISTest
    public static void TestDeleteSPContract()
    {
        
        Account acc = new Account(Name='testECPOC',ECSP__c=true,Service_Provider_Account_Type__c='Perpetual',Service_Provider_Admin_User__c='abc@abc.com',Service_Provider_Domain__c='abc1323',Service_Provider_Location__c='Canada (Central)');
        insert acc;
        
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' , accountId=acc.Id);
        insert contact;
        Account spAcc = new Account(Name='Silver Peak Systems');
        insert spAcc;
        Account speAcc = new Account(Name='EMAIL SUPPORT CONTACTS');
        insert speAcc;
        
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'acme';
        opportunity.AccountId = acc.Id;
        opportunity.Pricebook2Id = TestUtilities.getStandardPricebookId();
        opportunity.StageName = 'Closed Dead';
        opportunity.Dead_Reason__c = 'acme';
        opportunity.CloseDate = Date.today().addYears(1);
        opportunity.Type = 'New Business';
        opportunity.Opportunity_Source__c = 'Other';
        opportunity.POC_Type__c = 'POC';
        opportunity.Product_Type__c = 'Both';
        opportunity.Deal_Type__c = 'Replication';
        opportunity.Solution_Type__c = 'Replication Acceleration';
        opportunity.Technical_Responsible__c=UserInfo.getUserId();
        insert opportunity;
        
        Request__c pocRequest = new Request__c(POC_Contact__c = contact.Id);
        pocRequest.POC_Type__c='Perpetual';
        pocRequest.Opportunity__c= opportunity.id;
        pocRequest.VirtualProduct1__c= 'EC-SP-50-B';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-100-B';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-200-B';
        pocRequest.VirtualQuantity1__c= 5;
        pocRequest.VirtualProduct1__c= 'EC-SP-1000-B';
        pocRequest.VirtualQuantity1__c= 5;
        
        insert pocRequest;     
        Contract con= new Contract();
        con.AccountId=acc.Id;
        con.Contract_Type__c='Evaluation';
        con.Status='Draft';
        insert con;
        con.Status='Activated';
        update con;
        
        pocRequest.Contract_Number__c=con.Id;
        update pocRequest;
        Test.startTest();
        pocRequest.Status__c='Pending Return';
        pocRequest.Target_End_Date__c=Date.today();
        update pocRequest;
      
        DeleteSPContractsForExpiredPOCScheduler obj=new DeleteSPContractsForExpiredPOCScheduler();
        obj.execute(null);
        Request__c req=[Select Id,Contract_Number__c from Request__c where Id=:pocRequest.Id];
        System.assert(req.Contract_Number__c==null);
        Test.stopTest();
        
    }
    
}