public class PartnerPortalLoginController
{
    public PartnerPortalLoginController()
    {
        hasLoginError = false;
        List<User> users = [select Id, Contact.FirstName from User where Id=:UserInfo.getUserId() limit 1];
        ContactName = (users.size() > 0) ? users[0].Contact.FirstName : '';
    }
    
    public String Username { get; set; }
    public String Password { get; set; }
    public String ContactName { get; private set; }
    
    public Boolean hasLoginError { get; set; }
    
    public PageReference login()
    {
        try
        {
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            String startURL = ApexPages.currentPage().getParameters().get('startURL');
            String homeURL = String.isBlank(retURL) ? (String.isBlank(startURL) ? 'champions_home' : startURL) : retURL;
            hasLoginError = false;
            String formattedUsername = (Username != null && !Username.endsWith('.sp')) ? (Username + '.sp') : Username;   //To make sure username is not duplicate to other org
            User usr = getUserByEmail(new List<String> {formattedUsername, Username});
            if(usr != null)
            {
                if(usr.LastLoginDate != null || usr.CreatedDate >= Date.newInstance(2014,11,1))
                {
                    PageReference result = Site.login(usr.Username, Password, homeURL);
                    if(result == null)
                    {
                        hasLoginError = true;
                    }
                    return result;
                }
                else
                {
                    System.resetPassword(usr.Id, true);
                    return new PageReference('/reset_password_finish');
                }
            }
            else
            {
                hasLoginError = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Your username does not exist.'));
                return null;
            }
        }
        catch(Exception ex)
        {
            hasLoginError = true;
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public static User getUserByEmail(String[] names)
    {
        List<User> users = [select Id, Username, LastLoginDate, CreatedDate from User where Username in :names and IsActive=true and UserType in ('PowerPartner', 'CSPLitePortal', 'CustomerSuccess', 'PowerCustomerSuccess') limit 1];
        return (users.size() > 0) ? users[0] : null;
    }
}