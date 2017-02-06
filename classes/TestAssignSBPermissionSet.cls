@ISTest
public class TestAssignSBPermissionSet {
    @IsTest(SeeAllData=true)
    public static void test1()
    {
        Profile prof = [SELECT Id FROM Profile WHERE Name='1.4- Intl Regional Sales Manager']; 
        User usr = new User(Alias = 'standt', Email='testUser@uniquetest.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = prof.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='testUser@uniquetest.com');
        
        usr.IsActive =true;
        insert usr;
        
        List<PermissionSetAssignment> lstData= [Select Id from PermissionSetAssignment where AssigneeId=:usr.Id and PermissionSetId in('0PS38000000LQeF','0PS38000000Xzp1')];
        System.assert(lstData.size()>0);
    }

}