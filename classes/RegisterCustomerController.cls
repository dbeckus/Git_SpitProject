/*
 * Controller of customer register pages
 * RegisterInformationcustomer, RegisterAuthorizationCodeCustomer, RegisterResultCustomer
 */
public class RegisterCustomerController extends RegisterController
{
    //input basic information
    public override PageReference GotoStep1()
    {
        return Page.RegisterInformation;
    }
    //input authorization code
    public override PageReference GotoStep2()
    {
        return Page.RegisterAuthorizationCode; 
    }
    
    //confirmation
    public override PageReference GotoStep3()
    {
        saveRegisterInformation();
        return page.RegisterResult;
    }
    
        
    @isTest
    static void testRegisterController()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Training_Course__c course = new Training_Course__c(Name='acme', Course_Code__c='test');
        insert course;
        AuthCode__c code = new AuthCode__c(Account__c=acc.Id, Course_Code__c='test', Valid__c=true);
        insert code;
        code = [select Id, Authorization_Code__c from AuthCode__c where Id=:code.Id limit 1];
        Training_Events__c event = new Training_Events__c(Start_Date__c=Date.today().addDays(1), Course_Name__c=course.Id);
        insert event;
        
        Test.setCurrentPage(new PageReference('/apex/RegisterInformation?event=' + event.Id));
        RegisterCustomerController controller = new RegisterCustomerController();
        System.assert(controller.TrainEvent != null);
        System.assert(controller.gotoStep1() != null);
        System.assert(controller.gotoStep2() != null);
        
        controller.Student.Email = 'acme@acme.com';
        controller.Student.LastName = 'acme';
        controller.AuthCode = code.Authorization_Code__c;
        
        controller.gotoStep3();
    }
}