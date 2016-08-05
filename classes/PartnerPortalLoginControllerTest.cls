@isTest
public class PartnerPortalLoginControllerTest
{
    @isTest
    static void test()
    {
        List<User> users = [select Id, Email from User where IsActive=true and UserType='PowerPartner' limit 1];
        if(users.size() > 0)
        {
            System.runAs(users[0])
            {
                PartnerPortalLoginController controller = new PartnerPortalLoginController();
                controller.UserName = users[0].Email;
                controller.login();
            }
        }
    }
}