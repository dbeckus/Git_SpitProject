@isTest
public class NewAuthorizationCodesControllerTest
{
	@isTest
    static void testNewAuthorizationCodesController()
    {
        Account acc = new Account(Name='acme');
        insert acc;
        Training_Course__c course = new Training_Course__c(Name='acme', Course_Code__c='test');
        insert course;
        
        Test.setCurrentPage(new PageReference('/apex/NewAuthorizationCodes?id=' + acc.Id));
        NewAuthorizationCodesController controller = new NewAuthorizationCodesController();
        controller.SendEmail('test@acme.com', 'test', Blob.valueOf('test'));        
        controller.CourseCode = 'test';
        controller.EmailAddress = 'acme@acme.com';                
        controller.createAuthorizationCode();
        
        System.assert([select count() from AuthCode__c where Course_Code__c = 'test'] > 0);
    }
}