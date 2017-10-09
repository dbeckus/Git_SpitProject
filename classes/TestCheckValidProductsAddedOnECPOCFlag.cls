@isTest
public class TestCheckValidProductsAddedOnECPOCFlag {

  /*@isTest
    static void testECToNonECPocRequest()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='EdgeConnect';
        request.PhysicalProduct1__c = 'EC-XS';
        request.PhysicalProduct2__c = 'EC-XS';
        request.PhysicalProduct3__c = 'EC-XS';
        request.PhysicalProduct4__c = 'EC-XS';
        request.PhysicalProduct5__c = 'EC-XS';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'EC-BASE-1Y';
        request.VirtualProduct2__c = 'EC-BASE-1Y';
        request.VirtualProduct3__c = 'EC-BASE-1Y';
        request.VirtualProduct4__c = 'EC-BASE-1Y';
        request.VirtualProduct5__c = 'EC-BASE-1Y';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;

        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.POC_Type__c='EdgeConnect';
        try
        {
        	update request;
        }
        catch(Exception e)
        {
           Boolean expectedExceptionThrown =  e.getMessage().contains('EdgeConnect and Non-EdgeConnect products cannot be mixed') ? true : false;
		   System.AssertEquals(expectedExceptionThrown, true); 
        }
        
    }  
    
    @isTest
    static void testNonECToECPocRequest()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.PhysicalProduct1__c = 'NX-700';
        request.PhysicalProduct2__c = 'NX-1700';
        request.PhysicalProduct3__c = 'NX-2700';
        request.PhysicalProduct4__c = 'NX-3700';
        request.PhysicalProduct5__c = 'NX-5700';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'VRX-2';
        request.VirtualProduct2__c = 'VRX-2';
        request.VirtualProduct3__c = 'VRX-2';
        request.VirtualProduct4__c = 'VRX-2';
        request.VirtualProduct5__c = 'VRX-2';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;

        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.POC_Type__c='EdgeConnect';
        try
        {
        	update request;
        }
        catch(Exception e)
        {
           Boolean expectedExceptionThrown =  e.getMessage().contains('EdgeConnect and Non-EdgeConnect products cannot be mixed') ? true : false;
		   System.AssertEquals(expectedExceptionThrown, true); 
        }
        
    }  
    
    @isTest
    static void testUpdatePocRequest()
    {
        Contact contact = new Contact(FirstName = 'AcmeFirstname', LastName = 'AcmeLastname', Phone='123456789', Email = 'acme@acme.com' );
        insert contact;
        Request__c request = new Request__c(POC_Contact__c = contact.Id);
        request.POC_Type__c='WAN Op';
        request.PhysicalProduct1__c = 'NX-700';
        request.PhysicalProduct2__c = 'NX-1700';
        request.PhysicalProduct3__c = 'NX-2700';
        request.PhysicalProduct4__c = 'NX-3700';
        request.PhysicalProduct5__c = 'NX-5700';
        request.PhysicalQuantity1__c = 10;
        request.PhysicalQuantity2__c = 10;
        request.PhysicalQuantity3__c = 10;
        request.PhysicalQuantity4__c = 10;
        request.PhysicalQuantity5__c = 10;
        request.PhysicalLocation1__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation2__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation3__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation4__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        request.PhysicalLocation5__c = 'Street1' + '\r\n' + 'Street2' + '\r\n' + 'Moscow, BC 12' + '\r\n' + 'Canada' + '\r\n' + 'Kevin chong' + '\r\n' + '12111' + '\r\n' + 'company' + '\r\n' + 'finalCountry' + '\r\n' + 'finalFirstname finalLastname' + '\r\n' + '123234' + '\r\n' + 'finalCompany' + '\r\n' + 'vatId' + '\r\n' + 'vatAddress';
        
        request.VirtualProduct1__c = 'VRX-2';
        request.VirtualProduct2__c = 'VRX-2';
        request.VirtualProduct3__c = 'VRX-2';
        request.VirtualProduct4__c = 'VRX-2';
        request.VirtualProduct5__c = 'VRX-2';
        request.VirtualQuantity1__c = 10;
        request.VirtualQuantity2__c = 10;
        request.VirtualQuantity3__c = 10;
        request.VirtualQuantity4__c = 10;
        request.VirtualQuantity5__c = 10;

        insert request;
        ApexPages.StandardController stdController = new ApexPages.StandardController(request);
        CustomPOCRequestController controller = new CustomPOCRequestController(stdController);
        controller.savePage();
        request.Submission_Condition_Satisfied__c=true;
        try
        {
        	update request;
        }
        catch(Exception e)
        {
           
        }
        System.assertEquals(true, request.Submission_Condition_Satisfied__c);
    }  */
}