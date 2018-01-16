/*
 * Test for the SendUrlToUser
 * 23/8/2016 @Author Daniel Wu
 *
 */
@isTest
public class SendEmailAndCreateCampaignTest {
    /*@isTest(seeAllData=true)
	public static void testSendEmailAndCreateCampaign()
    {
        List<User> currentUser = [Select Id, Profile.Name, Profile.Id, Name from User where Profile.Name != '13g-SP Partner Community' and IsActive = true limit 1];
        if(currentUser.isEmpty())
        {
            return;
        }
        Contact con = new Contact(LastName='Acme', Email='acme@test.com',FirstName='Acme');
        insert con;
        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', OwnerId = currentUser[0].Id, Contact__c = con.Id, Activity_Date__c = date.today());
        insert mdf;
        MDF_Request__c newMDF = [Select Id, Approval_status__c,Activity_Complete__c, MDF_Status__c, SendReminder__c from MDF_Request__c where Id =: mdf.Id];
        newMDF.Approval_Status__c = 'Approved';
        newMDF.Activity_Complete__c = false;
        newMDF.MDF_Status__c = 'Past Due';
        newMDF.SendReminder__c = true;
		Test.startTest();
        update newMDF;
        Test.stopTest();
		mdf = [Select Id, Campaign__c from MDF_Request__c where Id =: newMDF.Id];
		system.assertEquals(1, [Select Count() from Campaign where Id =: mdf.Campaign__c]);
    }*/
}