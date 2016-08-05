public with sharing class PartnerPortalForgotPasswordController 
{
    public String Username {get; set;}   
    public Boolean ShowError {get; set;}

    public PartnerPortalForgotPasswordController() {}
  
    public PageReference forgotPassword() 
    {
        String formattedUsername = (Username != null && !Username.endsWith('.sp')) ? (Username + '.sp') : Username;
        User foundUser = PartnerPortalLoginController.getUserByEmail(new List<String> {formattedUsername, Username});
        if(foundUser != null)
        { 
            ShowError = false;
            Boolean success = Site.forgotPassword(foundUser.Username);
            PageReference confirmPage = Page.PartnerPortalForgotPasswordConfirm;
            confirmPage.setRedirect(true);
            if(success) 
            {  
                return confirmPage;
            }
        }
        else
        {
            ShowError = true;
        }
        return null;
    }
    
    @isTest
    static void testForgotPasswordController () {
        PartnerPortalForgotPasswordController  controller = new PartnerPortalForgotPasswordController ();
        controller.Username = UserInfo.getUsername();            
        System.assertEquals(controller.forgotPassword(),null);                           
    } 
}