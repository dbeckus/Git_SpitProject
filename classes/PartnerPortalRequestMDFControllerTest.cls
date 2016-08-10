/**
 * Test class of PartnerPortalRequestMDFController.
 *
 */

@isTest
private class PartnerPortalRequestMDFControllerTest
{
    @isTest
    static void testPartnerPortalRequestMDF()
    {
        Account testAccount = new Account(Name = 'acme');
        insert testAccount;

        Contact testContact = new Contact(LastName = 'acme', AccountId = testAccount.Id);
        insert testContact;

        Test.startTest();
        Profile spPortalProfile = [select Id from Profile where Name = '13g-SP Partner Community'];
        createTestPortalUser('acme', 'acme@silver-peak.example', testContact.Id, spPortalProfile.Id);
        Test.stopTest();
        
        User testPortalUser = [select Id, ContactId from User where ContactId = :testContact.Id limit 1];

        System.runAs(testPortalUser) {
            //Test Case: Insert a new MDF Request
            PartnerPortalRequestMDFController controller = new PartnerPortalRequestMDFController();
            controller.request.Approval_Status__c = 'Unsubmitted';
            controller.save();
            System.assertNotEquals(null, controller.request.Id);

            controller.invoiceAttachment.Body = Blob.valueOf('acme');
            controller.proofAttachment.Body = Blob.valueOf('acme');
            controller.attlistAttachment.Body = Blob.valueOf('acme');
            controller.sampleAtachment.Body = Blob.valueOf('acme');
            controller.eventAttachment.Body = Blob.valueOf('acme');
            controller.addlAttachment1.Body = Blob.valueOf('acme');
            controller.addlAttachment2.Body = Blob.valueOf('acme');
            controller.addlAttachment3.Body = Blob.valueOf('acme');
            controller.save();

            controller.submit();
            System.assertEquals('Pending', [select Approval_Status__c from MDF_Request__c where Id = :controller.request.Id].Approval_Status__c);
            
            //Test Case: Edit an old MDF Request
            PageReference pageRef = new PageReference('/apex/PartnerPortalRequestMDF');
            pageRef.getParameters().put('id', controller.request.Id);
            Test.setCurrentPage(pageRef);
            controller = new PartnerPortalRequestMDFController();
            controller.authorize();

            //Test Case: Delete an attachment
            pageRef.getParameters().put('file', controller.invoiceAttachment.Id);
            Test.setCurrentPage(pageRef);
            controller.deleteAttachment();
            System.assertEquals(0, [select count() from Attachment where Id = :controller.addlAttachment1.Id]);

            //Test Case: Update MDF Request and send email notification
            controller.save();
        }
    }
    
    @isTest
    static void testPartnerPortalManageMDF()
    {
        PartnerPortalRequestMDFController controller = new PartnerPortalRequestMDFController();
        controller.search();
    }

    static void createTestPortalUser(String name, String email, String contactId, String profileId) {
        User testPortalUser = new User();
        testPortalUser.UserName = email + '.sp';
        testPortalUser.Email = email;
        testPortalUser.LastName = name;
        testPortalUser.Alias = name;
        testPortalUser.TimeZoneSidKey = 'America/Los_Angeles';
        testPortalUser.LocaleSidKey = 'en_US';
        testPortalUser.EmailEncodingKey = 'UTF-8';
        testPortalUser.LanguageLocaleKey = 'en_US';
        testPortalUser.ContactId = contactId;
        testPortalUser.ProfileId = profileId;
        insert testPortalUser;
    }
}