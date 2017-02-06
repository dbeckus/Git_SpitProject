/*
 * Test for the SendUrlToUser
 * 23/8/2016 @Author Daniel Wu
 */
@isTest
public class SendMdfUrlToClientControllerTest {
    @isTest
    public static void testSendMdfUrlToClient()
    {
        List<User> currentUser = [Select Id, Profile.Name, Profile.Id, Name from User where Profile.Name != '13g-SP Partner Community' and IsActive = true limit 1];
        if(currentUser.isEmpty())
        {
            return;
        }
        Contact con = new Contact(LastName='Acme', Email='acme@test.com',FirstName = 'Acme');
        insert con;
        MDF_Request__c mdf = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                Silver_Peak_Speaking_Opportunity__c = 'Yes', OwnerId = currentUser[0].Id, Contact__c = con.Id);
        insert mdf;
        ApexPages.currentPage().getParameters().put('id',mdf.id);
        SendMdfUrlToClientController sutu = new SendMdfUrlToClientController();
        sutu.SendMdfUrlToClient();
        
        MDF_Request__c mdf1 = new MDF_Request__c(Type_of_Program__c ='Awareness', Event_Materials_Requested__c = 'test\r\nmessage',
                                                 Silver_Peak_Speaking_Opportunity__c = 'Yes', OwnerId = currentUser[0].Id);
        insert mdf1;
        ApexPages.currentPage().getParameters().put('id',mdf1.id);
        sutu.SendMdfUrlToClient();
        System.assertEquals(sutu.mdfId, '');
        
        ApexPages.currentPage().getParameters().put('id', 'test');
        sutu.SendMdfUrlToClient();
        System.assertEquals(sutu.mdfId, '');
    }
}